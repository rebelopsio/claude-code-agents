# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repository contains 83 specialized agent configuration files for Claude Code, organized into logical categories. Each `.md` file defines a specialized agent with specific expertise, tools, and behavioral patterns for different technical domains.

## Directory Structure

```
agents/
├── cloud-infrastructure/     # AWS, GCP, Kubernetes specialists
├── infrastructure-as-code/   # Terraform, Pulumi experts
├── programming-languages/    # Go, Python, JavaScript/TypeScript, Rust specialists
├── design-frontend/          # UI/UX design and frontend specialists
├── distributed-systems/      # Microservices, data streaming, messaging
├── devops-monitoring/        # DevOps, monitoring, code quality
├── product-management/       # Product, business analysis, technical writing, blog creation
├── quality-assurance/        # Testing and QA specialists
└── data-analysis/           # Data science and analytics

commands/                     # Slash commands for common workflows
├── blog-post.md             # Create SEO-optimized blog posts
├── gh-workflow-debug.md     # Debug GitHub Actions failures
├── incident-analysis.md     # Post-incident analysis
├── deployment-safety.md     # Pre-deployment checks
└── ... (17 total commands)

hooks/                        # Claude Code hooks for enhanced functionality
├── agent-selector.sh        # Suggest appropriate agents for tasks
├── response-notifier.sh     # Desktop notifications when Claude needs input
├── dangerous-operation-validator.sh  # Validate risky operations
└── ... (10 total hooks)
```

## Agent Configuration Structure

Each agent file follows this YAML frontmatter structure:

```yaml
---
name: agent-name
description: Brief description of agent capabilities and use cases
tools: list of available tools (Read, Write, Bash, WebSearch, mcp__*, etc.)
model: preferred model (opus, sonnet, etc.)
---
```

## MCP Tool Integration

Many agents include MCP (Model Context Protocol) tools for enhanced functionality:

### Available MCP Tools

- **`mcp__linear`**: Linear integration for issue tracking, project management, user stories
- **`mcp__mcp-obsidian`**: Obsidian integration for knowledge management and documentation
- **`mcp__Context7`**: Up-to-date library documentation and code examples
- **`mcp__aws-documentation`**: AWS service documentation and best practices
- **`mcp__aws-terraform`**: Terraform AWS provider resources and modules
- **`mcp__pulumi`**: Pulumi registry resources and deployment capabilities
- **`mcp__cloud-run`**: GCP Cloud Run deployment and management

### MCP Tool Usage by Category

- **Product Management**: Linear for user stories, Obsidian for requirements documentation
- **Development**: Context7 for library docs, Obsidian for technical notes
- **DevOps/SRE**: Linear for incident tracking, AWS/Pulumi tools for infrastructure
- **Cloud Infrastructure**: AWS Documentation, Terraform, Pulumi for cloud resources

## Essential Tool Requirements

All agents must have core tools for basic functionality:

### Required Core Tools

- **`Read`**: Read files from the filesystem
- **`Write`**: Write and modify files
- **`Bash`**: Execute commands and scripts
- **`WebSearch`**: Research best practices and documentation

### Additional Tools by Function

- **Development Agents**: Add `mcp__Context7` for up-to-date library documentation
- **Product/Project Management**: Add `mcp__linear` and `mcp__mcp-obsidian` for issue tracking and documentation
- **Infrastructure Agents**: Add relevant MCP tools (`mcp__aws-documentation`, `mcp__pulumi`, etc.)
- **Testing Agents**: Ensure `Bash` access for running test commands

## Project Structure Awareness

Agents must be aware that modern projects often organize code in subdirectories rather than at the root level.

### Common Directory Patterns

**Frontend Applications:**

- `frontend/`, `client/`, `web/`, `ui/`, `app/`
- `packages/frontend/`, `apps/web/`, `apps/client/`

**Backend Services:**

- `backend/`, `server/`, `api/`, `services/`
- `packages/api/`, `apps/api/`, `apps/server/`

**Monorepo Structures:**

