# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repository contains specialized agent configuration files for Claude Code, organized into logical categories. Each `.md` file defines a specialized agent with specific expertise, tools, and behavioral patterns for different technical domains.

## Directory Structure

```
agents/
├── cloud-infrastructure/     # AWS, GCP, Kubernetes specialists
├── infrastructure-as-code/   # Terraform, Pulumi experts
├── programming-languages/    # Go, Python, JavaScript/TypeScript specialists
├── devops-monitoring/        # DevOps, monitoring, code quality
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

### Infrastructure as Code

- **Terraform**: terraform-architect, terraform-migration-specialist, terraform-module-developer
- **Pulumi**: pulumi-architect, pulumi-automation-engineer, pulumi-component-engineer, pulumi-cost-analyzer, pulumi-migration-specialist, pulumi-multi-cloud-architect, pulumi-policy-engineer, pulumi-security-compliance-engineer, pulumi-state-manager, pulumi-testing-specialist

### Programming Languages & Frameworks

- **Go**: go-architect, go-performance-optimizer, go-test-engineer
- **Python**: python-automation-engineer, python-data-processor
- **JavaScript/TypeScript**: nextjs-architect, nextjs-deployment-specialist, react-component-engineer

### DevOps & Monitoring

- **Monitoring**: prometheus-engineer
- **Code Quality**: code-reviewer, debugger
- **Data**: data-scientist

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
