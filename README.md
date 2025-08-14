# Claude Code Agents

A collection of specialized agent configurations for Claude Code, designed to provide expert assistance across various technical domains.

## Overview

This repository contains pre-configured agent definitions that enable Claude Code to act as domain-specific experts. Each agent is tailored with specialized knowledge, best practices, and tools for their respective technical areas.

## Repository Structure

```
claude-code-agents/
├── agents/
│   ├── cloud-infrastructure/     # Cloud platform specialists
│   ├── infrastructure-as-code/   # IaC tools and practices
│   ├── programming-languages/    # Language-specific experts
│   ├── design-frontend/          # UI/UX and frontend design
│   ├── distributed-systems/      # Distributed systems and data
│   ├── devops-monitoring/        # DevOps and observability
│   ├── product-management/       # Product and project management
│   ├── quality-assurance/        # Testing and quality assurance
│   └── data-analysis/           # Data science and analytics
├── CLAUDE.md                    # Development guidance
└── README.md                    # This file
```

## Available Agents

### Cloud Infrastructure

| Agent                     | Description                                                     |
| ------------------------- | --------------------------------------------------------------- |
| `aws-architect`           | Design AWS cloud architectures using Well-Architected Framework |
| `aws-cost-optimizer`      | Analyze and optimize AWS costs and spending patterns            |
| `aws-security-engineer`   | Implement AWS security best practices and compliance            |
| `gcp-infrastructure`      | Provision and manage GCP resources using Terraform              |
| `gcp-monitoring`          | Set up monitoring dashboards and alerting in GCP                |
| `gcp-database`            | Deploy and optimize GCP database services                       |
| `gcp-security`            | Implement GCP security controls and IAM policies                |
| `gcp-cost-optimization`   | Analyze and optimize GCP costs and resource usage               |
| `gcp-migration`           | Migrate workloads from other clouds to GCP                      |
| `gke-specialist`          | Manage Google Kubernetes Engine clusters                        |
| `k8s-architect`           | Design Kubernetes architectures and multi-tenancy               |
| `k8s-deployment-engineer` | Create Kubernetes manifests and Helm charts                     |
| `k8s-troubleshooter`      | Debug Kubernetes issues and performance problems                |
| `solution-architect`      | Design enterprise solutions and system architectures            |

### Infrastructure as Code

| Agent                                 | Description                                           |
| ------------------------------------- | ----------------------------------------------------- |
| `terraform-architect`                 | Design Terraform modules and multi-environment setups |
| `terraform-migration-specialist`      | Migrate infrastructure to Terraform                   |
| `terraform-module-developer`          | Develop reusable Terraform modules                    |
| `pulumi-architect`                    | Design Pulumi programs with modern IaC patterns       |
| `pulumi-automation-engineer`          | Build Pulumi Automation API programs                  |
| `pulumi-component-engineer`           | Build reusable Pulumi components                      |
| `pulumi-cost-analyzer`                | Analyze and optimize infrastructure costs             |
| `pulumi-migration-specialist`         | Migrate to Pulumi from other IaC tools                |
| `pulumi-multi-cloud-architect`        | Design multi-cloud architectures                      |
| `pulumi-policy-engineer`              | Create compliance and governance policies             |
| `pulumi-security-compliance-engineer` | Implement security controls and compliance            |
| `pulumi-state-manager`                | Manage Pulumi state and disaster recovery             |
| `pulumi-testing-specialist`           | Implement comprehensive testing strategies            |

### Programming Languages

