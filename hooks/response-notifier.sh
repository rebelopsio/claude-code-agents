#!/bin/bash
# PostToolUse hook: Desktop notification with text-to-speech when Claude is waiting
#
# This hook runs after tool execution completes
# It detects when Claude is likely waiting for user input and notifies the user
# Works on macOS (using osascript and say) and Linux (using notify-send and espeak)

# Configuration
ENABLE_TTS="${CLAUDE_NOTIFIER_TTS:-true}"
NOTIFICATION_SOUND="${CLAUDE_NOTIFIER_SOUND:-true}"
MIN_EXECUTION_TIME="${CLAUDE_NOTIFIER_MIN_TIME:-5}"  # Only notify for tasks longer than X seconds

# Track execution time
EXEC_START_FILE="/tmp/claude-exec-start-$$"
NOTIFICATION_LOG="$HOME/.claude-code/notifications.log"

# Ensure log directory exists
mkdir -p "$HOME/.claude-code"

# Function to detect OS
detect_os() {
    case "$(uname -s)" in
        Darwin*) echo "macos" ;;
        Linux*)  echo "linux" ;;
        *)       echo "unknown" ;;
    esac
}

# Function to send desktop notification
send_notification() {
    local title="$1"
    local message="$2"
    local os_type=$(detect_os)

    case "$os_type" in
        macos)
            # macOS notification using osascript
            osascript -e "display notification \"$message\" with title \"$title\" sound name \"Glass\""
            ;;
        linux)
            # Linux notification using notify-send
            if command -v notify-send &> /dev/null; then
                notify-send -u normal -t 10000 -i dialog-information "$title" "$message"
            fi
            ;;
    esac

    # Log notification
    echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] $title: $message" >> "$NOTIFICATION_LOG"
}

# Function to speak text
speak_text() {
    local text="$1"
    local os_type=$(detect_os)

    if [[ "$ENABLE_TTS" != "true" ]]; then
        return
    fi

    case "$os_type" in
        macos)
            # macOS text-to-speech
            say -v "Samantha" "$text" &
            ;;
        linux)
            # Linux text-to-speech using espeak
            if command -v espeak &> /dev/null; then
                espeak "$text" 2>/dev/null &
            fi
            ;;
    esac
}

# Function to determine if we should notify
should_notify() {
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

    case "$tool" in
        Bash)
            if [[ "$exit_code" -eq 0 ]]; then
                echo "Command completed successfully"
            else
                echo "Command failed with error"
            fi
            ;;
        Task)
            echo "Agent task completed"
            ;;
        Write|MultiEdit)
            echo "File modifications complete"
            ;;
        TodoWrite)
            echo "Todo list updated"
            ;;
        WebSearch|WebFetch)
            echo "Web search complete"
            ;;
        *)
            echo "Task complete"
            ;;
    esac
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

        # Add task description if available
        if [[ -n "$CLAUDE_TASK_DESCRIPTION" ]]; then
            title="Claude Code - ${CLAUDE_TASK_DESCRIPTION:0:30}"
        fi

        # Send notification
        send_notification "$title" "$message"

        # Speak notification
        if [[ "$ENABLE_TTS" == "true" ]]; then
            speak_text "$message. Your attention may be needed."
        fi

        # Clean up timing file
        rm -f "$EXEC_START_FILE"
    fi
}

# Run main function
main

exit 0
