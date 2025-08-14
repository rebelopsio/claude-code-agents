# Installing Claude Code Hooks

This guide will help you properly configure the hooks in this repository to work with Claude Code.

## Prerequisites

1. **Claude Code installed** and working
2. **Repository cloned** to your local machine
3. **Permissions set** on hook scripts

## Step 1: Make Hooks Executable

First, ensure all hook scripts have execute permissions:

```bash
cd /path/to/claude-code-agents
chmod +x hooks/*.sh
```

## Step 2: Locate Your Settings File

Claude Code settings can be configured in several locations. Choose one:

### Option A: User-level Settings (Recommended)

**Location**: `~/.claude/settings.json`

This will apply hooks to all your Claude Code sessions.

### Option B: Project-level Settings

**Location**: `.claude/settings.json` or `.claude/settings.local.json` in your project root

This will apply hooks only when working in that specific project.

## Step 3: Configure Hooks with Absolute Paths

Edit your chosen settings file and add the hooks configuration. **IMPORTANT**: Use absolute paths to your repository.

### Full Configuration Example

Replace `/path/to/claude-code-agents` with the actual path to your cloned repository:

```json
{
  "hooks": {
    "preToolUse": [
      "/path/to/claude-code-agents/hooks/agent-selector.sh",
      "/path/to/claude-code-agents/hooks/dangerous-operation-validator.sh"
    ],
    "postToolUse": [
      "/path/to/claude-code-agents/hooks/agent-hierarchy-tracker.sh",
      "/path/to/claude-code-agents/hooks/auto-debug-suggester.sh",
      "/path/to/claude-code-agents/hooks/web-resource-validator.sh",
      "/path/to/claude-code-agents/hooks/typescript-validator.sh",
      "/path/to/claude-code-agents/hooks/test-runner-validator.sh",
      "/path/to/claude-code-agents/hooks/response-notifier.sh"
    ],
    "sessionStart": "/path/to/claude-code-agents/hooks/session-agent-context.sh",
    "subagentStop": "/path/to/claude-code-agents/hooks/agent-context-bridge.sh"
  }
}
```

### Minimal Configuration (Just Notifications)

If you only want the response notifications:

```json
{
  "hooks": {
    "postToolUse": ["/path/to/claude-code-agents/hooks/response-notifier.sh"]
  }
}
```

## Step 4: Find Your Repository Path

To get the absolute path to your repository:

```bash
cd /path/to/claude-code-agents
pwd
# This will output something like: /Users/username/source/claude-code-agents
```

## Step 5: Create/Update Settings File

### Example for macOS/Linux:

```bash
# Get the repository path
REPO_PATH=$(cd /path/to/claude-code-agents && pwd)

# Create settings directory if it doesn't exist
mkdir -p ~/.claude

# Create or update settings.json
cat > ~/.claude/settings.json << EOF
{
  "hooks": {
    "preToolUse": [
      "$REPO_PATH/hooks/agent-selector.sh",
      "$REPO_PATH/hooks/dangerous-operation-validator.sh"
    ],
    "postToolUse": [
      "$REPO_PATH/hooks/agent-hierarchy-tracker.sh",
      "$REPO_PATH/hooks/auto-debug-suggester.sh",
      "$REPO_PATH/hooks/response-notifier.sh"
    ],
    "sessionStart": "$REPO_PATH/hooks/session-agent-context.sh",
    "subagentStop": "$REPO_PATH/hooks/agent-context-bridge.sh"
  }
}
EOF
```

## Step 6: Verify Installation

1. **Start a new Claude Code session**
2. **Check if hooks are loaded** - You should see the session context hook output at startup
3. **Test a command** - Run a bash command and check for notifications

### Testing Response Notifier

```bash
# This should trigger a notification after completion
sleep 6 && echo "Test complete"
```

## Troubleshooting

### Hooks Not Running

1. **Check file permissions**:

   ```bash
   ls -la hooks/*.sh
   # All files should have execute permission (x)
   ```

2. **Verify settings file location**:

   ```bash
   cat ~/.claude/settings.json
   # Should show your hooks configuration
   ```

3. **Check absolute paths**:

   ```bash
   # Test if hook file exists
   ls -la /path/to/claude-code-agents/hooks/response-notifier.sh
   ```

4. **Look for errors** in Claude Code output

### Notifications Not Working

#### macOS

- Ensure Terminal/Claude Code has notification permissions:
  - System Preferences → Notifications → Terminal/Your Terminal App
  - Enable notifications

#### Linux

- Install notification daemon if missing:

  ```bash
  # Ubuntu/Debian
  sudo apt-get install libnotify-bin

  # Fedora
  sudo dnf install libnotify
  ```

#### Configuration Options

You can customize the response notifier by setting environment variables:

```json
{
  "environmentVariables": {
    "CLAUDE_NOTIFIER_TTS": "false", // Disable text-to-speech
    "CLAUDE_NOTIFIER_SOUND": "true", // Enable notification sounds
    "CLAUDE_NOTIFIER_MIN_TIME": "10" // Only notify for tasks >10 seconds
  },
  "hooks": {
    "postToolUse": ["/path/to/claude-code-agents/hooks/response-notifier.sh"]
  }
}
```

## Hook Types Explained

- **preToolUse**: Runs before any tool is executed (e.g., before running a command)
- **postToolUse**: Runs after a tool completes (e.g., after a command finishes)
- **sessionStart**: Runs when a Claude Code session begins
- **subagentStop**: Runs when a sub-agent completes its task

## Security Note

Hooks run with your user permissions. Only use hooks from trusted sources and review the code before installation.

## Need Help?

If hooks still aren't working:

1. Check the [Claude Code documentation](https://docs.anthropic.com/en/docs/claude-code/settings)
2. Review the [hooks README](hooks/README.md) for detailed hook descriptions
3. Open an issue in this repository with:
   - Your operating system
   - Claude Code version
   - Settings file content (remove sensitive info)
   - Any error messages
