#!/bin/bash
# PostToolUse hook: Track agent delegation patterns and hierarchy usage

# This hook runs after the Task tool completes
# It logs agent usage patterns for analysis and optimization

LOG_FILE="$HOME/.claude-code/agent-usage.log"
STATS_FILE="$HOME/.claude-code/agent-stats.json"

# Ensure log directory exists
mkdir -p "$HOME/.claude-code"

# Function to log agent usage
log_agent_usage() {
    local agent_type="$1"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Log to file
    echo "[$timestamp] Agent: $agent_type, Task: $CLAUDE_TASK_DESCRIPTION" >> "$LOG_FILE"

    # Update statistics (simple counter)
    if [[ -f "$STATS_FILE" ]]; then
        # Increment counter for this agent
        jq --arg agent "$agent_type" '.[$agent] += 1' "$STATS_FILE" > "$STATS_FILE.tmp" && mv "$STATS_FILE.tmp" "$STATS_FILE"
    else
        # Initialize stats file
        echo "{\"$agent_type\": 1}" > "$STATS_FILE"
    fi
}

# Function to detect delegation chains
detect_delegation() {
    local result="$1"

    # Check for delegation patterns in the result
    if [[ "$result" == *"delegating to"* ]] || [[ "$result" == *"invoking"* ]]; then
        echo "🔄 Delegation detected in agent workflow"

        # Extract delegation chain if possible
        if [[ "$result" == *"architect"* && "$result" == *"engineer"* ]]; then
            echo "   Hierarchy: architect → engineer → test-engineer"
        fi
    fi
}

# Check if this was a Task tool invocation
if [[ "$CLAUDE_TOOL_NAME" == "Task" ]]; then
    # Extract agent type from the result if available
    if [[ -n "$CLAUDE_SUBAGENT_TYPE" ]]; then
        log_agent_usage "$CLAUDE_SUBAGENT_TYPE"

        # Analyze delegation patterns
        detect_delegation "$CLAUDE_TOOL_RESULT"

        # Show most used agents periodically (every 10 invocations)
        usage_count=$(wc -l < "$LOG_FILE" 2>/dev/null || echo 0)
        if (( usage_count % 10 == 0 )) && (( usage_count > 0 )); then
            echo "📊 Top agents by usage:"
            jq -r 'to_entries | sort_by(.value) | reverse | .[0:5] | .[] | "   \(.key): \(.value) invocations"' "$STATS_FILE" 2>/dev/null
        fi
    fi
fi

exit 0
