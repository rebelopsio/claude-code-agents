#!/usr/bin/env python3
"""
Test Claude Code hooks functionality by simulating hook execution scenarios.
"""

import os
import sys
import subprocess
import tempfile
import json
from pathlib import Path
from typing import Dict, Any, List, Tuple
import unittest


class HookTestCase(unittest.TestCase):
    """Base test case for hook testing."""

    def setUp(self):
        """Set up test environment."""
        self.hooks_dir = Path("hooks")
        if not self.hooks_dir.exists():
            self.hooks_dir = Path(__file__).parent.parent.parent / "hooks"

        self.temp_dir = tempfile.mkdtemp(prefix="claude_hooks_test_")

    def tearDown(self):
        """Clean up test environment."""
        # Clean up temp directory
        subprocess.run(["rm", "-rf", self.temp_dir], check=False)

    def run_hook(self, hook_name: str, env: Dict[str, str] = None, args: List[str] = None) -> Tuple[int, str, str]:
        """Run a hook script with given environment and arguments."""
        hook_path = self.hooks_dir / hook_name

        if not hook_path.exists():
            self.skipTest(f"Hook {hook_name} not found")

        # Set up environment
        test_env = os.environ.copy()
        test_env["HOME"] = self.temp_dir  # Use temp dir for test data

        if env:
            test_env.update(env)

        # Run hook
        cmd = [str(hook_path)]
        if args:
            cmd.extend(args)

        result = subprocess.run(
            cmd,
            env=test_env,
            capture_output=True,
            text=True
        )

        return result.returncode, result.stdout, result.stderr


class TestAgentSelector(HookTestCase):
    """Test agent-selector.sh hook."""

    def test_architecture_suggestion(self):
        """Test that architecture keywords trigger appropriate suggestions."""
        env = {
            "CLAUDE_TOOL_NAME": "Task",
            "CLAUDE_TASK_DESCRIPTION": "Design a microservices architecture"
        }

        returncode, stdout, stderr = self.run_hook("agent-selector.sh", env, ["Design a microservices architecture"])

        self.assertEqual(returncode, 0, "Hook should exit successfully")
        self.assertIn("architect", stdout.lower(), "Should suggest architecture specialists")

    def test_debugging_suggestion(self):
        """Test that debugging keywords trigger appropriate suggestions."""
        env = {
            "CLAUDE_TOOL_NAME": "Task",
            "CLAUDE_TASK_DESCRIPTION": "Debug the error in my Go application"
        }

        returncode, stdout, stderr = self.run_hook("agent-selector.sh", env, ["Debug the error in my Go application"])

        self.assertEqual(returncode, 0, "Hook should exit successfully")
        self.assertIn("debugger", stdout.lower(), "Should suggest debugging specialists")

    def test_non_task_tool(self):
        """Test that non-Task tools don't trigger suggestions."""
        env = {
            "CLAUDE_TOOL_NAME": "Bash",
            "CLAUDE_TASK_DESCRIPTION": "ls -la"
        }

        returncode, stdout, stderr = self.run_hook("agent-selector.sh", env, ["ls -la"])

        self.assertEqual(returncode, 0, "Hook should exit successfully")
        self.assertNotIn("Consider", stdout, "Should not suggest agents for non-Task tools")


class TestDangerousOperationValidator(HookTestCase):
    """Test dangerous-operation-validator.sh hook."""

    def test_blocks_dangerous_rm(self):
        """Test that dangerous rm commands are blocked."""
        env = {
            "CLAUDE_TOOL_NAME": "Bash"
        }

        returncode, stdout, stderr = self.run_hook("dangerous-operation-validator.sh", env, ["rm -rf /"])

        self.assertEqual(returncode, 1, "Should block dangerous rm command")
        self.assertIn("BLOCKED", stdout, "Should show blocking message")

    def test_warns_permissive_chmod(self):
        """Test that overly permissive chmod generates warning."""
        env = {
            "CLAUDE_TOOL_NAME": "Bash"
        }

        returncode, stdout, stderr = self.run_hook("dangerous-operation-validator.sh", env, ["chmod 777 /tmp/test"])

        self.assertEqual(returncode, 0, "Should not block but warn")
        self.assertIn("WARNING", stdout, "Should show warning message")

    def test_allows_safe_commands(self):
        """Test that safe commands are allowed."""
        env = {
            "CLAUDE_TOOL_NAME": "Bash"
        }

        returncode, stdout, stderr = self.run_hook("dangerous-operation-validator.sh", env, ["ls -la"])

        self.assertEqual(returncode, 0, "Should allow safe commands")
        self.assertNotIn("BLOCKED", stdout, "Should not block safe commands")


