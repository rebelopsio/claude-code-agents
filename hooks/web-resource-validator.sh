#!/bin/bash
# PostToolUse hook: Validate web resources and references after changes

# This hook runs after file modifications
# It checks for broken references, missing imports, and invalid paths

TOOL_NAME="$CLAUDE_TOOL_NAME"
MODIFIED_FILE="$1"
VALIDATION_LOG="$HOME/.claude-code/validation.log"

# Ensure directory exists
mkdir -p "$HOME/.claude-code"

# Function to validate Next.js/React imports
validate_imports() {
    local file="$1"
    local issues_found=false

    # Skip if not a JS/TS file
    if [[ ! "$file" =~ \.(js|jsx|ts|tsx)$ ]]; then
        return 0
    fi

    # Check if file exists
    if [[ ! -f "$file" ]]; then
        return 0
    fi

    # Extract imports
    local imports=$(grep -E "^import .* from ['\"]" "$file" 2>/dev/null)

    while IFS= read -r import_line; do
        # Extract the import path
        local import_path=$(echo "$import_line" | sed -E "s/.*from ['\"]([^'\"]+)['\"].*/\1/")

        # Skip external packages (no relative/absolute paths)
        if [[ ! "$import_path" =~ ^[./] ]]; then
            continue
        fi

        # Get directory of the importing file
        local file_dir=$(dirname "$file")

        # Resolve the import path
        if [[ "$import_path" =~ ^/ ]]; then
            # Absolute import (from project root)
            resolved_path=".$import_path"
        else
            # Relative import
            resolved_path="$file_dir/$import_path"
        fi

        # Check various extensions if no extension provided
        if [[ ! "$resolved_path" =~ \.[^/]+$ ]]; then
            local found=false
            for ext in .ts .tsx .js .jsx /index.ts /index.tsx /index.js /index.jsx; do
                if [[ -f "$resolved_path$ext" ]]; then
                    found=true
                    break
                fi
            done

            if [[ "$found" == false ]]; then
                echo "⚠️ Missing import: '$import_path' in $file"
                echo "   Resolved to: $resolved_path (not found)"
                issues_found=true
            fi
        elif [[ ! -f "$resolved_path" ]]; then
            echo "⚠️ Missing import: '$import_path' in $file"
            issues_found=true
        fi
    done <<< "$imports"

    if [[ "$issues_found" == true ]]; then
        echo "💡 Tip: Check that all imported files exist and paths are correct"
        return 1
    fi

    return 0
}

