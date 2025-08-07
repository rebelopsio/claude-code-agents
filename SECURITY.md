# Security Policy

## Supported Versions

We actively maintain security for the following versions:

| Version  | Supported          |
| -------- | ------------------ |
| Latest   | ✅ Yes             |
| Previous | ⚠️ Limited support |

## Reporting a Vulnerability

If you discover a security vulnerability in this repository, please report it responsibly:

### How to Report

1. **DO NOT** create a public issue for security vulnerabilities
2. **Email** us directly at: [security@example.com] or create a private security advisory
3. **Include** as much detail as possible:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

### What to Expect

- **Acknowledgment** within 48 hours
- **Initial assessment** within 1 week
- **Regular updates** on progress
- **Public disclosure** coordinated with fix release

## Security Considerations

### Agent Content Security

- Agents should not include hardcoded secrets, API keys, or credentials
- Agents should promote security best practices for their domains
- Any code examples should follow secure coding practices

### Repository Security

- All contributions are reviewed before merging
- Automated security scanning via GitHub Actions
- Dependencies are regularly updated for security patches

### User Responsibility

When using these agents:

- **Review agent advice** before implementing in production
- **Follow security best practices** for your specific use case
- **Keep Claude Code updated** to the latest version
- **Report suspicious behavior** or security concerns

## Security Features

- **Automated validation** of agent content
- **Pre-commit hooks** to prevent common security issues
- **Dependency scanning** for development dependencies
- **Regular security updates** and patches

## Disclosure Policy

- Security issues are disclosed publicly **only after** fixes are available
- **CVE numbers** will be assigned for significant vulnerabilities
- **Security advisories** published via GitHub Security Advisories
- **Credits** given to responsible reporters (unless anonymity requested)

## Contact

For security-related questions or concerns:

- Create a private security advisory on GitHub
- Email: [security@example.com] (replace with actual contact)

Thank you for helping keep Claude Code Agents secure!
