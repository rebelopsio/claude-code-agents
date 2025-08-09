#!/usr/bin/env python3
"""
Validate Claude Code hooks for structure, syntax, and compatibility.
"""

import os
import sys
import json
import subprocess
import re
from pathlib import Path
from typing import List, Dict, Tuple, Optional

# Hook types supported by Claude Code
VALID_HOOK_TYPES = [
    'PreToolUse',
    'PostToolUse',
    'SessionStart',
    'SubagentStop',
    'Notification',
    'UserPromptSubmit',
    'Stop',
    'PreCompact'
]

# Required environment variables that hooks might use
CLAUDE_ENV_VARS = [
    'CLAUDE_TOOL_NAME',
    'CLAUDE_TOOL_RESULT',
    'CLAUDE_TOOL_EXIT_CODE',
    'CLAUDE_SUBAGENT_TYPE',
    'CLAUDE_TASK_DESCRIPTION'
]

class HookValidator:
    def __init__(self, hooks_dir: str = "hooks"):
        self.hooks_dir = Path(hooks_dir)
        self.errors = []
        self.warnings = []

    def validate_all(self) -> bool:
        """Validate all hooks in the hooks directory."""
        if not self.hooks_dir.exists():
            self.errors.append(f"Hooks directory '{self.hooks_dir}' does not exist")
            return False

        hook_files = list(self.hooks_dir.glob("*.sh"))
        if not hook_files:
            self.warnings.append(f"No hook files found in '{self.hooks_dir}'")
            return True

        print(f"🔍 Validating {len(hook_files)} hooks in {self.hooks_dir}/")
        print()

        all_valid = True
        for hook_file in hook_files:
            if hook_file.name == "README.md":
                continue
            print(f"Validating {hook_file.name}...")
            if not self.validate_hook(hook_file):
                all_valid = False
            print()

        return all_valid

    def validate_hook(self, hook_path: Path) -> bool:
        """Validate a single hook file."""
        validations = [
            ("Structure", self.check_structure),
            ("Syntax", self.check_syntax),
            ("Permissions", self.check_permissions),
            ("Exit codes", self.check_exit_codes),
            ("Environment usage", self.check_env_usage),
            ("Dependencies", self.check_dependencies),
            ("Security", self.check_security)
        ]

        hook_valid = True
        for check_name, check_func in validations:
            is_valid, message = check_func(hook_path)
            status = "✅" if is_valid else "❌"
            print(f"  {status} {check_name}: {message}")
            if not is_valid:
                hook_valid = False
                self.errors.append(f"{hook_path.name}: {message}")

        return hook_valid

    def check_structure(self, hook_path: Path) -> Tuple[bool, str]:
        """Check if hook has proper structure."""
        with open(hook_path, 'r') as f:
            lines = f.readlines()

        if not lines:
            return False, "File is empty"

        # Check shebang
        if not lines[0].startswith("#!/"):
            return False, "Missing shebang line"

        if "bash" not in lines[0] and "sh" not in lines[0]:
            return False, "Shebang should specify bash or sh"

        # Check for hook type comment
        content = ''.join(lines[:20])  # Check first 20 lines for type
        type_found = False
        for hook_type in VALID_HOOK_TYPES:
            if hook_type in content:
                type_found = True
                break

        if not type_found:
            self.warnings.append(f"{hook_path.name}: No hook type specified in comments")

        # Check for exit statement
        content_full = ''.join(lines)
        if "exit" not in content_full:
            return False, "Missing exit statement"

        return True, "Proper structure"

    def check_syntax(self, hook_path: Path) -> Tuple[bool, str]:
        """Check bash syntax using bash -n."""
        try:
            result = subprocess.run(
                ["bash", "-n", str(hook_path)],
                capture_output=True,
                text=True
            )

            if result.returncode != 0:
                error_msg = result.stderr.strip() if result.stderr else "Syntax error"
                return False, f"Bash syntax error: {error_msg}"

            return True, "Valid bash syntax"

        except subprocess.CalledProcessError as e:
            return False, f"Syntax check failed: {e}"
        except FileNotFoundError:
            self.warnings.append("bash not found - skipping syntax check")
            return True, "Skipped (bash not available)"

    def check_permissions(self, hook_path: Path) -> Tuple[bool, str]:
        """Check if hook has execute permissions."""
        if not os.access(hook_path, os.X_OK):
            return False, "Missing execute permission"
        return True, "Executable"

    def check_exit_codes(self, hook_path: Path) -> Tuple[bool, str]:
        """Check if hook properly uses exit codes."""
        with open(hook_path, 'r') as f:
            content = f.read()

        # Check for exit statements
        exit_pattern = r'exit\s+(\d+)'
        exits = re.findall(exit_pattern, content)

        if not exits:
            return False, "No exit statements found"

        # Check if there's at least one success exit
        if "exit 0" not in content:
            self.warnings.append(f"{hook_path.name}: No 'exit 0' found - hook might always fail")

        # Check for blocking exits (exit 1)
        if "exit 1" in content:
            # This is OK for validation hooks
            if "validator" in hook_path.name or "dangerous" in hook_path.name:
                return True, "Uses blocking exit (appropriate for validator)"
            else:
                self.warnings.append(f"{hook_path.name}: Uses 'exit 1' which blocks operations")

        return True, "Proper exit codes"

    def check_env_usage(self, hook_path: Path) -> Tuple[bool, str]:
        """Check if hook properly uses Claude environment variables."""
        with open(hook_path, 'r') as f:
            content = f.read()

        used_vars = []
        for var in CLAUDE_ENV_VARS:
            if var in content:
                used_vars.append(var)

        if used_vars:
            # Check if variables are properly referenced with $ or ${
            for var in used_vars:
                if f"${var}" not in content and f"${{{var}}}" not in content:
                    self.warnings.append(f"{hook_path.name}: {var} might not be properly referenced")

            return True, f"Uses Claude vars: {', '.join(used_vars)}"

        return True, "No Claude environment variables used"

    def check_dependencies(self, hook_path: Path) -> Tuple[bool, str]:
        """Check if hook dependencies are available."""
        with open(hook_path, 'r') as f:
            content = f.read()

        # Common commands that might not be available
        dependencies = ['jq', 'curl', 'wget', 'python', 'node']
        missing = []

        for dep in dependencies:
            # Check if dependency is used
            if dep in content:
                # Check if it's available
                if not self._command_exists(dep):
                    missing.append(dep)

        if missing:
            return False, f"Missing dependencies: {', '.join(missing)}"

        return True, "All dependencies available"

    def check_security(self, hook_path: Path) -> Tuple[bool, str]:
        """Check for security issues in hooks."""
        with open(hook_path, 'r') as f:
            content = f.read()

        issues = []

        # Check for eval usage
        if "eval" in content:
            issues.append("Uses 'eval' - potential security risk")

        # Check for unquoted variables
        unquoted_pattern = r'\$[A-Z_]+(?![A-Z_"\'}])'
        if re.search(unquoted_pattern, content):
            self.warnings.append(f"{hook_path.name}: Potentially unquoted variables")

        # Check for hardcoded secrets
        secret_patterns = [
            r'password\s*=\s*["\'][^"\']+["\']',
            r'api_key\s*=\s*["\'][^"\']+["\']',
            r'secret\s*=\s*["\'][^"\']+["\']'
        ]

        for pattern in secret_patterns:
            if re.search(pattern, content, re.IGNORECASE):
                issues.append("Possible hardcoded secrets")
                break

        # Check for unsafe rm commands
        if "rm -rf /" in content and "exit 1" not in content:
            issues.append("Dangerous rm command without protection")

        if issues:
            return False, f"Security issues: {'; '.join(issues)}"

        return True, "No security issues found"

    def _command_exists(self, command: str) -> bool:
        """Check if a command exists on the system."""
        try:
            subprocess.run(
                ["which", command],
                capture_output=True,
                check=False
            )
            return True
        except:
            return False

    def print_summary(self):
        """Print validation summary."""
        print("=" * 60)
        print("VALIDATION SUMMARY")
        print("=" * 60)

        if self.errors:
            print(f"\n❌ {len(self.errors)} errors found:")
            for error in self.errors:
                print(f"  - {error}")

        if self.warnings:
            print(f"\n⚠️  {len(self.warnings)} warnings found:")
            for warning in self.warnings:
                print(f"  - {warning}")

        if not self.errors and not self.warnings:
            print("\n✅ All hooks validated successfully!")

        print()
        return len(self.errors) == 0


def main():
    """Main validation function."""
    # Check if hooks directory exists
    hooks_dir = Path("hooks")
    if not hooks_dir.exists():
        # Try from repository root
        hooks_dir = Path(__file__).parent.parent.parent / "hooks"

    if not hooks_dir.exists():
        print(f"❌ Hooks directory not found at {hooks_dir}")
        sys.exit(1)

    validator = HookValidator(hooks_dir)

    # Run validation
    is_valid = validator.validate_all()

    # Print summary
    validator.print_summary()

    # Exit with appropriate code
    sys.exit(0 if is_valid else 1)


if __name__ == "__main__":
    main()
