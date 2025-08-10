# /gh-workflow-debug

Analyze and troubleshoot GitHub Actions workflow failures with intelligent agent routing.

## Usage

```
/gh-workflow-debug [options]
```

## Options

- `--pr <number>` - Analyze failures for specific pull request
- `--workflow <name>` - Target specific workflow (e.g., "CI", "Deploy")
- `--run-id <id>` - Analyze specific workflow run by ID
- `--branch <name>` - Check failures on specific branch
- `--actor <username>` - Filter by workflow trigger actor
- `--event <type>` - Filter by trigger event (push, pull_request, schedule, etc.)
- `--since <duration>` - Time range (1h, 1d, 1w) for failure analysis
- `--severity critical|high|medium|low` - Focus on specific failure severity
- `--suggest-agent` - Auto-suggest most appropriate troubleshooting agent
- `--fix-suggestions` - Generate immediate fix recommendations
- `--pattern-analysis` - Analyze recurring failure patterns

## What it does

1. **Fetches workflow information** using GitHub CLI or API
2. **Analyzes failure logs** and identifies error patterns
3. **Categorizes failures** by type and severity
4. **Routes to appropriate specialist** based on failure analysis
5. **Provides actionable fix suggestions** and prevention strategies
6. **Tracks failure patterns** across time and workflows

## Agent Routing Logic

The command automatically suggests the most appropriate agent based on failure analysis:

### CI/CD Issues

- **cicd-specialist**: Pipeline configuration, workflow syntax, general CI/CD problems
- **devops-engineer**: Infrastructure automation, deployment pipelines, environment issues

### Container & Deployment Issues

- **container-specialist**: Docker build failures, container runtime errors
- **k8s-deployment-engineer**: Kubernetes deployment failures, manifest issues
- **nextjs-deployment-specialist**: Next.js specific deployment problems

### Code Quality & Testing Issues

- **code-reviewer**: Code quality checks, linting failures, static analysis
- **qa-engineer**: Test failures, coverage issues, test infrastructure
- **debugger**: Complex debugging scenarios requiring multiple language expertise

### Language-Specific Issues

- **go-debugger**: Go compilation, testing, or runtime errors
- **rust-debugger**: Rust build failures, cargo issues, borrow checker errors
- **python-debugger**: Python testing, dependency, or runtime issues
- **javascript-debugger**: Node.js, npm/yarn, or JavaScript runtime errors
- **nextjs-debugger**: Next.js specific build or runtime issues
- **nuxtjs-debugger**: Nuxt.js specific build or runtime issues

### Security & Compliance Issues

- **security-engineer**: Security scans, vulnerability issues, compliance checks
- **pulumi-security-compliance-engineer**: Infrastructure security policy violations

### Infrastructure Issues

- **terraform-architect**: Terraform validation or planning failures
- **pulumi-architect**: Pulumi infrastructure deployment issues
- **aws-architect**: AWS-specific service or permission issues

## Example Output

````markdown
## GitHub Workflow Failure Analysis

**Repository**: myorg/myapp
**Workflow**: CI/CD Pipeline
**Run ID**: 7234567890
**Triggered by**: push to feature/user-auth
**Status**: ❌ Failed (3/5 jobs)
**Duration**: 12m 34s
**Analysis Time**: 2024-03-15 14:25:03 UTC

### 📊 Failure Summary

| Job Name  | Status     | Duration | Error Category    |
| --------- | ---------- | -------- | ----------------- |
| lint      | ✅ Passed  | 1m 23s   | -                 |
| test-unit | ❌ Failed  | 4m 12s   | Test Failures     |
| test-e2e  | ❌ Failed  | 6m 45s   | Container Issues  |
| build     | ⏸️ Skipped | -        | Dependency Failed |
| deploy    | ⏸️ Skipped | -        | Dependency Failed |

### 🔍 Error Analysis

#### Job: test-unit (❌ Failed)

**Error Pattern**: Test failures with database connectivity

```
Error: connect ECONNREFUSED 127.0.0.1:5432
    at TCPConnectWrap.afterConnect [as oncomplete] (node:net:1278:16)
    at /home/runner/work/myapp/myapp/tests/user.test.js:15:24

npm ERR! Test failed. See above for more information.
```

**Analysis**:

- **Category**: Test Infrastructure
- **Root Cause**: PostgreSQL service not running in CI environment
- **Severity**: High (blocking pipeline)
- **Pattern**: New issue (first occurrence)

**Immediate Fix**:

```yaml
# Add to .github/workflows/ci.yml
services:
  postgres:
    image: postgres:14
    env:
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: testdb
    options: >-
      --health-cmd pg_isready
      --health-interval 10s
      --health-timeout 5s
      --health-retries 5
    ports:
      - 5432:5432
```

#### Job: test-e2e (❌ Failed)

**Error Pattern**: Container build failure

```
Error: failed to solve: process "/bin/sh -c npm install --production" did not complete successfully: exit code 1
npm ERR! peer dep missing: react@^18.0.0, required by @testing-library/react@13.4.0
```

**Analysis**:

- **Category**: Container Build
- **Root Cause**: Missing peer dependency in production build
- **Severity**: Medium (affects deployment)
- **Pattern**: Recent regression (started 2 days ago)

