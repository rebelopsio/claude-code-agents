#!/bin/bash
# PostToolUse hook: Pushover push notification when Claude needs input
#
# This hook sends push notifications via Pushover when tool execution completes
# Can accept API credentials as arguments or environment variables
#
# Usage:
#   pushover-notifier.sh [user_key] [app_token] [enabled] [min_time] [priority] [sound]
#
# Arguments (all optional, falls back to environment variables):
#   $1: user_key  - Pushover user key
#   $2: app_token - Pushover application API token
#   $3: enabled   - true/false to enable/disable (default: true)
#   $4: min_time  - Minimum execution time in seconds (default: 5)
#   $5: priority  - -2=silent, -1=quiet, 0=normal, 1=high, 2=emergency (default: 0)
#   $6: sound     - Notification sound (optional)
#
# Environment variables (used if arguments not provided):
#   PUSHOVER_USER_KEY, PUSHOVER_APP_TOKEN, PUSHOVER_ENABLED,
#   PUSHOVER_MIN_TIME, PUSHOVER_PRIORITY, PUSHOVER_SOUND

# Parse arguments or fall back to environment variables
USER_KEY="${1:-${PUSHOVER_USER_KEY:-}}"
APP_TOKEN="${2:-${PUSHOVER_APP_TOKEN:-}}"
ENABLED="${3:-${PUSHOVER_ENABLED:-true}}"
MIN_EXECUTION_TIME="${4:-${PUSHOVER_MIN_TIME:-5}}"
PRIORITY="${5:-${PUSHOVER_PRIORITY:-0}}"
SOUND="${6:-${PUSHOVER_SOUND:-}}"

# Track execution time
EXEC_START_FILE="/tmp/claude-pushover-start-$$"
NOTIFICATION_LOG="$HOME/.claude-code/pushover-notifications.log"

# Ensure log directory exists
mkdir -p "$HOME/.claude-code"

# Function to check if Pushover is configured
is_configured() {
    if [[ -z "$USER_KEY" ]] || [[ -z "$APP_TOKEN" ]]; then
        # Log configuration issue once
        if [[ ! -f "$HOME/.claude-code/.pushover-warning-shown" ]]; then
            echo "⚠️ Pushover not configured. Set PUSHOVER_USER_KEY and PUSHOVER_APP_TOKEN in your environment." >&2
            echo "  Add to ~/.claude/settings.json:" >&2
            echo '  "environmentVariables": {' >&2
            echo '    "PUSHOVER_USER_KEY": "your-user-key",' >&2
            echo '    "PUSHOVER_APP_TOKEN": "your-app-token"' >&2
            echo '  }' >&2
            touch "$HOME/.claude-code/.pushover-warning-shown"
        fi
        return 1
    fi
    return 0
}

# Function to send Pushover notification
send_pushover() {
    local title="$1"
    local message="$2"
    local priority="${3:-$PRIORITY}"

    # Build the API request
    local data="token=$APP_TOKEN&user=$USER_KEY&title=$(echo -n "$title" | sed 's/ /%20/g')&message=$(echo -n "$message" | sed 's/ /%20/g')&priority=$priority"

    # Add sound if configured
    if [[ -n "$SOUND" ]]; then
        data="$data&sound=$SOUND"
    fi

    # Add HTML formatting
    data="$data&html=1"

    # Send the notification
    local response=$(curl -s -X POST \
        --form-string "token=$APP_TOKEN" \
        --form-string "user=$USER_KEY" \
        --form-string "title=$title" \
        --form-string "message=$message" \
        --form-string "priority=$priority" \
        --form-string "html=1" \
        ${SOUND:+--form-string "sound=$SOUND"} \
        https://api.pushover.net/1/messages.json 2>/dev/null)

    # Log the notification
    echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] $title: $message (Priority: $priority)" >> "$NOTIFICATION_LOG"

    # Check for success
    if [[ "$response" == *'"status":1'* ]]; then
        return 0
    else
        echo "Pushover notification failed: $response" >> "$NOTIFICATION_LOG"
        return 1
    fi
}

# Function to determine if we should notify
should_notify() {
    # Check if enabled
    if [[ "$ENABLED" != "true" ]]; then
        return 1
    fi

    # Check if configured
    if ! is_configured; then
        return 1
    fi

    # Check if this is a significant tool completion
    case "$CLAUDE_TOOL_NAME" in
        Bash|Task|MultiEdit|Write)
            # These tools often indicate task completion
            return 0
            ;;
        Read|Grep|Glob|LS)
            # These are usually quick lookups, don't notify
            return 1
            ;;
        *)
            # For other tools, check execution time
            if [[ -f "$EXEC_START_FILE" ]]; then
                local start_time=$(cat "$EXEC_START_FILE")
                local end_time=$(date +%s)
                local duration=$((end_time - start_time))

                if [[ $duration -ge $MIN_EXECUTION_TIME ]]; then
                    return 0
                fi
            fi
            return 1
            ;;
    esac
}

