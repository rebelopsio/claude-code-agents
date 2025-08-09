# /deployment-safety

Pre-deployment safety checks and risk assessment.

## Usage

```
/deployment-safety [environment] [options]
```

## Environments

- `production` - Production deployment checks
- `staging` - Staging environment checks
- `canary` - Canary deployment analysis
- `blue-green` - Blue-green deployment validation

## Options

- `--service <name>` - Specific service to deploy
- `--version <tag>` - Version/tag to deploy
- `--rollback-plan` - Generate rollback plan
- `--dependencies` - Check dependent services
- `--traffic-analysis` - Analyze current traffic
- `--risk-score` - Calculate deployment risk

## What it does

1. **Performs safety checks** before deployment
2. **Analyzes deployment risks** and dependencies
3. **Validates rollback capability**
4. **Checks system health** and capacity
5. **Generates go/no-go recommendation**

## Example Output

```markdown
## Deployment Safety Check

**Service**: payment-service
**Version**: v2.4.0 → v2.5.0
**Environment**: Production
**Time**: Friday, 15:45 UTC

### 🚦 Deployment Decision: PROCEED WITH CAUTION ⚠️

**Risk Score**: 6.8/10 (Medium-High)
**Confidence**: 73%

### ✅ Passed Checks (12/15)

1. **Build Status**: All tests passing (847/847)
2. **Staging Validation**: 72 hours stable in staging
3. **Rollback Tested**: Rollback successful in staging
4. **Dependencies Healthy**: All upstream services green
5. **Resource Capacity**: 45% CPU, 52% Memory available
6. **No Active Incidents**: Clear for 7 days
7. **Change Freeze**: Not in freeze period
8. **Feature Flags**: All flags configured correctly
9. **Database Migrations**: Backward compatible
10. **Config Validation**: All configs verified
11. **Monitoring**: Alerts and dashboards ready
12. **Team Availability**: 3/4 team members online

### ⚠️ Warning Checks (2/15)

#### High Traffic Period

**Risk**: Deploying during peak hours
**Current Traffic**: 8,500 req/s (85% of peak)
**Recommendation**: Wait 2 hours for traffic to decrease
```

Traffic Pattern (Last 24h):
req/s
10K | \***\*
8K | ** ** ← Current
6K |** **
4K | \*\***
2K |**\*\***\_\_\_\_**\*\***
00:00 12:00 24:00

```

#### Recent Deployment
**Risk**: Multiple deployments in short period
**Last Deployment**: 3 hours ago (user-service)
**Recommendation**: Allow system to stabilize

### 🔴 Failed Checks (1/15)

#### Canary Analysis Failed
**Issue**: Higher error rate in canary (2.1% vs 0.8%)
**Details**:
```

Canary Metrics (30 min):

- Error Rate: 2.1% (baseline: 0.8%)
- P99 Latency: 450ms (baseline: 320ms)
- Success Rate: 97.9% (baseline: 99.2%)

```
**Action Required**: Investigate canary issues before proceeding

### 📊 Risk Analysis

#### Change Risk Assessment
```

Component Changes Risk Details
API Endpoints +3 Low New endpoints, backward compatible
Database Schema +2 Med New columns, nullable
Dependencies +5 High Major version updates
Configuration +8 Med New feature flags added
Business Logic +127 High Payment flow modifications

````

#### Dependency Impact
```mermaid
graph TD
    PS[Payment Service v2.5.0]
    US[User Service]
    OS[Order Service]
    NS[Notification Service]
    AS[Analytics Service]

    PS -->|Breaking| OS
    PS -->|Compatible| US
    PS -->|Compatible| NS
    OS -->|Affected| AS

    style PS fill:#f9f,stroke:#333,stroke-width:4px
    style OS fill:#faa,stroke:#333,stroke-width:2px
````

### 🎯 Deployment Strategy

**Recommended Approach**: Progressive Rollout

```yaml
stages:
  - name: Canary
    traffic: 5%
    duration: 30m
    success_criteria:
      error_rate: <1%
      p99_latency: <400ms

  - name: Early Adopters
    traffic: 25%
    duration: 1h
    success_criteria:
      error_rate: <1%
      p99_latency: <380ms

  - name: Half
    traffic: 50%
    duration: 2h
    monitoring: enhanced

  - name: Full
    traffic: 100%
    monitoring: standard
