#!/bin/bash
# PreToolUse hook: Automatically suggest appropriate agents based on task patterns

# This hook runs before the Task tool is invoked
# It analyzes the task description and suggests the most appropriate agent

# Set non-blocking mode to prevent hanging
exec < /dev/null

# Exit immediately if not a Task tool
if [[ "$CLAUDE_TOOL_NAME" != "Task" ]]; then
    exit 0
fi

TASK_PROMPT="$1"

# Function to suggest agent based on keywords
suggest_agent() {
    local prompt="$1"

    # Convert to lowercase for matching
    prompt_lower=$(echo "$prompt" | tr '[:upper:]' '[:lower:]')

    # Architecture and design patterns
    if [[ "$prompt_lower" == *"architect"* ]] || [[ "$prompt_lower" == *"design"* ]] || [[ "$prompt_lower" == *"structure"* ]]; then
        echo "💡 Consider using architecture specialists: go-architect, rust-systems-engineer, nextjs-architect"
    fi

    # Debugging patterns
    if [[ "$prompt_lower" == *"debug"* ]] || [[ "$prompt_lower" == *"error"* ]] || [[ "$prompt_lower" == *"fix"* ]]; then
        echo "🔍 Consider language-specific debuggers: go-debugger, rust-debugger, python-debugger, javascript-debugger"
    fi

    # Testing patterns
    if [[ "$prompt_lower" == *"test"* ]] || [[ "$prompt_lower" == *"coverage"* ]] || [[ "$prompt_lower" == *"spec"* ]]; then
        echo "🧪 Consider test engineers: go-test-engineer, rust-test-engineer, python-test-engineer, react-nextjs-test-engineer"
    fi

    # Full-stack patterns
    if [[ "$prompt_lower" == *"full-stack"* ]] || [[ "$prompt_lower" == *"frontend"* && "$prompt_lower" == *"backend"* ]]; then
        echo "🌐 Consider full-stack agents: fullstack-nextjs-go, fullstack-nuxtjs-go"
    fi

    # Infrastructure patterns
    if [[ "$prompt_lower" == *"deploy"* ]] || [[ "$prompt_lower" == *"kubernetes"* ]] || [[ "$prompt_lower" == *"docker"* ]]; then
        echo "☁️ Consider infrastructure agents: k8s-deployment-engineer, container-specialist, terraform-architect"
    fi

    # Performance patterns
    if [[ "$prompt_lower" == *"performance"* ]] || [[ "$prompt_lower" == *"optimize"* ]] || [[ "$prompt_lower" == *"slow"* ]]; then
        echo "⚡ Consider optimization specialists: go-performance-optimizer, prometheus-engineer"
    fi
}

# Run the suggestion function
suggest_agent "$TASK_PROMPT"

# Always allow the tool to proceed
exit 0
