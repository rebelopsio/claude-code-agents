#!/bin/bash
# PostToolUse hook: Automatically run tests after code changes

# This hook runs after code modifications
# It suggests or runs relevant tests based on what was changed

TOOL_NAME="$CLAUDE_TOOL_NAME"
MODIFIED_FILE="$1"
TEST_LOG="$HOME/.claude-code/test-runs.log"

# Ensure directory exists
mkdir -p "$HOME/.claude-code"

# Function to detect test framework
detect_test_framework() {
    if [[ -f "package.json" ]]; then
        # Check for test frameworks in order of preference
        if grep -q "\"jest\"" package.json 2>/dev/null; then
            echo "jest"
        elif grep -q "\"vitest\"" package.json 2>/dev/null; then
            echo "vitest"
        elif grep -q "\"mocha\"" package.json 2>/dev/null; then
            echo "mocha"
        elif grep -q "\"@testing-library\"" package.json 2>/dev/null; then
            echo "jest"  # Usually used with Jest
        elif grep -q "\"test\":" package.json 2>/dev/null; then
            echo "npm"  # Generic npm test
        fi
    elif [[ -f "go.mod" ]]; then
        echo "go"
    elif [[ -f "Cargo.toml" ]]; then
        echo "rust"
    elif [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]]; then
        echo "python"
    fi
}

# Function to find related test files
find_test_files() {
    local source_file="$1"
    local test_files=""

    # Get base name without extension
    local base_name=$(basename "$source_file" | sed -E 's/\.(ts|tsx|js|jsx|go|rs|py)$//')
    local dir_name=$(dirname "$source_file")

    # Common test file patterns
    local patterns=(
        "${base_name}.test"
        "${base_name}.spec"
        "${base_name}_test"
        "test_${base_name}"
        "${base_name}.test"
        "${base_name}-test"
    )

    # Common test directories
    local test_dirs=(
        "__tests__"
        "tests"
        "test"
        ".test"
        "../__tests__"
        "../tests"
        "../test"
    )

    # Look for test files
    for pattern in "${patterns[@]}"; do
        # Same directory
        for ext in .ts .tsx .js .jsx .go .rs .py; do
            if [[ -f "$dir_name/${pattern}${ext}" ]]; then
                test_files="$test_files $dir_name/${pattern}${ext}"
            fi
        done

        # Test directories
        for test_dir in "${test_dirs[@]}"; do
            for ext in .ts .tsx .js .jsx .go .rs .py; do
                if [[ -f "$dir_name/$test_dir/${pattern}${ext}" ]]; then
                    test_files="$test_files $dir_name/$test_dir/${pattern}${ext}"
                fi
            done
        done
    done

    echo "$test_files"
}

# Function to suggest test command
suggest_test_command() {
    local file="$1"
    local framework="$2"

    case "$framework" in
        "jest")
            echo "npm test -- $file --coverage"
            ;;
        "vitest")
            echo "npm test -- $file"
            ;;
        "mocha")
            echo "npm test -- $file"
            ;;
        "go")
            local package_path=$(dirname "$file")
            echo "go test ./$package_path -v"
            ;;
        "rust")
            echo "cargo test"
            ;;
        "python")
            if command -v pytest &> /dev/null; then
                echo "pytest $file -v"
            else
                echo "python -m pytest $file -v"
            fi
            ;;
        "npm")
            echo "npm test"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Function to check if file is a test file
is_test_file() {
    local file="$1"

    if [[ "$file" =~ \.(test|spec|_test)\.(ts|tsx|js|jsx)$ ]] || \
       [[ "$file" =~ _test\.go$ ]] || \
       [[ "$file" =~ test_.*\.py$ ]] || \
       [[ "$file" =~ .*_test\.rs$ ]] || \
       [[ "$file" =~ \/__tests__\/ ]] || \
       [[ "$file" =~ \/tests?\/ ]]; then
        return 0
    fi

    return 1
}

# Function to validate test coverage
check_test_coverage() {
    local file="$1"
    local framework="$2"

    # Check if coverage reporting is available
    case "$framework" in
        "jest"|"vitest")
            if [[ -f "coverage/coverage-summary.json" ]]; then
                echo "📊 Coverage report available: coverage/lcov-report/index.html"
            fi
            ;;
        "go")
            echo "💡 Run with coverage: go test -cover ./$package_path"
            ;;
        "rust")
            echo "💡 Run with coverage: cargo tarpaulin"
            ;;
        "python")
            echo "💡 Run with coverage: pytest --cov=$file"
            ;;
    esac
}