# Function to generate contextual message
generate_message() {
    local tool="$CLAUDE_TOOL_NAME"
    local exit_code="${CLAUDE_TOOL_EXIT_CODE:-0}"
    local task="${CLAUDE_TASK_DESCRIPTION:-}"

    # Build message based on tool and result
    local message=""
    case "$tool" in
        Bash)
            if [[ "$exit_code" -eq 0 ]]; then
                message="✅ Command completed successfully"
            else
                message="❌ Command failed with exit code $exit_code"
            fi
            ;;
        Task)
            message="🤖 Agent task completed"
            ;;
        Write|MultiEdit)
            message="📝 File modifications complete"
            ;;
        TodoWrite)
            message="☑️ Todo list updated"
            ;;
        WebSearch|WebFetch)
            message="🔍 Web search complete"
            ;;
        *)
            message="✨ Task complete"
            ;;
    esac

    # Add task description if available
    if [[ -n "$task" ]]; then
        message="$message<br><i>${task:0:100}</i>"
    fi

    # Add duration if available
    if [[ -f "$EXEC_START_FILE" ]]; then
        local start_time=$(cat "$EXEC_START_FILE")
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))

        if [[ $duration -gt 60 ]]; then
            local minutes=$((duration / 60))
            local seconds=$((duration % 60))
            message="$message<br><small>Duration: ${minutes}m ${seconds}s</small>"
        else
            message="$message<br><small>Duration: ${duration}s</small>"
        fi
    fi

    echo "$message"
}

# Function to detect if waiting for response
detect_waiting_state() {
    # Analyze tool result for completion indicators
    local result="$CLAUDE_TOOL_RESULT"

    # Check for completion patterns
    if [[ "$result" == *"success"* ]] || \
       [[ "$result" == *"complete"* ]] || \
       [[ "$result" == *"finished"* ]] || \
       [[ "$result" == *"done"* ]] || \
       [[ "$CLAUDE_TOOL_EXIT_CODE" -eq 0 && "$CLAUDE_TOOL_NAME" == "Bash" ]]; then
        return 0  # Likely completed, might be waiting
    fi

    # Check for error patterns that might need user attention
    if [[ "$result" == *"error"* ]] || \
       [[ "$result" == *"failed"* ]] || \
       [[ "$CLAUDE_TOOL_EXIT_CODE" -ne 0 ]]; then
        return 0  # Error occurred, user attention needed
    fi

    return 1  # Still processing
}

# Function to determine priority based on context
get_priority() {
    local tool="$CLAUDE_TOOL_NAME"
    local exit_code="${CLAUDE_TOOL_EXIT_CODE:-0}"

    # Emergency priority for critical failures
    if [[ "$exit_code" -ne 0 ]] && [[ "$tool" == "Bash" ]]; then
        local result="$CLAUDE_TOOL_RESULT"
        if [[ "$result" == *"CRITICAL"* ]] || [[ "$result" == *"FATAL"* ]]; then
            echo "2"  # Emergency
            return
        fi
    fi

    # High priority for errors
    if [[ "$exit_code" -ne 0 ]]; then
        echo "1"  # High priority
        return
    fi

    # Default priority
    echo "$PRIORITY"
}

# Main logic
main() {
    # Record start time on PreToolUse
    if [[ -z "$CLAUDE_TOOL_RESULT" ]]; then
        echo "$(date +%s)" > "$EXEC_START_FILE"
        exit 0
    fi

    # Check if we should notify
    if should_notify && detect_waiting_state; then
        local message=$(generate_message)
        local title="Claude Code"
        local priority=$(get_priority)

        # Customize title based on priority
        case "$priority" in
            2)
                title="⚠️ Claude Code - URGENT"
                ;;
            1)
                title="❗ Claude Code - Error"
                ;;
            -1|-2)
                title="Claude Code"
                ;;
            *)
                title="Claude Code - Ready"
                ;;
        esac

        # Send Pushover notification
        send_pushover "$title" "$message" "$priority"

        # Clean up timing file
        rm -f "$EXEC_START_FILE"
    fi
}

# Run main function
main

exit 0