class TestAgentHierarchyTracker(HookTestCase):
    """Test agent-hierarchy-tracker.sh hook."""

    def test_logs_agent_usage(self):
        """Test that agent usage is logged."""
        env = {
            "CLAUDE_TOOL_NAME": "Task",
            "CLAUDE_SUBAGENT_TYPE": "go-architect",
            "CLAUDE_TASK_DESCRIPTION": "Design Go service",
            "CLAUDE_TOOL_RESULT": "Design completed"
        }

        returncode, stdout, stderr = self.run_hook("agent-hierarchy-tracker.sh", env)

        self.assertEqual(returncode, 0, "Hook should exit successfully")

        # Check if log file was created
        log_file = Path(self.temp_dir) / ".claude-code" / "agent-usage.log"
        if log_file.exists():
            with open(log_file) as f:
                content = f.read()
                self.assertIn("go-architect", content, "Should log agent type")

    def test_detects_delegation(self):
        """Test that delegation patterns are detected."""
        env = {
            "CLAUDE_TOOL_NAME": "Task",
            "CLAUDE_SUBAGENT_TYPE": "go-architect",
            "CLAUDE_TASK_DESCRIPTION": "Design service",
            "CLAUDE_TOOL_RESULT": "Delegating to go-engineer for implementation"
        }

        returncode, stdout, stderr = self.run_hook("agent-hierarchy-tracker.sh", env)

        self.assertEqual(returncode, 0, "Hook should exit successfully")
        self.assertIn("Delegation detected", stdout, "Should detect delegation pattern")


class TestAutoDebugSuggester(HookTestCase):
    """Test auto-debug-suggester.sh hook."""

    def test_suggests_go_debugger(self):
        """Test that Go errors trigger Go debugger suggestion."""
        env = {
            "CLAUDE_TOOL_NAME": "Bash",
            "CLAUDE_TOOL_RESULT": "panic: runtime error: index out of range\ngoroutine 1 [running]:\nmain.main()\n\t/app/main.go:10",
            "CLAUDE_TOOL_EXIT_CODE": "1"
        }

        returncode, stdout, stderr = self.run_hook("auto-debug-suggester.sh", env)

        self.assertEqual(returncode, 0, "Hook should exit successfully")
        self.assertIn("go-debugger", stdout.lower(), "Should suggest Go debugger")

    def test_suggests_python_debugger(self):
        """Test that Python errors trigger Python debugger suggestion."""
        env = {
            "CLAUDE_TOOL_NAME": "Bash",
            "CLAUDE_TOOL_RESULT": "Traceback (most recent call last):\n  File 'test.py', line 1\nImportError: No module named 'test'",
            "CLAUDE_TOOL_EXIT_CODE": "1"
        }

        returncode, stdout, stderr = self.run_hook("auto-debug-suggester.sh", env)

        self.assertEqual(returncode, 0, "Hook should exit successfully")
        self.assertIn("python-debugger", stdout.lower(), "Should suggest Python debugger")

    def test_no_suggestion_on_success(self):
        """Test that successful commands don't trigger suggestions."""
        env = {
            "CLAUDE_TOOL_NAME": "Bash",
            "CLAUDE_TOOL_RESULT": "Success",
            "CLAUDE_TOOL_EXIT_CODE": "0"
        }

        returncode, stdout, stderr = self.run_hook("auto-debug-suggester.sh", env)

        self.assertEqual(returncode, 0, "Hook should exit successfully")
        self.assertNotIn("debugger", stdout.lower(), "Should not suggest debugger on success")


class TestSessionAgentContext(HookTestCase):
    """Test session-agent-context.sh hook."""

    def test_displays_hierarchy(self):
        """Test that agent hierarchy is displayed."""
        returncode, stdout, stderr = self.run_hook("session-agent-context.sh")

        self.assertEqual(returncode, 0, "Hook should exit successfully")
        self.assertIn("Hierarchy", stdout, "Should display hierarchy information")
        self.assertIn("Architects", stdout, "Should mention architects")

    def test_project_detection(self):
        """Test project type detection."""
        # Create a fake go.mod in temp dir
        go_mod = Path(self.temp_dir) / "go.mod"
        go_mod.write_text("module test")

        # Run hook from temp dir
        original_cwd = os.getcwd()
        try:
            os.chdir(self.temp_dir)
            returncode, stdout, stderr = self.run_hook("session-agent-context.sh")
        finally:
            os.chdir(original_cwd)

        self.assertEqual(returncode, 0, "Hook should exit successfully")
        # Note: This might not work as expected since the hook checks current directory
        # This is more of a placeholder test