# Function to log test runs
log_test_run() {
    local file="$1"
    local framework="$2"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    echo "[$timestamp] File: $file, Framework: $framework" >> "$TEST_LOG"
}

# Main validation logic
case "$TOOL_NAME" in
    "Write"|"Edit"|"MultiEdit")
        if [[ -n "$MODIFIED_FILE" ]] && [[ -f "$MODIFIED_FILE" ]]; then
            # Detect test framework
            framework=$(detect_test_framework)

            if [[ -n "$framework" ]]; then
                echo "🧪 Test Validation"
                echo "━━━━━━━━━━━━━━━━"

                # Check if modified file is a test
                if is_test_file "$MODIFIED_FILE"; then
                    echo "✅ Test file modified: $MODIFIED_FILE"
                    echo ""
                    echo "📝 Run this test:"

                    test_cmd=$(suggest_test_command "$MODIFIED_FILE" "$framework")
                    if [[ -n "$test_cmd" ]]; then
                        echo "   $test_cmd"
                    fi

                    log_test_run "$MODIFIED_FILE" "$framework"
                else
                    # Find related test files
                    test_files=$(find_test_files "$MODIFIED_FILE")

                    if [[ -n "$test_files" ]]; then
                        echo "📝 Found related test files:"
                        for test_file in $test_files; do
                            echo "   • $test_file"
                        done
                        echo ""
                        echo "💡 Run tests with:"

                        # Suggest test command for first test file
                        first_test=$(echo "$test_files" | awk '{print $1}')
                        test_cmd=$(suggest_test_command "$first_test" "$framework")
                        if [[ -n "$test_cmd" ]]; then
                            echo "   $test_cmd"
                        fi
                    else
                        echo "⚠️ No test files found for: $MODIFIED_FILE"
                        echo ""
                        echo "💡 Consider creating tests:"

                        # Suggest test file name
                        base_name=$(basename "$MODIFIED_FILE" | sed -E 's/\.(ts|tsx|js|jsx)$//')
                        dir_name=$(dirname "$MODIFIED_FILE")

                        case "$framework" in
                            "jest"|"vitest")
                                echo "   • $dir_name/__tests__/${base_name}.test.ts"
                                echo "   • $dir_name/${base_name}.test.ts"
                                ;;
                            "go")
                                echo "   • ${MODIFIED_FILE%.go}_test.go"
                                ;;
                            "rust")
                                echo "   • Add #[test] functions in $MODIFIED_FILE"
                                echo "   • Create tests/${base_name}_test.rs"
                                ;;
                            "python")
                                echo "   • $dir_name/test_${base_name}.py"
                                echo "   • $dir_name/tests/test_${base_name}.py"
                                ;;
                        esac
                    fi
                fi

                # Check coverage
                check_test_coverage "$MODIFIED_FILE" "$framework"
                echo ""
            fi
        fi
        ;;
    "Task")
        # After implementation tasks, suggest running tests
        if [[ "$CLAUDE_TASK_DESCRIPTION" == *"implement"* ]] || \
           [[ "$CLAUDE_TASK_DESCRIPTION" == *"feature"* ]] || \
           [[ "$CLAUDE_TASK_DESCRIPTION" == *"fix"* ]]; then

            framework=$(detect_test_framework)
            if [[ -n "$framework" ]]; then
                echo "✅ Implementation complete"
                echo ""
                echo "🧪 Don't forget to run tests:"

                case "$framework" in
                    "jest"|"vitest"|"mocha"|"npm")
                        echo "   • npm test"
                        echo "   • npm run test:watch (for development)"
                        ;;
                    "go")
                        echo "   • go test ./..."
                        echo "   • go test -race ./..."
                        ;;
                    "rust")
                        echo "   • cargo test"
                        echo "   • cargo test -- --nocapture (see output)"
                        ;;
                    "python")
                        echo "   • pytest"
                        echo "   • pytest -v --cov"
                        ;;
                esac

                # Check for CI/CD
                if [[ -f ".github/workflows" ]] || [[ -f ".gitlab-ci.yml" ]] || [[ -f "Jenkinsfile" ]]; then
                    echo ""
                    echo "🔄 CI/CD detected - tests will run automatically on commit"
                fi
            fi
        fi
        ;;
esac

exit 0
