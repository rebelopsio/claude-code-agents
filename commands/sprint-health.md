# /sprint-health

Monitor sprint health and predict potential issues.

## Usage

```
/sprint-health [options]
```

## Options

- `--team <name>` - Specific team's sprint
- `--sprint current|next|<id>` - Sprint to analyze (default: current)
- `--alert-threshold <percent>` - Risk threshold for alerts
- `--suggest-actions` - Generate action items
- `--daily` - Show daily burndown analysis

## What it does

1. **Analyzes sprint metrics** in real-time
2. **Identifies risks** and blockers
3. **Predicts completion** likelihood
4. **Suggests interventions** to stay on track
5. **Generates health report** with actionable insights

## Example Output

```markdown
## Sprint Health Report - Sprint 23

### 🏃 Sprint Overview

- **Day**: 7 of 10 (70% complete)
- **Points Completed**: 21 of 34 (62%)
- **Health Score**: 72/100 ⚠️

### 📊 Burndown Analysis
```

Points
35 |●
30 | ●------- Ideal
25 | ● -------  
20 | ●\***\* --- Actual
15 | \*\***
10 | \***_
5 | _**
0 |\***\*\*\*\*\***\_\_\***\*\*\*\*\***|
0 2 4 6 8 10 Days

```

**Projection**: 85% likely to complete on time

### 🚨 Risk Indicators

#### High Risk Items
1. **#234: Refactor authentication** (8 points)
   - Status: In Progress for 4 days
   - Blocker: Waiting on security review
   - Impact: 24% of sprint capacity
   - Action: Escalate security review today

2. **#456: Payment integration** (5 points)
   - Status: Not Started
   - Dependency: Blocked by #234
   - Risk: May not complete
   - Action: Consider moving to next sprint

### 📈 Team Velocity

| Developer | Committed | Completed | In Progress | At Risk |
|-----------|-----------|-----------|-------------|---------|
| Alice | 8 pts | 6 pts | 2 pts | - |
| Bob | 10 pts | 4 pts | 3 pts | 3 pts 🔴 |
| Carol | 8 pts | 7 pts | 1 pts | - |
| David | 8 pts | 4 pts | 4 pts | - |

### 🔄 Flow Metrics

| Stage | Items | Avg Time | Bottleneck |
|-------|-------|----------|------------|
| To Do | 3 | - | - |
| In Progress | 5 | 2.3 days | ⚠️ Above target |
| Review | 2 | 0.5 days | ✅ |
| Testing | 1 | 1 day | ✅ |
| Done | 8 | - | - |

### 💊 Health Indicators

| Metric | Status | Trend | Notes |
|--------|--------|-------|-------|
| Scope Creep | ✅ | → | No new items added |
| Blockers | ⚠️ | ↗ | 2 new blockers today |
| Team Morale | ✅ | → | Based on standup sentiment |
| Technical Debt | ⚠️ | ↗ | 3 items deferred |
| Bug Rate | ✅ | ↘ | 2 bugs vs 5 last sprint |

### 🎯 Recommended Actions

#### Immediate (Today)
1. **Unblock #234**: Schedule emergency security review
2. **Pair Programming**: Bob needs help with #456
3. **Scope Review**: Consider dropping #789 (nice-to-have)

#### Tomorrow's Focus
1. Complete testing for #123, #125
2. Start #567 to maintain velocity
3. Update estimates for remaining items

#### Risk Mitigation
- **If security review delayed**: Move #234 to next sprint
- **If Bob remains blocked**: Redistribute 3 points to Carol
- **Buffer available**: 2 points can be added if needed

### 📝 Daily Standup Topics

1. Bob's blockers on payment integration
2. Security review escalation
3. Testing bottleneck prevention
4. Sprint goal feasibility check

### 🏁 Sprint Completion Forecast

**Scenarios**:
- **Best Case** (95%): Complete all committed items
- **Likely** (70%): Complete 30 of 34 points
- **Worst Case** (35%): Complete 25 points, carry over 9

**Recommendation**: Consider early de-scoping of #789 (3 points) to ensure core deliverables complete.
```

## Implementation

```typescript
async function analyzeSprintHealth(options: SprintOptions) {
  // Fetch sprint data
  const sprint = await getSprintData(options);

  // Analyze with scrum-master agent
  const analysis = await invokeAgent("scrum-master", {
    task: "analyze-sprint-health",
    sprint: sprint,
    includeVelocity: true,
    predictCompletion: true,
  });

  // Get team insights
  const teamHealth = await invokeAgent("site-reliability-engineer", {
    task: "analyze-team-metrics",
    sprint: sprint,
  });

  // Generate recommendations
  if (options.suggestActions) {
    const actions = await generateActionItems(analysis, teamHealth);
    return { analysis, actions };
  }

  return analysis;
}
```

## Related Commands

- `/burndown` - Detailed burndown chart
- `/velocity` - Team velocity trends
- `/retrospective` - Sprint retrospective analysis
