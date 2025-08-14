#!/bin/bash
# Setup script for Claude Code hooks
# This script helps configure hooks with the correct paths

set -e

echo "🚀 Claude Code Hooks Setup"
echo "=========================="
echo

# Get the absolute path to this repository
REPO_PATH="$(cd "$(dirname "$0")" && pwd)"
echo "📁 Repository path: $REPO_PATH"

# Check if hooks exist
if [ ! -d "$REPO_PATH/hooks" ]; then
    echo "❌ Error: hooks directory not found at $REPO_PATH/hooks"
    exit 1
fi

# Make hooks executable
echo "🔧 Making hooks executable..."
chmod +x "$REPO_PATH"/hooks/*.sh

# Ask user for settings location
echo
echo "Where would you like to install the hooks configuration?"
echo "1) User settings (~/.claude/settings.json) - Applies to all projects"
echo "2) Current project settings (.claude/settings.json) - Shared with team"
echo "3) Local project settings (.claude/settings.local.json) - Personal only"
echo "4) Custom location"
echo
read -p "Choose option (1-4): " choice

case $choice in
    1)
        SETTINGS_PATH="$HOME/.claude/settings.json"
        SETTINGS_DIR="$HOME/.claude"
        ;;
    2)
        SETTINGS_PATH=".claude/settings.json"
        SETTINGS_DIR=".claude"
        ;;
    3)
        SETTINGS_PATH=".claude/settings.local.json"
        SETTINGS_DIR=".claude"
        ;;
    4)
        read -p "Enter custom path: " SETTINGS_PATH
        SETTINGS_DIR="$(dirname "$SETTINGS_PATH")"
        ;;
    *)
        echo "Invalid option"
        exit 1
        ;;
esac

# Create directory if it doesn't exist
mkdir -p "$SETTINGS_DIR"

# Check if settings file exists
if [ -f "$SETTINGS_PATH" ]; then
    echo
    echo "⚠️  Warning: $SETTINGS_PATH already exists"
    echo "Do you want to:"
    echo "1) Backup and replace"
    echo "2) Merge with existing (manual edit required)"
    echo "3) Cancel"
    read -p "Choose option (1-3): " backup_choice

    case $backup_choice in
        1)
            BACKUP_PATH="${SETTINGS_PATH}.backup.$(date +%Y%m%d_%H%M%S)"
            cp "$SETTINGS_PATH" "$BACKUP_PATH"
            echo "✅ Backup created: $BACKUP_PATH"
            ;;
        2)
            echo
            echo "📝 Add the following configuration to your $SETTINGS_PATH file:"
            echo
            ;;
        3)
            echo "Cancelled"
            exit 0
            ;;
        *)
            echo "Invalid option"
            exit 1
            ;;
    esac
fi

# Ask which hooks to install
echo
echo "Which hooks would you like to install?"
echo "1) All hooks (recommended)"
echo "2) Just notifications (response-notifier only)"
echo "3) Safety hooks only (dangerous-operation-validator)"
echo "4) Custom selection"
read -p "Choose option (1-4): " hooks_choice

# Generate the configuration
cat > /tmp/claude-hooks-config.json << EOF
{
  "hooks": {
EOF

case $hooks_choice in
    1)
        # All hooks
        cat >> /tmp/claude-hooks-config.json << EOF
    "PreToolUse": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "$REPO_PATH/hooks/agent-selector.sh"
          },
          {
            "type": "command",
            "command": "$REPO_PATH/hooks/dangerous-operation-validator.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "$REPO_PATH/hooks/agent-hierarchy-tracker.sh"
          },
          {
            "type": "command",
            "command": "$REPO_PATH/hooks/auto-debug-suggester.sh"
          },
          {
            "type": "command",
            "command": "$REPO_PATH/hooks/response-notifier.sh"
          },
          {
            "type": "command",
            "command": "$REPO_PATH/hooks/web-resource-validator.sh"
          },
          {
            "type": "command",
            "command": "$REPO_PATH/hooks/typescript-validator.sh"
          },
          {
            "type": "command",
            "command": "$REPO_PATH/hooks/test-runner-validator.sh"
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "$REPO_PATH/hooks/session-agent-context.sh"
          }
        ]
      }
    ],
    "SubagentStop": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "$REPO_PATH/hooks/agent-context-bridge.sh"
          }
        ]
      }
    ]
EOF
        ;;
    2)
        # Just notifications
        cat >> /tmp/claude-hooks-config.json << EOF
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "$REPO_PATH/hooks/response-notifier.sh",
            "timeout": 5
          }
        ]
      }
    ]
EOF
        ;;
    3)
        # Safety only
        cat >> /tmp/claude-hooks-config.json << EOF
    "PreToolUse": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "$REPO_PATH/hooks/dangerous-operation-validator.sh"
          }
        ]
      }
    ]
EOF
        ;;
    4)
        echo "Custom selection not yet implemented. Please edit the configuration manually."
        exit 0
        ;;
esac

# Close the JSON
cat >> /tmp/claude-hooks-config.json << EOF
  }
}
EOF

# Write or display the configuration
if [ "$backup_choice" == "2" ] && [ -f "$SETTINGS_PATH" ]; then
    echo "----------------------------------------"
    cat /tmp/claude-hooks-config.json
    echo "----------------------------------------"
    echo
    echo "Please manually merge this configuration with your existing settings."
else
    cp /tmp/claude-hooks-config.json "$SETTINGS_PATH"
    echo
    echo "✅ Configuration written to: $SETTINGS_PATH"
fi

# Clean up
rm -f /tmp/claude-hooks-config.json

# Test hooks
echo
echo "🧪 Testing hook accessibility..."
if [ -x "$REPO_PATH/hooks/response-notifier.sh" ]; then
    echo "✅ Hooks are executable"
else
    echo "❌ Hooks are not executable. Running chmod..."
    chmod +x "$REPO_PATH"/hooks/*.sh
fi

# Platform-specific instructions
echo
echo "📋 Platform-specific setup:"
case "$(uname -s)" in
    Darwin*)
        echo "🍎 macOS detected"
        echo "   - Ensure Terminal has notification permissions in System Preferences"
        echo "   - Text-to-speech should work automatically"
        ;;
    Linux*)
        echo "🐧 Linux detected"
        echo "   - Ensure libnotify-bin is installed: sudo apt-get install libnotify-bin"
        echo "   - For text-to-speech, install espeak: sudo apt-get install espeak"
        ;;
    *)
        echo "⚠️  Unknown platform - manual configuration may be needed"
        ;;
esac

echo
echo "🎉 Setup complete!"
echo
echo "Next steps:"
echo "1. Start a new Claude Code session"
echo "2. The session-agent-context hook should display on startup if configured"
echo "3. Run a command like 'sleep 6 && echo done' to test notifications"
echo
echo "If hooks don't work, check:"
echo "- The settings file at: $SETTINGS_PATH"
echo "- Hook permissions: ls -la $REPO_PATH/hooks/"
echo "- Claude Code documentation: https://docs.anthropic.com/en/docs/claude-code/hooks"
echo
echo "For more information, see:"
echo "- $REPO_PATH/hooks/README.md"
echo "- $REPO_PATH/INSTALL_HOOKS.md"