| Agent                          | Description                                                                 |
| ------------------------------ | --------------------------------------------------------------------------- |
| `go-architect`                 | Design Go applications and architectural patterns                           |
| `go-engineer`                  | Implement Go applications following architectural designs                   |
| `go-performance-optimizer`     | Optimize Go applications for performance                                    |
| `go-test-engineer`             | Write comprehensive Go tests and benchmarks                                 |
| `python-automation-engineer`   | Create Python automation scripts and CLI tools                              |
| `python-data-processor`        | Build Python data processing pipelines                                      |
| `python-test-engineer`         | Write comprehensive Python tests using pytest and testing frameworks        |
| `nextjs-architect`             | Design NextJS applications with App Router                                  |
| `nextjs-deployment-specialist` | Configure NextJS deployments and CI/CD                                      |
| `react-component-engineer`     | Build reusable React components with TypeScript                             |
| `react-nextjs-test-engineer`   | Write comprehensive tests for React and NextJS applications                 |
| `react-native-developer`       | Build cross-platform mobile apps with React Native                          |
| `rust-systems-engineer`        | High-performance Rust systems programming                                   |
| `rust-cli-developer`           | Build robust command-line applications in Rust                              |
| `rust-test-engineer`           | Write comprehensive Rust tests using built-in framework and ecosystem tools |
| `rust-tui-developer`           | Create terminal user interfaces with ratatui                                |
| `rust-web-wasm-engineer`       | Build web applications using Rust and WebAssembly                           |
| `rust-tauri-developer`         | Create desktop applications using Tauri                                     |
| `vue-developer`                | Build Vue.js applications with Composition API                              |
| `vue-nuxt-test-engineer`       | Write comprehensive tests for Vue.js and Nuxt applications                  |
| `nuxt-developer`               | Full-stack web applications with Nuxt.js                                    |
| `fullstack-nextjs-go`          | Build full-stack applications with Next.js frontend and Go backend          |
| `fullstack-nuxtjs-go`          | Build full-stack applications with Nuxt.js frontend and Go backend          |

### DevOps & Monitoring

| Agent                       | Description                                                                   |
| --------------------------- | ----------------------------------------------------------------------------- |
| `cicd-specialist`           | Design and implement CI/CD pipelines using GitHub Actions, GitLab CI, Jenkins |
| `container-specialist`      | Design and implement containerization strategies using Docker and Kubernetes  |
| `devops-engineer`           | Implement DevOps practices, automation, and cultural transformation           |
| `security-engineer`         | Implement comprehensive security practices and DevSecOps integration          |
| `site-reliability-engineer` | Implement SRE practices, incident response, and service level management      |
| `prometheus-engineer`       | Configure Prometheus monitoring and alerting                                  |
| `code-reviewer`             | Expert code review for quality and security                                   |
| `debugger`                  | General debugging coordinator that routes to specialized debuggers            |
| `go-debugger`               | Debug Go applications with delve, pprof, race detector                        |
| `rust-debugger`             | Debug Rust applications with LLDB/GDB, memory safety tools                    |
| `python-debugger`           | Debug Python with pdb/ipdb, profiling, traceback analysis                     |
| `javascript-debugger`       | Debug JS/TS with Chrome DevTools, Node inspector                              |
| `nextjs-debugger`           | Debug Next.js SSR/SSG, hydration, App Router issues                           |
| `nuxtjs-debugger`           | Debug Nuxt.js SSR/SSG, Vue 3, Nitro server issues                             |
| `release-manager`           | Plan releases and coordinate software deployments                             |

### Design & Frontend

| Agent                 | Description                                                     |
| --------------------- | --------------------------------------------------------------- |
| `ui-ux-designer`      | Design user interfaces and experiences with accessibility focus |
| `ux-researcher`       | Conduct user research and validate design decisions             |
| `tailwind-specialist` | Master Tailwind CSS for rapid UI development                    |

### Distributed Systems

| Agent                      | Description                                                                              |
| -------------------------- | ---------------------------------------------------------------------------------------- |
| `microservices-architect`  | Design microservices architectures and service decoupling                                |
| `message-queue-engineer`   | Implement message queue systems and event-driven architectures                           |
| `data-streaming-engineer`  | Build real-time data streaming pipelines with Kafka/Flink                                |
| `etl-elt-engineer`         | Design ETL/ELT pipelines with modern data stack tools                                    |
| `database-sharding-expert` | Implement database sharding for horizontal scaling                                       |
| `sql-architect`            | Design database schemas, optimize SQL queries, and architect scalable database solutions |
| `postgres-developer`       | Develop PostgreSQL applications using advanced features and performance optimization     |

### Product Management

