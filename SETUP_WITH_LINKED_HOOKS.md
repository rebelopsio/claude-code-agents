# Setup Guide for Linked Hooks (~/.claude/hooks)

If you have the hooks directory linked to `~/.claude/hooks`, this guide helps you configure them.

## Step 1: Verify Your Link

```bash
# Check that the link exists and points to the right place
ls -la ~/.claude/hooks
# Should show: hooks -> /path/to/claude-code-agents/hooks
```

## Step 2: Make Hooks Executable

```bash
# Make all hooks executable
chmod +x ~/.claude/hooks/*.sh
```

## Step 3: Configure settings.json

Choose the configuration that fits your needs:

### Option A: Full Configuration (All Hooks)

```bash
# Copy the full example
cp hooks/settings.example.json ~/.claude/settings.json

# Edit if you need to adjust paths or settings
nano ~/.claude/settings.json
```

### Option B: Pushover Notifications

```bash
# Copy the Pushover example
cp hooks/settings.pushover.example.json ~/.claude/settings.json

# Edit and replace PLACEHOLDER values with your actual credentials
nano ~/.claude/settings.json
```

Replace:

- `REPLACE_WITH_YOUR_USER_KEY` → Your Pushover user key
- `REPLACE_WITH_YOUR_APP_TOKEN` → Your Pushover app token

### Option C: Minimal Setup (Basic Notifications)

```bash
# Copy the minimal example
cp hooks/settings.minimal.example.json ~/.claude/settings.json
```

## Step 4: Test the Configuration

1. **Start a new Claude Code session**

2. **Check if SessionStart hook runs** (if configured):

   - You should see agent hierarchy information at startup

3. **Test notifications**:

   ```bash
   # This should trigger a notification after 6 seconds
   sleep 6 && echo "Test complete"
   ```

4. **Test dangerous operation validator** (if configured):
   ```bash
   # This should be blocked
   rm -rf /
   ```

## Configuration Examples

### All Hooks Enabled

See `hooks/settings-example.json` for the complete configuration with all hooks.

### Essential Hooks Only

See `hooks/settings-minimal.json` for just notifications and safety validation.

### Custom Configuration

You can mix and match hooks based on your needs:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/response-notifier.sh"
          }
        ]
      },
      {
        "matcher": "Task",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/agent-hierarchy-tracker.sh"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/dangerous-operation-validator.sh"
          }
        ]
      }
    ]
  }
}
```

## Customizing Response Notifier

You can set environment variables in your settings to customize the notifier:

```json
{
  "environmentVariables": {
    "CLAUDE_NOTIFIER_TTS": "false", // Disable text-to-speech
    "CLAUDE_NOTIFIER_SOUND": "true", // Enable notification sounds
    "CLAUDE_NOTIFIER_MIN_TIME": "10" // Only notify for tasks >10 seconds
  },
  "hooks": {
    // ... your hooks configuration
  }
}
```

## Troubleshooting

### Hooks Not Running?

1. **Check permissions**:

   ```bash
   ls -la ~/.claude/hooks/*.sh
   # All should have execute permission (x)
   ```

2. **Verify settings file**:

   ```bash
   cat ~/.claude/settings.json | jq .hooks
   # Should show your hooks configuration
   ```

3. **Check the symbolic link**:
   ```bash
   ls -la ~/.claude/hooks
   # Should point to your claude-code-agents/hooks directory
   ```

### Notifications Not Appearing?

**macOS**:

- System Preferences → Notifications → Terminal (or your terminal app)
- Enable "Allow Notifications"

**Linux**:

```bash
# Install notification daemon if missing
sudo apt-get install libnotify-bin  # Ubuntu/Debian
sudo dnf install libnotify          # Fedora
```

## Quick Test Commands

```bash
# Test notification (should notify after 6 seconds)
sleep 6 && echo "Done"

# Test dangerous operation validator (should be blocked)
chmod 777 /etc/passwd

# Test agent suggestions (if using Task tool)
# When you use Task tool, agent-selector should suggest agents

# Check if hooks are logging
ls -la ~/.claude-code/
# Should see agent-usage.log, notifications.log, etc.
```

## Available Hooks

| Hook                             | Trigger      | Purpose                                       |
| -------------------------------- | ------------ | --------------------------------------------- |
| response-notifier.sh             | PostToolUse  | Desktop notifications when Claude needs input |
| dangerous-operation-validator.sh | PreToolUse   | Blocks dangerous commands                     |
| agent-selector.sh                | PreToolUse   | Suggests appropriate agents                   |
| agent-hierarchy-tracker.sh       | PostToolUse  | Tracks agent usage patterns                   |
| auto-debug-suggester.sh          | PostToolUse  | Suggests debuggers on errors                  |
| session-agent-context.sh         | SessionStart | Shows agent hierarchy at startup              |
| agent-context-bridge.sh          | SubagentStop | Bridges context between agents                |
| web-resource-validator.sh        | PostToolUse  | Validates web resources                       |
| typescript-validator.sh          | PostToolUse  | Validates TypeScript files                    |
| test-runner-validator.sh         | PostToolUse  | Suggests running tests                        |

Choose the hooks that match your workflow!