- `apps/` - Individual applications (web, mobile, desktop)
- `packages/` - Shared libraries and components
- `libs/` - Internal utility libraries
- `services/` - Microservices or backend services

**Full-Stack Projects:**

- Root level: `frontend/` and `backend/` directories
- Nx workspaces: `apps/` and `libs/`
- Turborepo: `apps/` and `packages/`

### Agent Behavior Requirements

1. **Always explore project structure first** before assuming code location
2. **Look for framework indicators**: `package.json`, `next.config.js`, `Dockerfile`, etc.
3. **Check common subdirectories** before working in root level
4. **Adapt tooling and configurations** based on discovered structure
5. **Document assumptions** about project layout when creating files

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
- **Databases**: sql-architect, postgres-developer

### DevOps & Monitoring

- **CI/CD**: cicd-specialist
- **DevOps**: devops-engineer
- **Containers**: container-specialist
- **Security**: security-engineer
- **Reliability**: site-reliability-engineer
- **Monitoring**: prometheus-engineer
- **Code Quality**: code-reviewer
- **Debugging**: debugger (coordinator), go-debugger, rust-debugger, python-debugger, javascript-debugger, nextjs-debugger, nuxtjs-debugger
- **Operations**: release-manager

### Product Management

- **Analysis**: business-analyst, product-owner
- **Process**: scrum-master
- **Documentation**: technical-writer
- **Content Creation**: blog-writer, marketing-seo-specialist
- **Marketing**: marketing-seo-specialist

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

# Validate hooks functionality
python .github/scripts/validate_hooks.py
python .github/scripts/test_hooks.py

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

### Agent Hierarchy and Delegation

Agents are organized in a hierarchical structure that mirrors real-world development teams:

#### Level 1: Architects (1-to-many delegation)

**Role**: High-level design and orchestration

- `solution-architect`: Top-level orchestrator, delegates to domain architects
- `*-architect` agents: Design systems, delegate implementation to engineers
- **Delegation pattern**: Break down complex problems, assign to multiple specialists
- **Examples**:
  - `go-architect` → `go-engineer` + `go-test-engineer`
  - `aws-architect` → `terraform-architect` + implementation teams

#### Level 2: Engineers (1-to-1 or 1-to-few delegation)

**Role**: Implementation and feature development

- `*-engineer` agents: Implement designs from architects
- **Delegation pattern**: Implement then hand off for testing/review
- **Examples**:
  - `go-engineer` → `go-test-engineer` for test coverage
  - Any engineer → `code-reviewer` for quality validation

#### Level 3: Specialists (receive and validate)

**Role**: Quality assurance, optimization, and validation

- `*-test-engineer`: Write tests for implemented code
- `*-performance-optimizer`: Optimize existing implementations
- `code-reviewer`: Cross-cutting quality reviews
- `security-engineer`: Security validation and hardening

#### Handoff Best Practices

**Downstream handoff should include**:

- Clear specifications and requirements
- Architectural decisions and rationale
- Interface definitions and contracts
- Performance requirements and constraints
- Risk factors and edge cases to consider

**Upstream feedback should include**:

- Implementation feasibility concerns
- Discovered edge cases or limitations
- Performance bottlenecks identified
- Test results and coverage metrics
- Security vulnerabilities found

**Cross-cutting agents**:

- `code-reviewer`: Reviews code from all levels
- `debugger`: Coordinates debugging, delegates to language-specific debuggers
  - Language specialists: `go-debugger`, `rust-debugger`, `python-debugger`, `javascript-debugger`
  - Framework specialists: `nextjs-debugger`, `nuxtjs-debugger`
- `security-engineer`: Validates security across all implementations

### Common Tool Patterns

- `Read, Write`: For code generation and modification
- `Bash`: For command execution and system interaction
- `WebSearch`: For documentation and best practice research
- `LS, Glob, Grep`: For exploration and searching (architects, test engineers)
- `MultiEdit`: For bulk refactoring (engineers, migration specialists)
- Model selection based on task complexity (opus for complex architecture, sonnet for implementation)
