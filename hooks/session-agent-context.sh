#!/bin/bash
# SessionStart hook: Load agent hierarchy and suggest workflow patterns

# This hook runs at the start of each session
# It provides context about available agents and their relationships

echo "🤖 Claude Code Agents System Initialized"
echo ""
echo "📋 Agent Hierarchy Pattern:"
echo "   Architects → Engineers → Test Engineers → Debuggers"
echo ""
echo "🎯 Quick Agent Selection Guide:"
echo "   • Design/Architecture: go-architect, rust-systems-engineer, nextjs-architect"
echo "   • Implementation: go-engineer, python-automation-engineer, react-component-engineer"
echo "   • Testing: go-test-engineer, python-test-engineer, vue-nuxt-test-engineer"
echo "   • Debugging: go-debugger, rust-debugger, javascript-debugger, python-debugger"
echo "   • Full-Stack: fullstack-nextjs-go, fullstack-nuxtjs-go"
echo ""

# Check for recent agent usage patterns
STATS_FILE="$HOME/.claude-code/agent-stats.json"
if [[ -f "$STATS_FILE" ]]; then
    echo "📊 Your most used agents:"
    jq -r 'to_entries | sort_by(.value) | reverse | .[0:3] | .[] | "   • \(.key): \(.value) uses"' "$STATS_FILE" 2>/dev/null
    echo ""
fi

# Suggest workflow based on current directory
if [[ -f "go.mod" ]]; then
    echo "🔍 Detected Go project - Available specialists:"
    echo "   go-architect → go-engineer → go-test-engineer → go-debugger"
elif [[ -f "package.json" ]]; then
    if grep -q "next" package.json 2>/dev/null; then
        echo "🔍 Detected Next.js project - Available specialists:"
        echo "   nextjs-architect → react-component-engineer → react-nextjs-test-engineer → nextjs-debugger"
    elif grep -q "nuxt" package.json 2>/dev/null; then
        echo "🔍 Detected Nuxt.js project - Available specialists:"
        echo "   nuxt-developer → vue-developer → vue-nuxt-test-engineer → nuxtjs-debugger"
    fi
elif [[ -f "Cargo.toml" ]]; then
    echo "🔍 Detected Rust project - Available specialists:"
    echo "   rust-systems-engineer → rust-cli-developer → rust-test-engineer → rust-debugger"
elif [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]]; then
    echo "🔍 Detected Python project - Available specialists:"
    echo "   python-automation-engineer → python-data-processor → python-test-engineer → python-debugger"
fi

echo ""
echo "💡 Tip: Agents automatically delegate to appropriate specialists based on task complexity"

exit 0
