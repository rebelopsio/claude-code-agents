#!/bin/bash
# PostToolUse hook: Automatically suggest debugging agents when errors are detected

# This hook runs after tools complete
# It detects errors and suggests appropriate debugging specialists

TOOL_NAME="$CLAUDE_TOOL_NAME"
TOOL_RESULT="$CLAUDE_TOOL_RESULT"

# Function to detect error patterns and suggest debuggers
detect_and_suggest_debugger() {
    local result="$1"
    local suggested=false

    # Go errors
    if [[ "$result" == *"panic:"* ]] || [[ "$result" == *"runtime error:"* ]] || [[ "$result" == *"undefined:"* && "$result" == *".go:"* ]]; then
        echo "🔍 Go error detected! Consider using: Task tool with go-debugger"
        echo "   Example: 'Debug the panic in the Go application'"
        suggested=true
    fi

    # Rust errors
    if [[ "$result" == *"error[E"* ]] || [[ "$result" == *"cannot borrow"* ]] || [[ "$result" == *"lifetime"* ]]; then
        echo "🦀 Rust error detected! Consider using: Task tool with rust-debugger"
        echo "   Example: 'Debug the borrow checker error in the Rust code'"
        suggested=true
    fi

    # Python errors
    if [[ "$result" == *"Traceback (most recent call last):"* ]] || [[ "$result" == *"SyntaxError:"* ]] || [[ "$result" == *"ImportError:"* ]]; then
        echo "🐍 Python error detected! Consider using: Task tool with python-debugger"
        echo "   Example: 'Debug the Python traceback error'"
        suggested=true
    fi

    # JavaScript/TypeScript errors
    if [[ "$result" == *"SyntaxError:"* && "$result" == *".js"* ]] || [[ "$result" == *"TypeError:"* ]] || [[ "$result" == *"ReferenceError:"* ]]; then
        echo "📜 JavaScript error detected! Consider using: Task tool with javascript-debugger"
        echo "   Example: 'Debug the JavaScript TypeError'"
        suggested=true
    fi

    # Next.js specific errors
    if [[ "$result" == *"Error: Hydration"* ]] || [[ "$result" == *"next/router"* ]] || [[ "$result" == *"getServerSideProps"* ]]; then
        echo "▲ Next.js error detected! Consider using: Task tool with nextjs-debugger"
        echo "   Example: 'Debug the Next.js hydration error'"
        suggested=true
    fi

    # Nuxt.js specific errors
    if [[ "$result" == *"[nuxt]"* ]] || [[ "$result" == *"Nitro"* ]] || [[ "$result" == *"useFetch"* && "$result" == *"error"* ]]; then
        echo "💚 Nuxt.js error detected! Consider using: Task tool with nuxtjs-debugger"
        echo "   Example: 'Debug the Nuxt.js SSR error'"
        suggested=true
    fi

    # Test failures
    if [[ "$result" == *"FAIL"* ]] || [[ "$result" == *"failed"* && "$result" == *"test"* ]] || [[ "$result" == *"assertion"* ]]; then
        echo "🧪 Test failure detected! Consider using appropriate test engineer:"
        echo "   • go-test-engineer (for Go tests)"
        echo "   • rust-test-engineer (for Rust tests)"
        echo "   • python-test-engineer (for Python tests)"
        echo "   • react-nextjs-test-engineer (for React/Next.js tests)"
        suggested=true
    fi

    # Generic compilation errors
    if [[ "$result" == *"compilation error"* ]] || [[ "$result" == *"build failed"* ]]; then
        echo "🏗️ Build error detected! Consider using language-specific debugger or architect"
        suggested=true
    fi

    if [[ "$suggested" == true ]]; then
        echo ""
        echo "💡 Tip: Debuggers can analyze error patterns, suggest fixes, and validate solutions"
    fi
}

# Function to track error patterns
track_error_patterns() {
    local error_type="$1"
    local error_log="$HOME/.claude-code/error-patterns.log"

    mkdir -p "$HOME/.claude-code"

    # Log error pattern with timestamp
    echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] $error_type" >> "$error_log"

    # Check for recurring errors (last 10 entries)
    if [[ -f "$error_log" ]]; then
        local recent_count=$(tail -n 10 "$error_log" | grep -c "$error_type")
        if (( recent_count >= 3 )); then
            echo "🔄 Recurring error pattern detected: $error_type"
            echo "   Consider reviewing the architecture or implementation approach"
        fi
    fi
}

# Main error detection
case "$TOOL_NAME" in
    "Bash")
        # Check for non-zero exit codes
        if [[ "$CLAUDE_TOOL_EXIT_CODE" != "0" ]] && [[ -n "$CLAUDE_TOOL_EXIT_CODE" ]]; then
            detect_and_suggest_debugger "$TOOL_RESULT"

            # Track error patterns
            if [[ "$TOOL_RESULT" == *"error"* ]]; then
                track_error_patterns "bash_execution_error"
            fi
        fi
        ;;
    "Task")
        # Check for task failures
        if [[ "$TOOL_RESULT" == *"error"* ]] || [[ "$TOOL_RESULT" == *"failed"* ]]; then
            detect_and_suggest_debugger "$TOOL_RESULT"
            track_error_patterns "agent_task_error_$CLAUDE_SUBAGENT_TYPE"
        fi
        ;;
esac

exit 0
