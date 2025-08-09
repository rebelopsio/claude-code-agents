# Claude Code Agent System Hooks

This directory contains hooks that enhance the Claude Code agent system by providing automatic suggestions, tracking, validation, and debugging assistance.

## Available Hooks

### 1. Agent Selector (`agent-selector.sh`)

**Type:** PreToolUse  
**Purpose:** Automatically suggests appropriate agents based on task patterns

- Analyzes task descriptions for keywords
- Suggests relevant specialist agents
- Helps users choose the right agent for their task

**Example suggestions:**

- Architecture tasks → `go-architect`, `rust-systems-engineer`
- Debugging tasks → Language-specific debuggers
- Full-stack tasks → `fullstack-nextjs-go`, `fullstack-nuxtjs-go`

### 2. Agent Hierarchy Tracker (`agent-hierarchy-tracker.sh`)

**Type:** PostToolUse  
**Purpose:** Tracks agent usage patterns and delegation chains

- Logs agent invocations to `~/.claude-code/agent-usage.log`
- Maintains usage statistics in `~/.claude-code/agent-stats.json`
- Detects and reports delegation patterns
- Shows top agents by usage every 10 invocations

### 3. Session Agent Context (`session-agent-context.sh`)

**Type:** SessionStart  
**Purpose:** Loads agent hierarchy context at session start

- Displays available agent hierarchy patterns
- Shows quick selection guide for common tasks
- Detects project type and suggests relevant agents
- Shows your most frequently used agents

### 4. Dangerous Operation Validator (`dangerous-operation-validator.sh`)

**Type:** PreToolUse  
**Purpose:** Validates and warns about potentially dangerous operations

- Blocks system-critical deletions (e.g., `rm -rf /`)
- Warns about overly permissive permissions
- Cautions about sensitive file modifications
- Alerts on production deployments
- Validates agent selection appropriateness

### 5. Auto Debug Suggester (`auto-debug-suggester.sh`)

**Type:** PostToolUse  
**Purpose:** Automatically suggests debugging agents when errors are detected

- Detects language-specific error patterns
- Suggests appropriate debugging specialists
- Tracks recurring error patterns
- Provides contextual debugging tips

**Detected patterns:**

- Go: panics, runtime errors
- Rust: borrow checker, lifetime errors
- Python: tracebacks, import errors
- JavaScript: TypeErrors, ReferenceErrors
- Next.js: Hydration errors, SSR issues
- Nuxt.js: Nitro errors, composable issues

### 6. Agent Context Bridge (`agent-context-bridge.sh`)

**Type:** SubagentStop  
**Purpose:** Bridges context between agent invocations in delegation chains

- Extracts key findings from agent outputs
- Tracks agent invocation chains
- Suggests next agents based on workflow patterns
- Maintains context between related agent calls
- Detects complete development chains (architect → engineer → test)

**Features:**

- Stores agent findings in `~/.claude-code/agent-context.json`
- Tracks chains in `~/.claude-code/agent-chain.log`
- Automatically suggests next steps in the workflow
- Resets context after complete chains to prevent overflow

## Installation

1. Make hooks executable:

```bash
chmod +x hooks/*.sh
```

2. Configure Claude Code to use hooks:

```bash
# Add to your Claude Code settings
claude-code config set hooks.preTool ./hooks/agent-selector.sh
claude-code config set hooks.preTool ./hooks/dangerous-operation-validator.sh
claude-code config set hooks.postTool ./hooks/agent-hierarchy-tracker.sh
claude-code config set hooks.postTool ./hooks/auto-debug-suggester.sh
claude-code config set hooks.sessionStart ./hooks/session-agent-context.sh
claude-code config set hooks.subagentStop ./hooks/agent-context-bridge.sh
```

Or add to your settings JSON:

```json
{
  "hooks": {
    "preToolUse": ["./hooks/agent-selector.sh", "./hooks/dangerous-operation-validator.sh"],
    "postToolUse": ["./hooks/agent-hierarchy-tracker.sh", "./hooks/auto-debug-suggester.sh"],
    "sessionStart": "./hooks/session-agent-context.sh",
    "subagentStop": "./hooks/agent-context-bridge.sh"
  }
}
```

## Usage Patterns

### Workflow Enhancement

The hooks work together to create an enhanced agent workflow:

1. **Session starts** → Context loader shows available agents
2. **Task requested** → Agent selector suggests appropriate specialists
3. **Before execution** → Dangerous operation validator checks safety
4. **After execution** → Hierarchy tracker logs patterns
5. **Agent completes** → Context bridge maintains chain state
6. **On errors** → Debug suggester recommends debugging agents

### Data Collection

Hooks collect usage data in `~/.claude-code/`:

- `agent-usage.log`: Chronological agent invocations
- `agent-stats.json`: Usage frequency statistics
- `error-patterns.log`: Recurring error tracking
- `agent-context.json`: Current agent chain context
- `agent-chain.log`: Agent delegation chains

### Customization

Each hook can be customized by editing the shell scripts:

- Add new agent patterns to `agent-selector.sh`
- Modify danger patterns in `dangerous-operation-validator.sh`
- Extend error detection in `auto-debug-suggester.sh`
- Customize session messages in `session-agent-context.sh`

## Benefits

1. **Improved Agent Discovery**: Users learn about relevant agents for their tasks
2. **Safety Validation**: Dangerous operations are caught before execution
3. **Usage Analytics**: Track which agents are most valuable
4. **Error Recovery**: Automatic debugging suggestions on failures
5. **Learning Curve**: Context at session start helps new users
6. **Delegation Visibility**: See how agents work together

## Examples

### Example 1: Architecture Task

```
User: "Design a microservices architecture"
Hook: "💡 Consider using architecture specialists: go-architect, rust-systems-engineer, nextjs-architect"
```

### Example 2: Error Detection

```
Tool: Bash command fails with Go panic
Hook: "🔍 Go error detected! Consider using: Task tool with go-debugger"
```

### Example 3: Dangerous Operation

```
Tool: Bash "rm -rf /"
Hook: "❌ BLOCKED: Attempting to delete system root directory"
```

## Troubleshooting

If hooks aren't working:

1. Check execution permissions: `ls -la hooks/*.sh`
2. Verify hook configuration: `claude-code config get hooks`
3. Test hooks manually: `./hooks/agent-selector.sh "test task"`
4. Check logs: `tail ~/.claude-code/*.log`

## Future Enhancements

Potential improvements:

- Machine learning for agent selection based on success rates
- Integration with CI/CD pipelines
- Custom hook templates for specific workflows
- Web dashboard for usage analytics
- Automatic agent chaining based on task complexity