# Function to validate Next.js specific patterns
validate_nextjs_patterns() {
    local file="$1"

    # Check for Next.js project
    if [[ ! -f "package.json" ]] || ! grep -q "next" package.json 2>/dev/null; then
        return 0
    fi

    # Check API route references
    if [[ "$file" =~ \.(js|jsx|ts|tsx)$ ]]; then
        local api_calls=$(grep -E "fetch\(['\"][^'\"]*['\"]" "$file" 2>/dev/null)

        while IFS= read -r api_line; do
            local api_path=$(echo "$api_line" | sed -E "s/.*fetch\(['\"]([^'\"]+)['\"].*/\1/")

            # Check internal API routes
            if [[ "$api_path" =~ ^/api/ ]]; then
                # Convert API path to file path
                local api_file_base="pages$api_path"
                if [[ ! -f "$api_file_base.ts" ]] && [[ ! -f "$api_file_base.js" ]] && [[ ! -f "$api_file_base/index.ts" ]] && [[ ! -f "$api_file_base/index.js" ]]; then
                    # Check app directory structure
                    api_file_base="app$api_path/route"
                    if [[ ! -f "$api_file_base.ts" ]] && [[ ! -f "$api_file_base.js" ]]; then
                        echo "⚠️ API route not found: $api_path"
                        echo "   Referenced in: $file"
                    fi
                fi
            fi
        done <<< "$api_calls"
    fi

    # Check for Image src paths
    if grep -q "next/image" "$file" 2>/dev/null; then
        local image_srcs=$(grep -E "src=['\"][^'\"]+['\"]" "$file" 2>/dev/null)

        while IFS= read -r img_line; do
            local img_path=$(echo "$img_line" | sed -E "s/.*src=['\"]([^'\"]+)['\"].*/\1/")

            # Check local images
            if [[ "$img_path" =~ ^/ ]] && [[ ! "$img_path" =~ ^https?:// ]]; then
                if [[ ! -f "public$img_path" ]]; then
                    echo "⚠️ Image not found in public directory: $img_path"
                    echo "   Referenced in: $file"
                fi
            fi
        done <<< "$image_srcs"
    fi
}

# Function to validate link hrefs
validate_links() {
    local file="$1"

    # Check for Next.js Link components
    if grep -q "next/link" "$file" 2>/dev/null; then
        local links=$(grep -E "href=['\"][^'\"]+['\"]" "$file" 2>/dev/null)

        while IFS= read -r link_line; do
            local href=$(echo "$link_line" | sed -E "s/.*href=['\"]([^'\"]+)['\"].*/\1/")

            # Check internal routes
            if [[ "$href" =~ ^/ ]] && [[ ! "$href" =~ ^https?:// ]] && [[ ! "$href" =~ ^# ]]; then
                # Remove query params and anchors
                local route_path=$(echo "$href" | cut -d'?' -f1 | cut -d'#' -f1)

                # Check if route file exists (pages or app directory)
                local found=false

                # Check pages directory
                for ext in .tsx .ts .jsx .js; do
                    if [[ -f "pages$route_path$ext" ]] || [[ -f "pages$route_path/index$ext" ]]; then
                        found=true
                        break
                    fi
                done

                # Check app directory
                if [[ "$found" == false ]]; then
                    if [[ -f "app$route_path/page.tsx" ]] || [[ -f "app$route_path/page.ts" ]] || [[ -f "app$route_path/page.jsx" ]] || [[ -f "app$route_path/page.js" ]]; then
                        found=true
                    fi
                fi

                if [[ "$found" == false && "$route_path" != "/" && "$route_path" != "" ]]; then
                    echo "⚠️ Route may not exist: $href"
                    echo "   Referenced in: $file"
                    echo "   💡 Tip: Ensure the page component exists for this route"
                fi
            fi
        done <<< "$links"
    fi
}

# Function to validate CSS/SCSS imports
validate_styles() {
    local file="$1"

    # Check CSS imports
    local css_imports=$(grep -E "import.*\.(css|scss|sass)" "$file" 2>/dev/null)

    while IFS= read -r css_line; do
        local css_path=$(echo "$css_line" | sed -E "s/.*['\"]([^'\"]+\.(css|scss|sass))['\"].*/\1/")

        if [[ -n "$css_path" ]]; then
            local file_dir=$(dirname "$file")

            # Resolve relative path
            if [[ "$css_path" =~ ^\./ ]]; then
                resolved_css="$file_dir/$css_path"
            else
                resolved_css="$css_path"
            fi

            if [[ ! -f "$resolved_css" ]]; then
                echo "⚠️ Style file not found: $css_path"
                echo "   Referenced in: $file"
            fi
        fi
    done <<< "$css_imports"
}

# Function to validate environment variables
validate_env_vars() {
    local file="$1"

    # Check for environment variable usage
    local env_vars=$(grep -E "process\.env\.[A-Z_]+" "$file" 2>/dev/null | sed -E "s/.*process\.env\.([A-Z_]+).*/\1/" | sort -u)

    if [[ -n "$env_vars" ]]; then
        local missing_vars=""

        while IFS= read -r var; do
            # Check if it's a Next.js public var
            if [[ "$var" =~ ^NEXT_PUBLIC_ ]]; then
                # Check .env files
                local found=false
                for env_file in .env .env.local .env.development .env.production; do
                    if [[ -f "$env_file" ]] && grep -q "^$var=" "$env_file" 2>/dev/null; then
                        found=true
                        break
                    fi
                done

                if [[ "$found" == false ]]; then
                    missing_vars="$missing_vars $var"
                fi
            fi
        done <<< "$env_vars"

        if [[ -n "$missing_vars" ]]; then
            echo "⚠️ Environment variables used but not defined:$missing_vars"
            echo "   In file: $file"
            echo "   💡 Tip: Add these to your .env.local or appropriate .env file"
        fi
    fi
}

# Function to log validation results
log_validation() {
    local file="$1"
    local status="$2"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    echo "[$timestamp] File: $file, Status: $status" >> "$VALIDATION_LOG"
}

# Main validation logic
case "$TOOL_NAME" in
    "Write"|"Edit"|"MultiEdit")
        # Get the modified file path from the tool arguments
        if [[ -n "$MODIFIED_FILE" ]] && [[ -f "$MODIFIED_FILE" ]]; then
            echo "🔍 Validating changes to: $MODIFIED_FILE"

            validation_failed=false

            # Run validations
            if ! validate_imports "$MODIFIED_FILE"; then
                validation_failed=true
            fi

            if ! validate_nextjs_patterns "$MODIFIED_FILE"; then
                validation_failed=true
            fi

            if ! validate_links "$MODIFIED_FILE"; then
                validation_failed=true
            fi

            if ! validate_styles "$MODIFIED_FILE"; then
                validation_failed=true
            fi

            if ! validate_env_vars "$MODIFIED_FILE"; then
                validation_failed=true
            fi

            # Log results
            if [[ "$validation_failed" == true ]]; then
                log_validation "$MODIFIED_FILE" "warnings"
                echo ""
                echo "📝 Validation found potential issues. Please review the warnings above."
            else
                log_validation "$MODIFIED_FILE" "clean"
            fi
        fi
        ;;
    "Task")
        # Check if task involved web development
        if [[ "$CLAUDE_TASK_DESCRIPTION" == *"nextjs"* ]] || [[ "$CLAUDE_TASK_DESCRIPTION" == *"react"* ]] || [[ "$CLAUDE_TASK_DESCRIPTION" == *"frontend"* ]]; then
            echo "💡 Web development task completed. Consider running:"
            echo "   • npm run build - to check for build errors"
            echo "   • npm run lint - to check for linting issues"
            echo "   • npm test - to ensure tests pass"
        fi
        ;;
esac

exit 0
