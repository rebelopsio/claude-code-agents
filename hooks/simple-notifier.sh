#!/bin/bash
# Simple notification hook for Claude Code

# Log all environment variables for debugging
echo "=== Hook Triggered at $(date) ===" >> /tmp/claude-hook-debug.log
env | grep CLAUDE >> /tmp/claude-hook-debug.log 2>&1 || echo "No CLAUDE vars found" >> /tmp/claude-hook-debug.log

# Send Pushover notification if configured
if [[ -n "${PUSHOVER_USER_KEY}" ]] && [[ -n "${PUSHOVER_APP_TOKEN}" ]]; then
    curl -s -X POST \
        --form-string "token=${PUSHOVER_APP_TOKEN}" \
        --form-string "user=${PUSHOVER_USER_KEY}" \
        --form-string "title=Claude Code Activity" \
        --form-string "message=Tool execution completed" \
        https://api.pushover.net/1/messages.json >> /tmp/claude-hook-debug.log 2>&1
fi

exit 0
