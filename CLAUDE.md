# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repository contains 70 specialized agent configuration files for Claude Code, organized into logical categories. Each `.md` file defines a specialized agent with specific expertise, tools, and behavioral patterns for different technical domains.

## Directory Structure

```
agents/
├── cloud-infrastructure/     # AWS, GCP, Kubernetes specialists
├── infrastructure-as-code/   # Terraform, Pulumi experts
├── programming-languages/    # Go, Python, JavaScript/TypeScript, Rust specialists
├── design-frontend/          # UI/UX design and frontend specialists
├── distributed-systems/      # Microservices, data streaming, messaging
├── devops-monitoring/        # DevOps, monitoring, code quality
├── product-management/       # Product, business analysis, technical writing
├── quality-assurance/        # Testing and QA specialists
└── data-analysis/           # Data science and analytics
```

## Agent Configuration Structure

Each agent file follows this YAML frontmatter structure:

```yaml
---
name: agent-name
description: Brief description of agent capabilities and use cases
tools: list of available tools (file_read, file_write, bash, web_search, etc.)
model: preferred model (opus, sonnet, etc.)
---
```

## Available Agent Categories

### Cloud Infrastructure

- **AWS**: aws-architect, aws-cost-optimizer, aws-security-engineer
- **GCP**: gcp-infrastructure, gcp-monitoring, gcp-database, gcp-security, gcp-cost-optimization, gcp-migration, gke-specialist
- **Kubernetes**: k8s-architect, k8s-deployment-engineer, k8s-troubleshooter
- **General**: solution-architect

### Infrastructure as Code

- **Terraform**: terraform-architect, terraform-migration-specialist, terraform-module-developer
- **Pulumi**: pulumi-architect, pulumi-automation-engineer, pulumi-component-engineer, pulumi-cost-analyzer, pulumi-migration-specialist, pulumi-multi-cloud-architect, pulumi-policy-engineer, pulumi-security-compliance-engineer, pulumi-state-manager, pulumi-testing-specialist

### Programming Languages & Frameworks

- **Go**: go-architect, go-performance-optimizer, go-test-engineer
- **Python**: python-automation-engineer, python-data-processor, python-test-engineer
- **JavaScript/TypeScript**: nextjs-architect, nextjs-deployment-specialist, react-component-engineer, react-nextjs-test-engineer, react-native-developer, nuxt-developer, vue-developer, vue-nuxt-test-engineer
- **Rust**: rust-systems-engineer, rust-cli-developer, rust-test-engineer, rust-tui-developer, rust-web-wasm-engineer, rust-tauri-developer

### Design & Frontend

- **UI/UX**: ui-ux-designer, ux-researcher
- **CSS**: tailwind-specialist

### Distributed Systems

- **Architecture**: microservices-architect
- **Messaging**: message-queue-engineer, data-streaming-engineer
- **Data**: etl-elt-engineer, database-sharding-expert

### DevOps & Monitoring

- **CI/CD**: cicd-specialist
- **DevOps**: devops-engineer
- **Containers**: container-specialist
- **Security**: security-engineer
- **Reliability**: site-reliability-engineer
- **Monitoring**: prometheus-engineer
- **Code Quality**: code-reviewer, debugger
- **Operations**: release-manager

### Product Management

- **Analysis**: business-analyst, product-owner
- **Process**: scrum-master
- **Documentation**: technical-writer

### Quality Assurance

- **Testing**: qa-engineer

### Data Analysis

- **Analytics**: data-scientist

## Common Development Commands

### Validation and Quality Checks

```bash
# Install development dependencies
pip install -r requirements-dev.txt

# Run pre-commit hooks (validates agents, YAML, formatting)
pre-commit run --all-files

# Validate agent structure and content
python .github/scripts/validate_agents.py

# Check agent naming conventions
find agents/ -name "*.md" | while read file; do
  basename=$(basename "$file" .md)
  if [[ ! "$basename" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
    echo "❌ Invalid agent name: $file (must be kebab-case)"
  fi
done

# Validate YAML frontmatter in all agents
python .github/scripts/validate_frontmatter.py
```

### Agent File Structure Validation

The validation system enforces:

- **Required fields**: `name`, `description`
- **Optional fields**: `tools`, `model` (must be opus/sonnet/haiku if specified)
- **Naming**: Agent name must match filename in kebab-case
- **Content**: Minimum 100 characters, must include "When invoked:" and practices sections
- **Description**: 20-200 characters

## Development Tasks

### Adding New Agents

1. Create a new `.md` file following the naming convention: `domain-role.md`
2. Place in the appropriate category directory under `agents/`
3. Include required YAML frontmatter with name, description, tools, and model
4. Define clear behavioral patterns and expertise areas
5. Specify key practices and considerations
6. Update the main README.md with agent details

### Modifying Existing Agents

1. Maintain the YAML frontmatter structure
2. Ensure descriptions accurately reflect capabilities
3. Update tool requirements if needed
4. Keep behavioral instructions clear and actionable
5. Update documentation if agent capabilities change

## Architecture Principles

- **Single Responsibility**: Each agent focuses on a specific domain or role
- **Clear Expertise Boundaries**: Agents have well-defined capabilities and limitations
- **Tool Appropriateness**: Agents only request tools necessary for their domain
- **Best Practices Enforcement**: Each agent embodies industry best practices for their domain
- **Actionable Instructions**: Agent behaviors are defined with clear, executable steps
- **Consistent Structure**: All agents follow the same frontmatter format and content patterns
- **Quality Assurance**: Automated validation ensures agent files meet structural and content requirements

## Key Patterns

### Agent Invocation Flow

1. Analyze requirements and constraints
2. Apply domain-specific best practices
3. Implement solutions using available tools
4. Validate and optimize results
5. Document decisions and rationale

### Common Tool Patterns

- `file_read, file_write`: For code generation and modification
- `bash`: For command execution and system interaction
- `web_search`: For documentation and best practice research
- Model selection based on task complexity (opus for complex architecture, sonnet for implementation)
