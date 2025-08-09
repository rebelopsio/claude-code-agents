# /dependency-check

Analyze and optimize project dependencies.

## Usage

```
/dependency-check [options]
```

## Options

- `--audit` - Security audit of dependencies
- `--outdated` - Check for outdated packages
- `--unused` - Find unused dependencies
- `--duplicates` - Find duplicate packages
- `--size` - Analyze bundle size impact
- `--fix` - Auto-fix issues where possible
- `--alternative` - Suggest lighter alternatives

## What it does

1. **Audits dependencies** for security vulnerabilities
2. **Identifies issues**: outdated, unused, duplicated packages
3. **Analyzes impact** on bundle size and performance
4. **Suggests alternatives** and optimizations
5. **Generates report** with actionable fixes

## Example Output

````markdown
## Dependency Analysis Report

### 🚨 Security Vulnerabilities (3)

| Package    | Version | Severity | CVE            | Fix Version |
| ---------- | ------- | -------- | -------------- | ----------- |
| lodash     | 4.17.19 | High     | CVE-2021-23337 | 4.17.21     |
| node-fetch | 2.6.0   | Critical | CVE-2022-0235  | 2.6.7       |
| minimist   | 1.2.0   | Medium   | CVE-2021-44906 | 1.2.6       |

**Fix Command**:

```bash
npm update lodash node-fetch minimist
# or
npm audit fix
```
````

### 📦 Bundle Size Analysis

#### Top 10 Heaviest Dependencies

```
Package          Size      % of Bundle  Alternative
moment          231 KB     18%         date-fns (12 KB)
lodash          71 KB      6%          lodash-es (modular)
jquery          87 KB      7%          vanilla JS
axios           54 KB      4%          native fetch
uuid            21 KB      2%          crypto.randomUUID()
```

**Potential Savings**: 464 KB (37% reduction)

### 🔄 Outdated Packages (12)

| Package    | Current | Latest | Breaking | Update Command             |
| ---------- | ------- | ------ | -------- | -------------------------- |
| react      | 17.0.2  | 18.2.0 | Yes      | `npm install react@latest` |
| next       | 12.1.0  | 13.5.4 | Yes      | See migration guide        |
| typescript | 4.5.2   | 5.2.2  | No       | `npm update typescript`    |

### 🗑️ Unused Dependencies (5)

Found in package.json but never imported:

- `chalk` - Remove with: `npm uninstall chalk`
- `commander` - Remove with: `npm uninstall commander`
- `dotenv` - Already using process.env
- `morgan` - Logging not implemented
- `bcrypt` - Using bcryptjs instead

**Clean Command**:

```bash
npm uninstall chalk commander dotenv morgan bcrypt
```

### 🔁 Duplicate Packages

#### Different Versions of Same Package

```
├─ react@17.0.2
│  └─ react@16.14.0 (via react-dom)
├─ tslib@2.4.0
│  └─ tslib@1.14.1 (via @angular/common)
```

**Resolution**:

```json
// package.json
"overrides": {
  "react": "17.0.2",
  "tslib": "2.4.0"
}
```

### 💡 Optimization Suggestions

#### 1. Replace Heavy Libraries

```javascript
// Before: moment.js (231 KB)
import moment from "moment";
moment().format("YYYY-MM-DD");

// After: date-fns (12 KB)
import { format } from "date-fns";
format(new Date(), "yyyy-MM-dd");

// Savings: 219 KB (95% reduction)
```

#### 2. Use Native Alternatives

```javascript
// Before: uuid package
import { v4 as uuidv4 } from "uuid";
const id = uuidv4();

// After: Native crypto
const id = crypto.randomUUID();

// Savings: 21 KB (100% reduction)
```

#### 3. Tree-Shake Lodash

```javascript
// Before: Full import
import _ from "lodash";
_.debounce(fn, 300);

// After: Specific import
import debounce from "lodash/debounce";
debounce(fn, 300);

// Savings: 65 KB (92% reduction)
```

### 📊 Dependency Metrics

| Metric              | Current | Target  | Status |
| ------------------- | ------- | ------- | ------ |
| Total Dependencies  | 147     | <100    | ⚠️     |
| Direct Dependencies | 42      | <30     | ⚠️     |
| Security Issues     | 3       | 0       | 🔴     |
| Outdated (Major)    | 12      | <5      | 🔴     |
| Bundle Size         | 1.2 MB  | <500 KB | 🔴     |
| Unused              | 5       | 0       | ⚠️     |

### 🎯 Action Plan

#### Immediate (Critical Security)

```bash
# Fix critical vulnerabilities
npm audit fix --force

# Update specific packages
npm install node-fetch@2.6.7 minimist@1.2.6
```

#### Short-term (This Week)

1. Remove unused dependencies (-5 packages)
2. Replace moment with date-fns (-219 KB)
3. Update non-breaking packages

#### Long-term (This Sprint)

1. Migrate to React 18 (requires testing)
2. Upgrade to Next.js 13 (App Router)
3. Implement bundle splitting
4. Set up dependency update automation

### 🤖 Automation Recommendations

```yaml
# .github/workflows/dependency-check.yml
name: Dependency Check
on:
  schedule:
    - cron: "0 0 * * MON"
  pull_request:

jobs:
  audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: npm audit
      - run: npx depcheck
      - run: npm outdated
```

````

## Implementation

```typescript
async function checkDependencies(options: DependencyOptions) {
  // Run various checks
  const [security, outdated, unused, duplicates, sizes] = await Promise.all([
    runSecurityAudit(),
    checkOutdated(),
    findUnusedDependencies(),
    findDuplicates(),
    analyzeBundleSize()
  ]);

  // Analyze with appropriate agent
  const analysis = await invokeAgent('devops-engineer', {
    task: 'analyze-dependencies',
    security,
    outdated,
    unused,
    duplicates,
    sizes
  });

  // Generate optimization suggestions
  const optimizations = await invokeAgent('site-reliability-engineer', {
    task: 'optimize-dependencies',
    analysis
  });

  if (options.fix) {
    const fixes = await applyDependencyFixes(analysis);
    return { analysis, optimizations, fixes };
  }

  return { analysis, optimizations };
}
````

## Related Commands

- `/bundle-analyze` - Detailed bundle analysis
- `/security-scan` - Security-focused scanning
- `/update-deps` - Guided dependency updates