```

### 🔄 Rollback Plan

**Rollback Triggers**:

- Error rate > 2%
- P99 latency > 500ms
- 500 errors > 100/min
- Database connection errors

**Rollback Procedure**:

```bash
# Automatic rollback (< 5 min)
kubectl rollout undo deployment/payment-service

# Manual rollback with verification
./scripts/rollback.sh payment-service v2.4.0 --verify

# Database rollback if needed
flyway undo -target=2.4.0
```

**Rollback Time**: 3-5 minutes
**Data Loss Risk**: None (backward compatible)

### 📋 Pre-Deployment Checklist

- [x] Code review completed
- [x] Security scan passed
- [x] Load testing completed
- [x] Documentation updated
- [x] Runbooks updated
- [ ] **Customer notification sent** ⚠️
- [x] Rollback tested
- [ ] **Canary metrics acceptable** ❌
- [x] Team briefed
- [x] Monitoring dashboard ready

### 🚨 Current System State

| Metric        | Current | Normal | Status |
| ------------- | ------- | ------ | ------ |
| CPU Usage     | 55%     | 40-60% | ✅     |
| Memory        | 48%     | 45-65% | ✅     |
| Error Rate    | 0.8%    | <1%    | ✅     |
| P99 Latency   | 320ms   | <350ms | ✅     |
| Active Alerts | 0       | 0      | ✅     |
| Queue Depth   | 1,234   | <2000  | ✅     |

### 💡 Recommendations

1. **Fix Canary Issues First**

   - Investigate 2.1% error rate
   - May be related to new payment provider integration
   - Check logs for specific error patterns

2. **Wait for Lower Traffic**

   - Deploy after 18:00 UTC (2 hours)
   - Traffic will be 40% lower
   - More capacity for handling issues

3. **Enhanced Monitoring**

   ```javascript
   // Add temporary detailed logging
   logger.setLevel("DEBUG");
   metrics.enableDetailedTracking({
     service: "payment-service",
     duration: "4h",
     samples: 0.1, // 10% sampling
   });
   ```

4. **Team Preparation**
   - Ensure DBA is available (database changes)
   - Have payment team on standby
   - Prepare customer support for potential issues

### 🎮 Deployment Command

Once all issues are resolved:

```bash
# Safe deployment with automatic checks
./deploy.sh \
  --service payment-service \
  --version v2.5.0 \
  --environment production \
  --strategy progressive \
  --rollback-on-error \
  --max-error-rate 1.5 \
  --require-approval \
  --notify-channels "#deployments,#oncall"
```

````

## Implementation

```typescript
async function checkDeploymentSafety(env: string, options: SafetyOptions) {
  // Run safety checks
  const checks = await runSafetyChecks(env, options);

  // Analyze with SRE agent
  const analysis = await invokeAgent('site-reliability-engineer', {
    task: 'deployment-risk-assessment',
    checks: checks,
    environment: env,
    service: options.service
  });

  // Generate deployment strategy
  const strategy = await invokeAgent('devops-engineer', {
    task: 'deployment-strategy',
    analysis: analysis,
    generateRollback: options.rollbackPlan
  });

  // Calculate go/no-go recommendation
  const decision = calculateDeploymentDecision(analysis, strategy);

  return { checks, analysis, strategy, decision };
}
````

## Related Commands

- `/canary-analysis` - Detailed canary metrics
- `/rollback` - Execute rollback procedure
- `/traffic-shape` - Traffic shaping for deployment
