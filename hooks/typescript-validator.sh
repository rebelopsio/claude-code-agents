#!/bin/bash
# PostToolUse hook: Validate TypeScript changes and type safety

# This hook runs after TypeScript file modifications
# It checks for type errors, missing types, and suggests type improvements

TOOL_NAME="$CLAUDE_TOOL_NAME"
MODIFIED_FILE="$1"

# Function to check if TypeScript is available
check_typescript() {
    if [[ -f "tsconfig.json" ]] && command -v npx &> /dev/null; then
        return 0
    fi
    return 1
}

# Function to validate TypeScript file
validate_typescript() {
    local file="$1"

    # Skip if not a TypeScript file
    if [[ ! "$file" =~ \.(ts|tsx)$ ]]; then
        return 0
    fi

    # Skip if TypeScript not available
    if ! check_typescript; then
        return 0
    fi

    echo "🔍 Running TypeScript validation on: $file"

    # Run TypeScript compiler check on single file
    local tsc_output=$(npx tsc --noEmit --skipLibCheck "$file" 2>&1)
    local tsc_exit=$?

    if [[ $tsc_exit -ne 0 ]]; then
        echo "❌ TypeScript errors found:"
        echo "$tsc_output" | head -20
        echo ""
        echo "💡 Fix suggestions:"

        # Analyze common error patterns
        if [[ "$tsc_output" == *"Cannot find module"* ]]; then
            echo "   • Check import paths and ensure modules are installed"
            echo "   • Run: npm install or yarn install"
        fi

        if [[ "$tsc_output" == *"Property"*"does not exist on type"* ]]; then
            echo "   • Add type definitions for the missing property"
            echo "   • Check if you're accessing the correct object"
        fi

        if [[ "$tsc_output" == *"Type"*"is not assignable to type"* ]]; then
            echo "   • Review type compatibility"
            echo "   • Consider using type assertions or generics"
        fi

        if [[ "$tsc_output" == *"Object is possibly 'undefined'"* ]] || [[ "$tsc_output" == *"Object is possibly 'null'"* ]]; then
            echo "   • Add null/undefined checks"
            echo "   • Use optional chaining (?.) or nullish coalescing (??)"
        fi

        return 1
    fi

    # Check for any 'any' types (code quality)
    local any_count=$(grep -c "\bany\b" "$file" 2>/dev/null || echo 0)
    if [[ $any_count -gt 0 ]]; then
        echo "⚠️ Found $any_count usage(s) of 'any' type in $file"
        echo "   💡 Consider using more specific types for better type safety"
    fi

    # Check for missing return types
    if grep -E "function.*\(.*\)\s*{|=>\s*{" "$file" | grep -v -E ":\s*\w+\s*(=>|\{)" &>/dev/null; then
        echo "⚠️ Some functions may be missing explicit return types"
        echo "   💡 Add return type annotations for better type safety"
    fi

    return 0
}

# Function to suggest type improvements
suggest_type_improvements() {
    local file="$1"

    # Check for common patterns that could be improved

    # Check for string literals that could be enums
    if grep -E "(status|type|mode|state)\s*[=:]\s*['\"]" "$file" &>/dev/null; then
        echo "💡 Consider using enums or union types for string literals like 'status', 'type', 'mode'"
    fi

    # Check for magic numbers
    if grep -E "[^0-9]\d{2,}[^0-9]" "$file" | grep -v -E "import|from|px|ms|[0-9]{4}" &>/dev/null; then
        echo "💡 Consider extracting magic numbers to named constants"
    fi

    # Check for TODO/FIXME comments
    if grep -E "//\s*(TODO|FIXME|HACK|XXX)" "$file" &>/dev/null; then
        echo "📝 Found TODO/FIXME comments - don't forget to address them"
    fi
}

# Function to validate interfaces and types
validate_types_usage() {
    local file="$1"

    # Check if interfaces are exported when needed
    local interfaces=$(grep -E "^interface\s+\w+" "$file" 2>/dev/null)
    if [[ -n "$interfaces" ]]; then
        while IFS= read -r interface_line; do
            local interface_name=$(echo "$interface_line" | sed -E "s/interface\s+(\w+).*/\1/")

            # Check if it's used in exports
            if grep -E "export.*$interface_name" "$file" &>/dev/null; then
                continue
            fi

            # Check if it should be exported (PascalCase usually means public)
            if [[ "$interface_name" =~ ^[A-Z] ]]; then
                echo "💡 Interface '$interface_name' might need to be exported"
            fi
        done <<< "$interfaces"
    fi
}

# Function to check for common React/Next.js TypeScript issues
check_react_typescript() {
    local file="$1"

    # Skip if not a React file
    if [[ ! "$file" =~ \.(tsx)$ ]]; then
        return 0
    fi

    # Check for proper React.FC usage
    if grep -E ":\s*React\.FC\b" "$file" &>/dev/null; then
        echo "💡 Consider explicit typing over React.FC for better type inference"
    fi

    # Check for missing key props in maps
    if grep -E "\.map\([^)]+\)\s*=>\s*[<(]" "$file" | grep -v "key=" &>/dev/null; then
        echo "⚠️ Possible missing 'key' prop in array mapping"
    fi

    # Check for event handler types
    if grep -E "on[A-Z]\w+\s*=\s*\([^)]*\)\s*=>" "$file" | grep -v -E ":\s*\w+Event" &>/dev/null; then
        echo "💡 Consider adding proper event types to handlers (e.g., React.MouseEvent)"
    fi
}

# Main validation logic
case "$TOOL_NAME" in
    "Write"|"Edit"|"MultiEdit")
        if [[ -n "$MODIFIED_FILE" ]] && [[ -f "$MODIFIED_FILE" ]]; then
            # Only validate TypeScript files
            if [[ "$MODIFIED_FILE" =~ \.(ts|tsx)$ ]]; then
                echo "📘 TypeScript Validation"
                echo "━━━━━━━━━━━━━━━━━━━━━"

                # Run validations
                validate_typescript "$MODIFIED_FILE"
                suggest_type_improvements "$MODIFIED_FILE"
                validate_types_usage "$MODIFIED_FILE"
                check_react_typescript "$MODIFIED_FILE"

                echo ""
            fi
        fi
        ;;
    "Task")
        # After TypeScript-related tasks
        if [[ "$CLAUDE_TASK_DESCRIPTION" == *"typescript"* ]] || [[ "$CLAUDE_TASK_DESCRIPTION" == *"types"* ]]; then
            if check_typescript; then
                echo "📘 TypeScript task completed. Running project-wide type check..."

                # Run full type check
                if npx tsc --noEmit 2>&1 | head -5 | grep -E "error"; then
                    echo "❌ Type errors detected in project"
                    echo "   Run: npx tsc --noEmit for full details"
                else
                    echo "✅ No type errors detected"
                fi
            fi
        fi
        ;;
esac

exit 0