**Immediate Fix**:

```dockerfile
# Update Dockerfile
RUN npm install --production --legacy-peer-deps
# OR fix peer dependencies in package.json
```

### 🤖 Recommended Agent Assignment

Based on the failure analysis, I recommend using these agents:

#### Primary Agent: **qa-engineer**

**Reason**: Multiple test infrastructure issues requiring comprehensive testing strategy
**Tasks**:

- Fix database service configuration in CI
- Review test environment setup
- Implement better test isolation
- Add pre-commit hooks for test validation

#### Secondary Agent: **container-specialist**

**Reason**: Container build failures with dependency issues  
**Tasks**:

- Optimize Docker build process
- Fix peer dependency conflicts
- Implement multi-stage builds
- Add container health checks

#### Optional: **cicd-specialist**

**Reason**: Pipeline optimization and workflow improvements
**Tasks**:

- Optimize job dependencies and parallelization
- Add failure notifications and retry policies
- Implement smarter job skipping logic

### 📈 Failure Pattern Analysis

**Recent Trends** (Last 7 days):

- Test failures: ↑ 340% (12 → 41 failures)
- Container issues: ↑ 150% (4 → 10 failures)
- Success rate: ↓ 23% (87% → 64%)

**Common Patterns**:

1. **PostgreSQL connection failures** (15 occurrences)
   - Usually on feature branches
   - Often after dependency updates
2. **Peer dependency conflicts** (8 occurrences)
   - Started after React 18 upgrade
   - Affects e2e test container builds

**Recommendations**:

- Add database connectivity tests before running test suites
- Implement dependency lockfile validation
- Consider using Docker Compose for consistent local/CI environments

### 🛠️ Quick Fix Commands

```bash
# Fix PostgreSQL service in GitHub Actions
gh workflow view ci.yml --repo myorg/myapp
# Then edit .github/workflows/ci.yml to add services section

# Fix peer dependency issues locally
npm install --legacy-peer-deps
npm audit --audit-level moderate

# Test container build locally
docker build -t myapp:test .
docker run --rm myapp:test npm test

# Re-run failed workflow
gh run rerun 7234567890 --failed-jobs
```

### 🔄 Prevention Strategies

1. **Add Pre-commit Hooks**:

```yaml
# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: docker-build-test
        name: Test Docker build
        entry: docker build -t test .
        language: system
        pass_filenames: false
```

2. **Implement Workflow Dependencies Matrix**:

```yaml
# .github/workflows/ci.yml
strategy:
  matrix:
    node-version: [16, 18, 20]
    postgres-version: [13, 14, 15]
```

3. **Add Workflow Status Checks**:

```yaml
# Required status checks in branch protection
- lint
- test-unit
- test-e2e
- security-scan
```

### 📚 Related Documentation

- [GitHub Actions Documentation](https://docs.github.com/actions)
- [Container Testing Best Practices](docs/testing/containers.md)
- [Database Testing Setup](docs/testing/database.md)
- [Debugging CI Failures](docs/ci/debugging.md)

### 🔗 Useful Links

- [Workflow Run Details](https://github.com/myorg/myapp/actions/runs/7234567890)
- [Recent Failure History](https://github.com/myorg/myapp/actions?query=workflow%3ACI%2FCD+event%3Apush)
- [Repository Insights](https://github.com/myorg/myapp/pulse)
````

## Implementation

```typescript
async function debugWorkflow(options: WorkflowDebugOptions) {
  // Fetch workflow data using GitHub CLI or API
  const workflowData = await fetchWorkflowInfo(options);

  // Analyze failure logs and categorize errors
  const analysis = await analyzeFailures(workflowData);

  // Determine most appropriate agent based on failure types
  const recommendedAgent = await routeToAgent(analysis);

  // Generate actionable fix suggestions
  const fixes = await generateFixSuggestions(analysis);

  // Pattern analysis across historical data
  const patterns = await analyzePatterns(options.since);

  return {
    analysis,
    recommendedAgent,
    fixes,
    patterns,
    quickCommands: generateQuickFixes(analysis),
  };
}

function routeToAgent(analysis: FailureAnalysis): string {
  const errorTypes = analysis.categorizedErrors;

  // Priority routing logic
  if (errorTypes.includes("container-build")) {
    return "container-specialist";
  }
  if (errorTypes.includes("test-infrastructure")) {
    return "qa-engineer";
  }
  if (errorTypes.includes("security-scan")) {
    return "security-engineer";
  }
  if (errorTypes.includes("deployment-failure")) {
    return "cicd-specialist";
  }

  // Language-specific routing
  const languages = analysis.detectedLanguages;
  if (languages.includes("go") && errorTypes.includes("compile-error")) {
    return "go-debugger";
  }
  if (languages.includes("rust") && errorTypes.includes("cargo-error")) {
    return "rust-debugger";
  }
  if (languages.includes("javascript") && errorTypes.includes("npm-error")) {
    return "javascript-debugger";
  }

  // Default to general CI/CD specialist
  return "cicd-specialist";
}
```

## Related Commands

- `/incident-analysis` - Post-incident analysis for severe outages
- `/deployment-safety` - Pre-deployment safety checks
- `/code-quality` - Code quality analysis and improvements
- `/security-scan` - Security vulnerability analysis
