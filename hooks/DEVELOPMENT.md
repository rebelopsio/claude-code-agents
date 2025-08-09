# Hook Development Guide

This guide provides instructions for developing, testing, and validating Claude Code hooks.

## Hook Types

Claude Code supports the following hook types:

- **PreToolUse**: Runs before a tool is invoked
- **PostToolUse**: Runs after a tool completes
- **SessionStart**: Runs when a session begins
- **SubagentStop**: Runs when a subagent completes
- **Notification**: Runs for notifications
- **UserPromptSubmit**: Runs when user submits a prompt
- **Stop**: Runs when Claude stops
- **PreCompact**: Runs before context compaction

## Development Workflow

### 1. Create a New Hook

```bash
# Create hook file
touch hooks/my-new-hook.sh

# Add shebang and basic structure
cat > hooks/my-new-hook.sh << 'EOF'
#!/bin/bash
# PreToolUse hook: Description of what this hook does

# Your hook logic here
echo "Hook executing..."

# Always exit with 0 unless blocking
exit 0
EOF

# Make executable
chmod +x hooks/my-new-hook.sh
```

### 2. Available Environment Variables

Hooks have access to these Claude environment variables:

- `CLAUDE_TOOL_NAME`: The name of the tool being invoked
- `CLAUDE_TOOL_RESULT`: The result of the tool execution (PostToolUse)
- `CLAUDE_TOOL_EXIT_CODE`: Exit code of the tool (PostToolUse)
- `CLAUDE_SUBAGENT_TYPE`: Type of subagent (Task tool)
- `CLAUDE_TASK_DESCRIPTION`: Description of the task

### 3. Hook Guidelines

#### Exit Codes

- **exit 0**: Allow operation to proceed (default)
- **exit 1**: Block operation (only for validation hooks)

#### Output

- Output to stdout is shown to the user
- Use clear prefixes: ✅ ❌ ⚠️ 💡 🔍 📊

#### Data Storage

- Store data in `$HOME/.claude-code/`
- Use JSON for structured data
- Clean up old data periodically

#### Performance

- Keep hooks fast (<1 second execution)
- Avoid blocking operations
- Use background processes if needed

## Testing Hooks

### Manual Testing

```bash
# Test with mock environment
CLAUDE_TOOL_NAME="Task" \
CLAUDE_SUBAGENT_TYPE="go-architect" \
./hooks/agent-selector.sh "Design a service"

# Test blocking behavior
CLAUDE_TOOL_NAME="Bash" \
./hooks/dangerous-operation-validator.sh "rm -rf /"
```

### Automated Testing

```bash
# Run validation script
python .github/scripts/validate_hooks.py

# Run functionality tests
python .github/scripts/test_hooks.py
```

### Pre-commit Validation

```bash
# Install pre-commit hooks
pre-commit install

# Run on all files
pre-commit run --all-files

# Run on specific hooks
pre-commit run validate-hooks --all-files
```

## CI Integration

Hooks are automatically validated in CI:

1. **Structure validation**: Shebang, exit codes, syntax
2. **Permission check**: Execute permissions
3. **Dependency check**: Required commands available
4. **Security scan**: No hardcoded secrets or dangerous patterns

## Common Patterns

### Logging Pattern

```bash
LOG_FILE="$HOME/.claude-code/hook.log"
mkdir -p "$HOME/.claude-code"

log_event() {
    echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] $1" >> "$LOG_FILE"
}

log_event "Hook executed: $CLAUDE_TOOL_NAME"
```

### JSON Storage Pattern

```bash
DATA_FILE="$HOME/.claude-code/data.json"

# Read JSON
if [[ -f "$DATA_FILE" ]]; then
    data=$(cat "$DATA_FILE")
else
    data='{}'
fi

# Update JSON (requires jq)
echo "$data" | jq --arg key "value" '.[$key] = "data"' > "$DATA_FILE"
```

### Conditional Execution Pattern

```bash
# Only run for specific tools
if [[ "$CLAUDE_TOOL_NAME" == "Task" ]]; then
    echo "Processing Task tool..."
fi

# Only run for specific agents
if [[ "$CLAUDE_SUBAGENT_TYPE" == *"debugger"* ]]; then
    echo "Debugger agent detected"
fi
```

### Safe Command Validation

```bash
# Validate before blocking
validate_command() {
    local cmd="$1"

    # Check multiple conditions
    if [[ "$cmd" == *"rm -rf /"* ]]; then
        echo "❌ BLOCKED: Dangerous command"
        return 1
    fi

    return 0
}

if ! validate_command "$1"; then
    exit 1
fi
```

## Debugging Hooks

### Enable Debug Output

```bash
#!/bin/bash
set -x  # Enable debug output

# Or conditionally
[[ "$DEBUG" == "1" ]] && set -x
```

### Log to stderr

```bash
# Debug output to stderr (not shown to user)
echo "Debug: Variable value = $var" >&2
```

### Test in Isolation

```bash
# Create test environment
export HOME=$(mktemp -d)
mkdir -p "$HOME/.claude-code"

# Run hook
./hooks/my-hook.sh

# Check results
ls -la "$HOME/.claude-code/"
```

## Security Considerations

### Never Do This

```bash
# ❌ Don't use eval with user input
eval "$user_input"

# ❌ Don't store secrets
API_KEY="hardcoded-secret"

# ❌ Don't use unquoted variables
rm -rf $path  # Should be "$path"
```

### Always Do This

```bash
# ✅ Quote variables
rm -rf "$path"

# ✅ Validate input
if [[ ! "$input" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "Invalid input"
    exit 1
fi

# ✅ Use safe defaults
: ${VAR:="default_value"}
```

## Hook Examples

### Example 1: Simple Logger

```bash
#!/bin/bash
# PostToolUse hook: Log all tool executions

LOG="$HOME/.claude-code/tools.log"
mkdir -p "$(dirname "$LOG")"

echo "[$(date -u +%FT%T)] Tool: $CLAUDE_TOOL_NAME" >> "$LOG"

exit 0
```

### Example 2: Validation Hook

```bash
#!/bin/bash
# PreToolUse hook: Validate dangerous operations

if [[ "$CLAUDE_TOOL_NAME" == "Bash" ]]; then
    if [[ "$1" == *"sudo"* ]]; then
        echo "❌ BLOCKED: sudo commands not allowed"
        exit 1
    fi
fi

exit 0
```

### Example 3: Context Provider

```bash
#!/bin/bash
# SessionStart hook: Provide project context

if [[ -f "package.json" ]]; then
    echo "📦 Node.js project detected"
    echo "Available scripts:"
    grep '"scripts"' -A 10 package.json | grep '"' | head -5
fi

exit 0
```

## Troubleshooting

### Hook Not Running

1. Check execute permissions: `ls -la hooks/`
2. Verify hook configuration: `claude-code config get hooks`
3. Check hook syntax: `bash -n hooks/my-hook.sh`

### Hook Blocking Unexpectedly

1. Check exit codes: Ensure `exit 0` for non-blocking
2. Review conditions: May be too broad
3. Test in isolation: Run with mock environment

### Performance Issues

1. Profile execution: `time ./hooks/my-hook.sh`
2. Avoid blocking calls: Use background processes
3. Cache expensive operations: Store results in files

## Contributing

When contributing hooks:

1. Follow naming convention: `descriptive-name.sh`
2. Include hook type comment at top
3. Document environment variables used
4. Add to README.md documentation
5. Include tests in `test_hooks.py`
6. Ensure passes validation: `python .github/scripts/validate_hooks.py`
