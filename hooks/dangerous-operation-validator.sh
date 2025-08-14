#!/bin/bash
# PreToolUse hook: Validate dangerous operations before execution

# This hook runs before tools are invoked
# It checks for potentially dangerous operations and warns/blocks as needed

TOOL_NAME="$CLAUDE_TOOL_NAME"
COMMAND="$1"

# Set non-blocking mode to prevent hanging
exec < /dev/null

# Exit immediately if no tool name provided
if [[ -z "$TOOL_NAME" ]]; then
    exit 0
fi

# Only process Bash, Task, Write, and MultiEdit tools
if [[ "$TOOL_NAME" != "Bash" ]] && [[ "$TOOL_NAME" != "Task" ]] && [[ "$TOOL_NAME" != "Write" ]] && [[ "$TOOL_NAME" != "MultiEdit" ]]; then
    exit 0
fi

# Function to check for dangerous patterns
check_dangerous_patterns() {
    local cmd="$1"
    local tool="$2"

    # Convert to lowercase for matching
    cmd_lower=$(echo "$cmd" | tr '[:upper:]' '[:lower:]')

    # Dangerous file operations
    if [[ "$tool" == "Bash" ]]; then
        # Check for recursive deletions
        if [[ "$cmd" == *"rm -rf /"* ]] || [[ "$cmd" == *"rm -rf /*"* ]]; then
            echo "❌ BLOCKED: Attempting to delete system root directory"
            exit 1
        fi

        # Check for dangerous chmod
        if [[ "$cmd" == *"chmod 777"* ]] && [[ "$cmd" == *"/"* ]]; then
            echo "⚠️ WARNING: Setting overly permissive permissions (777)"
        fi

        # Check for password/secret exposure
        if [[ "$cmd_lower" == *"password"* ]] || [[ "$cmd_lower" == *"secret"* ]] || [[ "$cmd_lower" == *"api_key"* ]]; then
            echo "🔐 CAUTION: Command may expose sensitive information"
        fi

        # Check for system modifications
        if [[ "$cmd" == *"/etc/"* ]] || [[ "$cmd" == *"/sys/"* ]] || [[ "$cmd" == *"/proc/"* ]]; then
            echo "⚠️ WARNING: Modifying system directories"
        fi
    fi

    # Infrastructure operations
    if [[ "$tool" == "Task" ]]; then
        local agent_type="$CLAUDE_SUBAGENT_TYPE"

        # Check for production deployments
        if [[ "$agent_type" == *"deployment"* ]] || [[ "$agent_type" == "terraform-architect" ]]; then
            if [[ "$cmd_lower" == *"production"* ]] || [[ "$cmd_lower" == *"prod"* ]]; then
                echo "🚨 CAUTION: Production deployment detected - ensure proper review"
            fi
        fi

        # Check for infrastructure destruction
        if [[ "$cmd_lower" == *"destroy"* ]] || [[ "$cmd_lower" == *"delete"* && "$cmd_lower" == *"infrastructure"* ]]; then
            echo "⚠️ WARNING: Infrastructure destruction operation detected"
        fi
    fi
}

# Function to validate agent selection
validate_agent_selection() {
    local agent="$1"
    local task="$2"

    # Check for mismatched agent selection
    if [[ "$agent" == "rust-debugger" ]] && [[ "$task" == *".py"* ]]; then
        echo "❓ Notice: Using Rust debugger for Python file - consider python-debugger instead"
    fi

    if [[ "$agent" == "go-architect" ]] && [[ "$task" == *"quick fix"* ]]; then
        echo "💡 Tip: For simple fixes, go-engineer might be more appropriate than go-architect"
    fi
}

# Main validation
case "$TOOL_NAME" in
    "Bash")
        check_dangerous_patterns "$COMMAND" "Bash"
        ;;
    "Task")
        check_dangerous_patterns "$CLAUDE_TASK_DESCRIPTION" "Task"
        validate_agent_selection "$CLAUDE_SUBAGENT_TYPE" "$CLAUDE_TASK_DESCRIPTION"
        ;;
    "Write"|"MultiEdit")
        # Check for writing to sensitive files
        if [[ "$1" == *".env"* ]] || [[ "$1" == *"credentials"* ]] || [[ "$1" == *"secrets"* ]]; then
            echo "🔐 CAUTION: Modifying potentially sensitive file"
        fi
        ;;
esac

# Always allow unless explicitly blocked
exit 0
