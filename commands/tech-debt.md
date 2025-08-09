# /tech-debt

Track and manage technical debt across the codebase.

## Usage

```
/tech-debt [action] [options]
```

## Actions

- `scan` - Scan codebase for technical debt
- `track` - Add debt item to backlog
- `prioritize` - Prioritize debt items
- `report` - Generate debt report
- `estimate` - Estimate debt payment effort

## Options

- `--severity critical|high|medium|low`
- `--category architecture|testing|documentation|performance`
- `--cost-analysis` - Include cost/benefit analysis
- `--timeline` - Generate payment timeline
- `--team <name>` - Filter by team ownership

## What it does

1. **Identifies technical debt** through code analysis
2. **Categorizes and tracks** debt items
3. **Estimates impact** on velocity and maintenance
4. **Prioritizes payment** based on ROI
5. **Generates roadmap** for debt reduction

## Example Output

```markdown
## Technical Debt Report

### 💰 Debt Overview

**Total Debt**: 847 hours (106 days)
**Monthly Interest**: 42 hours (5% compound)
**Velocity Impact**: -23%

### 📊 Debt Distribution
```

Category Hours % Total Interest Rate
Architecture 380 45% 8%/month
Testing 210 25% 6%/month  
Documentation 120 14% 3%/month
Performance 85 10% 5%/month
Security 52 6% 10%/month

````

### 🔴 Critical Debt Items

#### 1. Monolithic Database Architecture
**Severity**: Critical
**Effort**: 120 hours
**Impact**: Blocking horizontal scaling
**Interest**: 8% monthly (adding 9.6 hours/month)

**Description**: Single database becoming bottleneck
**Solution**: Implement database sharding
**ROI**: Break even in 2 sprints

**Implementation Plan**:
```yaml
Phase 1: (40h) Design sharding strategy
Phase 2: (40h) Implement shard router
Phase 3: (40h) Migrate data and test
````

#### 2. Missing Test Coverage

**Severity**: High
**Effort**: 80 hours
**Impact**: 15 production bugs/month
**Interest**: 6% monthly

**Uncovered Areas**:

- Payment processing (0% coverage)
- Authentication (23% coverage)
- Data validation (45% coverage)

### 📈 Debt Accumulation Trend

```
Hours
1000 |                    ****
800  |               ****
600  |          ****
400  |     ****
200  | ****
0    |________________________
     Jan  Feb  Mar  Apr  May

Legend: * = Actual debt
        - = Projected without action
```

### 💡 Payment Strategy

#### Sprint 24 (Immediate)

1. **Quick Wins** (16 hours total)
   - Add critical path tests (8h)
   - Document API endpoints (4h)
   - Fix performance hotspots (4h)
   - **ROI**: Saves 4h/week immediately

#### Q2 Priority

1. **Database Sharding** (120h)

   - Prevents future downtime
   - Enables scaling
   - **ROI**: 60h/month after implementation

2. **Test Automation** (80h)
   - Reduces bug rate by 70%
   - Saves 20h/sprint on manual testing
   - **ROI**: 40h/month

### 🎯 Debt Reduction Roadmap

| Quarter | Focus Area    | Investment | Debt Reduced | ROI  |
| ------- | ------------- | ---------- | ------------ | ---- |
| Q2 2024 | Architecture  | 200h       | 380h         | 1.9x |
| Q3 2024 | Testing       | 150h       | 210h         | 1.4x |
| Q4 2024 | Performance   | 80h        | 85h          | 1.1x |
| Q1 2025 | Documentation | 100h       | 120h         | 1.2x |

### 📊 Impact Analysis

**If we pay debt:**

- Velocity increase: +35% by Q4
- Bug rate decrease: -60%
- Developer satisfaction: +40%
- Time to market: -25%

**If we ignore debt:**

- Velocity decrease: -45% by Q4
- Bug rate increase: +120%
- Developer turnover risk: High
- System failure risk: Critical

### 🏷️ Debt Items for Backlog

```typescript
// Generated Linear/Jira tickets
const debtTickets = [
  {
    title: "Refactor authentication module",
    points: 8,
    labels: ["tech-debt", "security"],
    priority: "High",
    description: "Current auth implementation...",
  },
  {
    title: "Add payment service tests",
    points: 5,
    labels: ["tech-debt", "testing"],
    priority: "Critical",
    description: "Zero test coverage for...",
  },
];
```

````

## Implementation

```typescript
async function analyzeTechDebt(action: string, options: DebtOptions) {
  // Scan codebase for debt indicators
  const debtItems = await scanForTechDebt();

  // Analyze with appropriate agent
  const analysis = await invokeAgent('solution-architect', {
    task: 'analyze-tech-debt',
    items: debtItems,
    includeROI: true
  });

  // Generate payment strategy
  const strategy = await invokeAgent('product-owner', {
    task: 'prioritize-debt-payment',
    analysis: analysis,
    constraints: options
  });

  if (action === 'track') {
    await createDebtTickets(strategy.prioritized);
  }

  return { analysis, strategy };
}
````

## Related Commands

- `/refactor` - Refactor specific code
- `/architecture-review` - Architecture analysis
- `/sprint-planning` - Include debt in planning