| Agent                      | Description                                                                     |
| -------------------------- | ------------------------------------------------------------------------------- |
| `business-analyst`         | Analyze business requirements and create process documentation                  |
| `product-owner`            | Define product vision and manage backlog prioritization                         |
| `scrum-master`             | Facilitate Scrum ceremonies and coach agile teams                               |
| `technical-writer`         | Create comprehensive technical documentation and user guides                    |
| `marketing-seo-specialist` | Optimize websites for search engines and implement digital marketing strategies |
| `blog-writer`              | Create engaging, SEO-optimized blog posts with comprehensive research           |

### Quality Assurance

| Agent         | Description                                        |
| ------------- | -------------------------------------------------- |
| `qa-engineer` | Design test strategies and ensure software quality |

### Data Analysis

| Agent            | Description                              |
| ---------------- | ---------------------------------------- |
| `data-scientist` | Data analysis, SQL queries, and insights |

## Installation & Usage

### Quick Setup (Agents + Hooks)

```bash
# Clone the repository
git clone https://github.com/rebelopsio/claude-code-agents.git
cd claude-code-agents

# Run the setup script for hooks (optional but recommended)
./setup-hooks.sh

# Follow the prompts to configure hooks for notifications and enhanced functionality

# For configurations with API keys (e.g., Pushover notifications):
# See SECURE_CONFIGURATION.md for safe credential management
```

### Installing Agents

To use these agents with Claude Code, you need to place them in one of the supported locations as described in the [official sub-agents documentation](https://docs.anthropic.com/en/docs/claude-code/sub-agents):

#### Option 1: Copy Files

```bash
# Clone the repository
git clone https://github.com/rebelopsio/claude-code-agents.git
cd claude-code-agents

# Copy to project-level location (for current project only)
mkdir -p .claude
cp -r agents .claude/

# OR copy to user-level location (for all projects)
mkdir -p ~/.claude
cp -r agents ~/.claude/
```

#### Option 2: Symbolic Links (Recommended)

```bash
# Clone the repository
git clone https://github.com/rebelopsio/claude-code-agents.git

# For project-level (current project only)
ln -s /path/to/claude-code-agents/agents .claude

# OR for user-level (all projects)
ln -s /path/to/claude-code-agents/agents ~/.claude
```

**Note**: Symbolic links are recommended as they keep agents automatically updated when you pull changes from this repository.

### Using Agents

Once installed, you can invoke agents in Claude Code using the Task tool:

```markdown
Please use the rust-systems-engineer agent to help me optimize this concurrent data structure.
```

Or reference them directly:

```markdown
I need the microservices-architect to review this API design.
```

### Agent Structure

Each agent is defined in a markdown file with YAML frontmatter containing:

- **name**: Agent identifier
- **description**: Capabilities and use cases
- **tools**: Available tools (file_read, file_write, bash, web_search)
- **model**: Preferred Claude model (opus, sonnet)

### Example Agent Structure

```yaml
---
name: aws-architect
description: Design AWS cloud architectures, implement Well-Architected Framework principles
tools: file_read, file_write, bash, web_search
model: opus
---
You are an AWS solutions architect specializing in...
```

## Contributing

When adding new agents:

1. Follow the established naming convention: `domain-role.md`
2. Include complete YAML frontmatter
3. Define clear expertise boundaries and behavioral patterns
4. Place in appropriate category directory
5. Update this README with agent details

## Agent Selection Guide

- **Cloud Infrastructure**: Choose based on your cloud provider (AWS/GCP) and specific needs
- **Infrastructure as Code**: Terraform for traditional IaC, Pulumi for modern type-safe IaC
- **Programming Languages**: Select based on your primary development language and platform
- **Design & Frontend**: Use for UI/UX design and modern CSS frameworks
- **Distributed Systems**: For building scalable, resilient distributed architectures
- **DevOps & Monitoring**: Use for operational excellence and code quality
- **Product Management**: For product strategy, requirements, and agile processes
- **Quality Assurance**: For testing strategies and quality processes
- **Data Analysis**: For data science and analytics workflows

Each agent embodies best practices and industry standards for their domain, ensuring consistent, high-quality assistance across all technical areas.
