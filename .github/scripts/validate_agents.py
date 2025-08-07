#!/usr/bin/env python3
"""
Validate Claude Code agent files for structure, naming, and content quality.
"""

import os
import yaml
import re
import sys
from pathlib import Path

def validate_agent_file(file_path):
    """Validate a single agent file."""
    errors = []

    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Check for YAML frontmatter
    if not content.startswith('---'):
        errors.append("Missing YAML frontmatter")
        return errors

    try:
        # Extract frontmatter and content
        parts = content.split('---', 2)
        if len(parts) < 3:
            errors.append("Invalid frontmatter structure")
            return errors

        frontmatter = yaml.safe_load(parts[1])
        agent_content = parts[2].strip()

        # Validate required fields
        required_fields = ['name', 'description']
        for field in required_fields:
            if field not in frontmatter:
                errors.append(f"Missing required field: {field}")

        # Validate optional fields
        optional_fields = ['tools', 'model']
        valid_models = ['opus', 'sonnet', 'haiku']

        if 'model' in frontmatter:
            if frontmatter['model'] not in valid_models:
                errors.append(f"Invalid model: {frontmatter['model']}. Must be one of: {valid_models}")

        # Validate name matches filename
        expected_name = file_path.stem
        if frontmatter.get('name') != expected_name:
            errors.append(f"Agent name '{frontmatter.get('name')}' must match filename '{expected_name}'")

        # Validate name format (kebab-case)
        if not re.match(r'^[a-z0-9]+(-[a-z0-9]+)*$', expected_name):
            errors.append(f"Agent name must be in kebab-case format")

        # Validate description
        description = frontmatter.get('description', '')
        if len(description) < 20:
            errors.append("Description too short (minimum 20 characters)")
        if len(description) > 200:
            errors.append("Description too long (maximum 200 characters)")

        # Validate content length
        if len(agent_content) < 100:
            errors.append("Agent content too short (minimum 100 characters)")

        # Check for key sections in content
        content_lower = agent_content.lower()
        if 'when invoked:' not in content_lower:
            errors.append("Missing 'When invoked:' section")

        # Check for best practices or key practices section
        if not any(phrase in content_lower for phrase in ['best practices', 'key practices', 'practices:']):
            errors.append("Missing best practices or key practices section")

    except yaml.YAMLError as e:
        errors.append(f"Invalid YAML frontmatter: {e}")
    except Exception as e:
        errors.append(f"Unexpected error: {e}")

    return errors

def main():
    """Main validation function."""
    agents_dir = Path('agents')
    if not agents_dir.exists():
        print("❌ Agents directory not found")
        sys.exit(1)

    total_errors = 0
    agent_count = 0

    # Validate all agent files
    for agent_file in agents_dir.rglob('*.md'):
        agent_count += 1
        print(f"Validating {agent_file}...")

        errors = validate_agent_file(agent_file)
        if errors:
            print(f"❌ {agent_file}:")
            for error in errors:
                print(f"  - {error}")
            total_errors += len(errors)
        else:
            print(f"✅ {agent_file}")

    # Summary
    print(f"\n📊 Validation Summary:")
    print(f"  - Agents validated: {agent_count}")
    print(f"  - Total errors: {total_errors}")

    if total_errors > 0:
        print("❌ Validation failed")
        sys.exit(1)
    else:
        print("✅ All agents passed validation")

if __name__ == "__main__":
    main()
