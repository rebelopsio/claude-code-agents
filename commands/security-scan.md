# /security-scan

Comprehensive security analysis of your codebase and infrastructure.

## Usage

```
/security-scan [scope] [options]
```

## Scopes

- `code` - Static code analysis for vulnerabilities
- `dependencies` - Check for vulnerable packages
- `secrets` - Scan for exposed secrets and keys
- `infrastructure` - IaC security scanning
- `api` - API security testing
- `full` - Complete security audit

## Options

- `--severity critical|high|medium|low` - Minimum severity to report
- `--fix` - Generate fixes for vulnerabilities
- `--compliance OWASP|PCI|SOC2` - Check compliance standards
- `--ignore-file <path>` - Path to .securityignore file
- `--output sarif|json|markdown` - Output format

## What it does

1. **Scans for vulnerabilities**:
   - SQL injection risks
   - XSS vulnerabilities
   - Authentication bypasses
   - Insecure dependencies
   - Exposed secrets
2. **Checks compliance** with security standards
3. **Generates fixes** with secure code examples
4. **Creates security report** with prioritized actions

## Example Output

````markdown
## Security Scan Report

### 🚨 Critical Vulnerabilities (2)

#### 1. SQL Injection in UserController

**File**: `api/controllers/UserController.js:45`
**Severity**: Critical
**CWE**: CWE-89
**OWASP**: A03:2021 – Injection

**Vulnerable Code**:

```javascript
const query = `SELECT * FROM users WHERE id = ${userId}`;
db.query(query);
```
````

**Fixed Code**:

```javascript
const query = "SELECT * FROM users WHERE id = ?";
db.query(query, [userId]);
```

#### 2. Hardcoded API Key

**File**: `config/services.js:12`
**Severity**: Critical
**Type**: Secret Exposure

**Found**:

```javascript
const API_KEY = "sk_live_4242424242424242";
```

**Fix**:

```javascript
const API_KEY = process.env.STRIPE_API_KEY;
// Add to .env: STRIPE_API_KEY=sk_live_xxx
```

### ⚠️ High Risk Issues (5)

#### Vulnerable Dependencies

| Package | Current | Vulnerable | Fixed   | CVE            |
| ------- | ------- | ---------- | ------- | -------------- |
| express | 4.16.0  | Yes        | 4.18.2  | CVE-2022-24999 |
| lodash  | 4.17.19 | Yes        | 4.17.21 | CVE-2021-23337 |

**Fix Command**:

```bash
npm update express lodash
```

#### Missing Security Headers

**Affected**: All API endpoints
**Missing Headers**:

- X-Frame-Options
- X-Content-Type-Options
- Content-Security-Policy
- Strict-Transport-Security

**Fix Implementation**:

```javascript
// middleware/security.js
import helmet from "helmet";

app.use(
  helmet({
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        styleSrc: ["'self'", "'unsafe-inline'"],
        scriptSrc: ["'self'"],
        imgSrc: ["'self'", "data:", "https:"],
      },
    },
    hsts: {
      maxAge: 31536000,
      includeSubDomains: true,
      preload: true,
    },
  }),
);
```

### 📊 Security Score

| Category           | Score      | Grade |
| ------------------ | ---------- | ----- |
| Code Security      | 65/100     | D     |
| Dependencies       | 45/100     | F     |
| Secrets Management | 80/100     | B     |
| Infrastructure     | 75/100     | C     |
| **Overall**        | **66/100** | **D** |

### 🔒 Compliance Status

#### OWASP Top 10 Coverage

- ✅ A01:2021 - Broken Access Control
- ❌ A02:2021 - Cryptographic Failures
- ❌ A03:2021 - Injection
- ✅ A04:2021 - Insecure Design
- ❌ A05:2021 - Security Misconfiguration

### 📋 Remediation Plan

#### Immediate (Fix Today)

1. Remove hardcoded API keys
2. Update vulnerable dependencies
3. Fix SQL injection vulnerability

#### Short-term (This Week)

1. Implement security headers
2. Add input validation
3. Set up secret scanning in CI

#### Long-term (This Month)

1. Implement rate limiting
2. Add security monitoring
3. Conduct penetration testing

````

## Implementation

```typescript
async function securityScan(scope: string, options: SecurityOptions) {
  const scanners = {
    code: 'security-engineer',
    dependencies: 'devops-engineer',
    secrets: 'security-engineer',
    infrastructure: 'terraform-architect',
    api: 'security-engineer'
  };

  const agent = scanners[scope] || 'security-engineer';

  const vulnerabilities = await invokeAgent(agent, {
    task: 'security-scan',
    scope: scope,
    severity: options.severity,
    compliance: options.compliance
  });

  if (options.fix) {
    const fixes = await generateSecurityFixes(vulnerabilities);
    return { vulnerabilities, fixes };
  }

  return vulnerabilities;
}
````

## Related Commands

- `/secret-scan` - Deep scan for secrets
- `/dependency-audit` - Audit dependencies
- `/pentest` - Penetration testing simulation
