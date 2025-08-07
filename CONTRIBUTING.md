# Contributing to Claude Code Agents

Thank you for your interest in contributing to the Claude Code Agents repository! This guide will help you understand how to contribute effectively.

## 🚀 Quick Start

1. **Fork** the repository
2. **Clone** your fork locally
3. **Create** a new branch for your contribution
4. **Make** your changes following our guidelines
5. **Test** your changes locally
6. **Submit** a pull request

## 📋 Types of Contributions

### New Agents

- Specialized agents for specific technologies, frameworks, or domains
- Must fill a gap not covered by existing agents
- Should have clear, non-overlapping expertise boundaries

### Agent Improvements

- Enhanced capabilities or updated best practices
- Bug fixes or corrections
- Performance optimizations

### Documentation

- README updates
- Agent documentation improvements
- Usage examples and guides

### Infrastructure

- CI/CD improvements
- Testing enhancements
- Development tooling

## 🎯 Agent Creation Guidelines

### Naming Convention

- Use **kebab-case** for agent names (e.g., `rust-systems-engineer`)
- Names should be descriptive and specific
- Include the technology/domain and role (e.g., `vue-developer`, `kafka-streaming-engineer`)

### Required Structure

Every agent must have:

```yaml
---
name: agent-name
description: "Clear, concise description of agent capabilities and use cases"
tools: file_read, file_write, bash, web_search # Optional
model: sonnet # or opus
---
Agent content starts here...
```

### Content Requirements

1. **"When invoked:" section** - Clear list of what the agent does
2. **Best practices section** - Domain-specific best practices
3. **Key technologies/tools** - Relevant frameworks, libraries, tools
4. **Patterns and approaches** - Common patterns for the domain
5. **Minimum 100 characters** of substantive content

### Directory Structure

Place agents in the appropriate category:

```
agents/
├── cloud-infrastructure/     # AWS, GCP, Kubernetes
├── infrastructure-as-code/   # Terraform, Pulumi, CDK
├── programming-languages/    # Language-specific agents
├── design-frontend/          # UI/UX, CSS frameworks
├── distributed-systems/      # Microservices, data systems
├── devops-monitoring/        # CI/CD, monitoring, security
└── data-analysis/           # Data science, analytics
```

## ✅ Validation Requirements

All contributions must pass our automated checks:

### YAML Frontmatter

- Valid YAML syntax
- Required fields: `name`, `description`
- Agent name matches filename
- Description between 20-200 characters

### Content Quality

- Minimum 100 characters of content
- Includes "When invoked:" section
- Contains best practices or key practices
- Professional, helpful tone

### File Structure

- Placed in correct category directory
- Follows kebab-case naming
- No duplicate agent names

### Documentation Sync

- New agents added to README.md
- Proper categorization in agent tables

## 🧪 Testing Your Contribution

### Local Validation

Run the validation script locally:

```bash
# Install Python dependencies
pip install pyyaml jsonschema

# Run validation
python .github/scripts/validate_agents.py
```

### Manual Testing

1. **Install agents locally**:

   ```bash
   ln -s /path/to/claude-code-agents/agents ~/.claude/agents
   ```

2. **Test with Claude Code**:
   - Try invoking your agent with sample prompts
   - Verify it stays within its expertise boundaries
   - Ensure it provides helpful, accurate guidance

### Pre-commit Hooks

Set up pre-commit hooks to catch issues early:

```bash
# Install pre-commit
pip install pre-commit

# Install hooks
pre-commit install

# Run manually
pre-commit run --all-files
```

## 📝 Pull Request Process

### Before Submitting

- [ ] Run local validation tests
- [ ] Test agent functionality with Claude Code
- [ ] Update README.md if adding new agents
- [ ] Follow the PR template completely
- [ ] Write clear commit messages

### PR Requirements

1. **Fill out the PR template completely**
2. **Provide clear description** of changes
3. **Include testing evidence** that agent works
4. **Update documentation** as needed
5. **Follow existing patterns** and conventions

### Review Process

1. **Automated checks** must pass (GitHub Actions)
2. **Code review** by maintainers
3. **Testing verification** of agent functionality
4. **Documentation review** for accuracy and clarity
5. **Merge** after approval

## 🎨 Style Guidelines

### Agent Content Style

- **Professional tone** - Clear, helpful, authoritative
- **Action-oriented** - Focus on what the agent does
- **Specific examples** - Include relevant tools, patterns, technologies
- **Structured format** - Use consistent headings and organization
- **No marketing language** - Focus on technical capabilities

### Markdown Formatting

- Use consistent heading levels
- Employ bullet points for lists
- Include code blocks for examples
- Bold important terms and concepts
- Keep lines under 100 characters when possible

## 🔧 Development Setup

### Local Environment

```bash
# Clone the repository
git clone https://github.com/your-username/claude-code-agents.git
cd claude-code-agents

# Install development dependencies
pip install -r requirements-dev.txt

# Install pre-commit hooks
pre-commit install

# Create a new branch
git checkout -b feature/your-agent-name
```

### Recommended Tools

- **VSCode** with YAML extension
- **Python 3.8+** for validation scripts
- **Claude Code** for testing agents
- **Pre-commit** for automated checks

## 🆘 Getting Help

### Questions?

- **GitHub Issues** - Ask questions or report problems
- **GitHub Discussions** - Community discussions and ideas
- **Pull Request Comments** - Get feedback on specific changes

### Common Issues

**Agent validation fails:**

- Check YAML frontmatter syntax
- Ensure name matches filename
- Verify required content sections

**Agent doesn't work in Claude Code:**

- Check agent installation location
- Verify YAML frontmatter is valid
- Test with simple prompts first

**README sync issues:**

- Ensure agent is added to correct table
- Check agent name formatting in README
- Verify table structure is maintained

## 📜 Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help others learn and improve
- Follow GitHub's community guidelines

## 🏆 Recognition

Contributors will be acknowledged in:

- Repository contributors list
- Release notes for significant contributions
- Community recognition for outstanding agents

Thank you for helping make Claude Code Agents better for everyone! 🎉