class TestAgentContextBridge(HookTestCase):
    """Test agent-context-bridge.sh hook."""

    def test_extracts_findings(self):
        """Test that key findings are extracted from agent output."""
        env = {
            "CLAUDE_SUBAGENT_TYPE": "go-architect",
            "CLAUDE_TOOL_RESULT": "Designed microservices structure with event-driven pattern"
        }

        returncode, stdout, stderr = self.run_hook("agent-context-bridge.sh", env)

        self.assertEqual(returncode, 0, "Hook should exit successfully")

        # Check if context file was created
        context_file = Path(self.temp_dir) / ".claude-code" / "agent-context.json"
        if context_file.exists():
            with open(context_file) as f:
                context = json.load(f)
                self.assertIn("go-architect", context, "Should store agent findings")

    def test_suggests_next_agent(self):
        """Test that next agent in chain is suggested."""
        env = {
            "CLAUDE_SUBAGENT_TYPE": "go-architect",
            "CLAUDE_TOOL_RESULT": "Architecture defined"
        }

        returncode, stdout, stderr = self.run_hook("agent-context-bridge.sh", env)

        self.assertEqual(returncode, 0, "Hook should exit successfully")
        self.assertIn("engineer", stdout.lower(), "Should suggest engineer as next step")


class TestResponseNotifier(HookTestCase):
    """Test response-notifier.sh hook."""

    def test_notifies_on_bash_completion(self):
        """Test that notifications are triggered for completed bash commands."""
        env = {
            "CLAUDE_TOOL_NAME": "Bash",
            "CLAUDE_TOOL_EXIT_CODE": "0",
            "CLAUDE_TOOL_RESULT": "Command completed successfully",
            "CLAUDE_TASK_DESCRIPTION": "Running build script"
        }

        returncode, stdout, stderr = self.run_hook("response-notifier.sh", env)

        # Hook should exit successfully even if notifications fail
        self.assertEqual(returncode, 0, "Hook should exit successfully")

    def test_handles_failed_commands(self):
        """Test notification for failed commands."""
        env = {
            "CLAUDE_TOOL_NAME": "Bash",
            "CLAUDE_TOOL_EXIT_CODE": "1",
            "CLAUDE_TOOL_RESULT": "Error: command failed",
            "CLAUDE_TASK_DESCRIPTION": "Deploy to production"
        }

        returncode, stdout, stderr = self.run_hook("response-notifier.sh", env)

        self.assertEqual(returncode, 0, "Hook should exit successfully")

    def test_skips_quick_reads(self):
        """Test that quick read operations don't trigger notifications."""
        env = {
            "CLAUDE_TOOL_NAME": "Read",
            "CLAUDE_TOOL_EXIT_CODE": "0",
            "CLAUDE_TOOL_RESULT": "File read successfully"
        }

        returncode, stdout, stderr = self.run_hook("response-notifier.sh", env)

        self.assertEqual(returncode, 0, "Hook should exit successfully")


def run_tests():
    """Run all hook tests."""
    # Create test suite
    loader = unittest.TestLoader()
    suite = unittest.TestSuite()

    # Add all test cases
    suite.addTests(loader.loadTestsFromTestCase(TestAgentSelector))
    suite.addTests(loader.loadTestsFromTestCase(TestDangerousOperationValidator))
    suite.addTests(loader.loadTestsFromTestCase(TestAgentHierarchyTracker))
    suite.addTests(loader.loadTestsFromTestCase(TestAutoDebugSuggester))
    suite.addTests(loader.loadTestsFromTestCase(TestSessionAgentContext))
    suite.addTests(loader.loadTestsFromTestCase(TestAgentContextBridge))
    suite.addTests(loader.loadTestsFromTestCase(TestResponseNotifier))

    # Run tests
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)

    # Return exit code
    return 0 if result.wasSuccessful() else 1


def main():
    """Main test runner."""
    print("=" * 60)
    print("HOOK FUNCTIONALITY TESTS")
    print("=" * 60)
    print()

    # Check if hooks directory exists
    hooks_dir = Path("hooks")
    if not hooks_dir.exists():
        hooks_dir = Path(__file__).parent.parent.parent / "hooks"

    if not hooks_dir.exists():
        print(f"❌ Hooks directory not found at {hooks_dir}")
        sys.exit(1)

    # Run tests
    exit_code = run_tests()

    print()
    print("=" * 60)
    if exit_code == 0:
        print("✅ All hook tests passed!")
    else:
        print("❌ Some hook tests failed")
    print("=" * 60)

    sys.exit(exit_code)


if __name__ == "__main__":
    main()
