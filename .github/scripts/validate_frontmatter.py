#!/usr/bin/env python3
"""
Validate YAML frontmatter in agent files.
"""

import yaml
import sys
import os

def main():
    """Validate frontmatter for all provided files."""
    errors = []

    for arg in sys.argv[1:]:
        if arg.endswith('.md'):
            try:
                with open(arg, 'r') as f:
                    content = f.read()

                if not content.startswith('---'):
                    errors.append(f'❌ {arg}: Missing YAML frontmatter')
                    continue

                parts = content.split('---', 2)
                if len(parts) < 3:
                    errors.append(f'❌ {arg}: Invalid frontmatter structure')
                    continue

                frontmatter = yaml.safe_load(parts[1])

                # Check required fields
                required_fields = ['name', 'description']
                for field in required_fields:
                    if field not in frontmatter:
                        errors.append(f'❌ {arg}: Missing required field: {field}')

                # Validate name matches filename
                expected_name = os.path.basename(arg)[:-3]
                if frontmatter.get('name') != expected_name:
                    errors.append(f'❌ {arg}: name field must match filename')

            except yaml.YAMLError as e:
                errors.append(f'❌ {arg}: Invalid YAML: {e}')
            except Exception as e:
                errors.append(f'❌ {arg}: Error: {e}')

    if errors:
        for error in errors:
            print(error)
        sys.exit(1)

if __name__ == '__main__':
    main()
