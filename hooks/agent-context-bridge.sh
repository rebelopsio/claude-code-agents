#!/bin/bash
# SubagentStop hook: Bridge context between agent invocations in a chain

# This hook runs when a subagent completes
# It extracts key information and prepares context for the next agent

CONTEXT_FILE="$HOME/.claude-code/agent-context.json"
CHAIN_FILE="$HOME/.claude-code/agent-chain.log"

# Ensure directory exists
mkdir -p "$HOME/.claude-code"

# Function to extract key findings from agent output
extract_key_findings() {
    local output="$1"
    local agent="$2"

    # Initialize context file if it doesn't exist
    if [[ ! -f "$CONTEXT_FILE" ]]; then
        echo '{}' > "$CONTEXT_FILE"
    fi

    # Extract based on agent type
    case "$agent" in
        *"architect"*)
            # Extract design decisions
            if [[ "$output" == *"structure"* ]] || [[ "$output" == *"pattern"* ]]; then
                jq --arg agent "$agent" --arg finding "Architectural pattern defined" \
                   '.[$agent] = {"type": "architecture", "finding": $finding}' \
                   "$CONTEXT_FILE" > "$CONTEXT_FILE.tmp" && mv "$CONTEXT_FILE.tmp" "$CONTEXT_FILE"
            fi
            ;;
        *"engineer"*)
            # Extract implementation details
            if [[ "$output" == *"implemented"* ]] || [[ "$output" == *"created"* ]]; then
                jq --arg agent "$agent" --arg finding "Implementation completed" \
                   '.[$agent] = {"type": "implementation", "finding": $finding}' \
                   "$CONTEXT_FILE" > "$CONTEXT_FILE.tmp" && mv "$CONTEXT_FILE.tmp" "$CONTEXT_FILE"
            fi
            ;;
        *"test"*)
            # Extract test results
            if [[ "$output" == *"passed"* ]] || [[ "$output" == *"coverage"* ]]; then
                jq --arg agent "$agent" --arg finding "Tests executed" \
                   '.[$agent] = {"type": "testing", "finding": $finding}' \
                   "$CONTEXT_FILE" > "$CONTEXT_FILE.tmp" && mv "$CONTEXT_FILE.tmp" "$CONTEXT_FILE"
            fi
            ;;
        *"debugger"*)
            # Extract debugging findings
            if [[ "$output" == *"fixed"* ]] || [[ "$output" == *"resolved"* ]]; then
                jq --arg agent "$agent" --arg finding "Issue resolved" \
                   '.[$agent] = {"type": "debugging", "finding": $finding}' \
                   "$CONTEXT_FILE" > "$CONTEXT_FILE.tmp" && mv "$CONTEXT_FILE.tmp" "$CONTEXT_FILE"
            fi
            ;;
    esac
}

# Function to track agent chains
track_agent_chain() {
    local agent="$1"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Log to chain file
    echo "[$timestamp] $agent" >> "$CHAIN_FILE"

    # Detect common chains
    if [[ -f "$CHAIN_FILE" ]]; then
        local chain=$(tail -n 5 "$CHAIN_FILE" | grep -o '[a-z-]*' | tr '\n' ' → ')

        # Check for complete hierarchy chains
        if [[ "$chain" == *"architect"*"engineer"*"test"* ]]; then
            echo "✅ Complete development chain detected: Design → Implementation → Testing"
        fi

        if [[ "$chain" == *"test"*"debugger"* ]]; then
            echo "🔧 Test-Debug cycle detected: Testing → Debugging"
        fi
    fi
}

# Function to suggest next agent based on context
suggest_next_agent() {
    local current_agent="$1"
    local context=$(cat "$CONTEXT_FILE" 2>/dev/null || echo '{}')

    # Suggest based on current agent and context
    case "$current_agent" in
        *"architect"*)
            echo "📍 Next in chain: Consider an engineer agent for implementation"
            ;;
        *"engineer"*)
            if [[ "$context" != *"testing"* ]]; then
                echo "📍 Next in chain: Consider a test engineer for validation"
            fi
            ;;
        *"test-engineer"*)
            if [[ "$CLAUDE_TOOL_RESULT" == *"fail"* ]]; then
                echo "📍 Next in chain: Consider a debugger for failing tests"
            fi
            ;;
        *"debugger"*)
            echo "📍 Next in chain: Consider re-running tests to verify fixes"
            ;;
    esac
}

# Function to maintain context window
maintain_context_window() {
    # Keep only last 10 chain entries
    if [[ -f "$CHAIN_FILE" ]]; then
        local line_count=$(wc -l < "$CHAIN_FILE")
        if (( line_count > 10 )); then
            tail -n 10 "$CHAIN_FILE" > "$CHAIN_FILE.tmp" && mv "$CHAIN_FILE.tmp" "$CHAIN_FILE"
        fi
    fi

    # Clear context after complete chain
    local context_size=$(jq 'length' "$CONTEXT_FILE" 2>/dev/null || echo 0)
    if (( context_size > 5 )); then
        echo "🔄 Resetting agent context after complete chain"
        echo '{}' > "$CONTEXT_FILE"
    fi
}

# Main logic
if [[ -n "$CLAUDE_SUBAGENT_TYPE" ]]; then
    # Extract and store findings
    extract_key_findings "$CLAUDE_TOOL_RESULT" "$CLAUDE_SUBAGENT_TYPE"

    # Track the chain
    track_agent_chain "$CLAUDE_SUBAGENT_TYPE"

    # Suggest next agent
    suggest_next_agent "$CLAUDE_SUBAGENT_TYPE"

    # Maintain context window
    maintain_context_window

    # Show current chain status
    if [[ -f "$CHAIN_FILE" ]]; then
        echo "🔗 Current agent chain:"
        tail -n 3 "$CHAIN_FILE" | while read line; do
            echo "   $line"
        done
    fi
fi

exit 0
