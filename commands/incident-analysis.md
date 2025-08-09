# /incident-analysis

Post-incident analysis and prevention recommendations.

## Usage

```
/incident-analysis [incident-id] [options]
```

## Options

- `--severity P0|P1|P2|P3` - Incident severity level
- `--timeline` - Generate detailed timeline
- `--rca` - Root cause analysis
- `--blast-radius` - Impact assessment
- `--prevention` - Prevention recommendations
- `--runbook` - Generate runbook for future

## What it does

1. **Reconstructs incident timeline** from logs and metrics
2. **Performs root cause analysis** using 5-whys
3. **Assesses impact** on users and systems
4. **Identifies contributing factors**
5. **Generates prevention plan** and runbooks

## Example Output

````markdown
## Incident Analysis: INC-2024-0145

### 📋 Incident Summary

**Title**: Database Connection Pool Exhaustion
**Severity**: P1 (Critical)
**Duration**: 2h 15m (14:23 - 16:38 UTC)
**Impact**: 47% of users experienced errors
**Revenue Loss**: ~$23,400

### ⏱️ Timeline

```mermaid
timeline
    title Incident Timeline INC-2024-0145

    14:23 : First error spike detected
    14:28 : Automated alert triggered
    14:35 : On-call engineer acknowledged
    14:42 : Initial investigation started
    14:55 : Database team engaged
    15:10 : Root cause identified
    15:15 : Mitigation started
    15:30 : Partial recovery
    16:15 : Full recovery
    16:38 : Incident resolved
```
````

**Detailed Timeline**:

| Time  | Event                         | Actor       | Impact               |
| ----- | ----------------------------- | ----------- | -------------------- |
| 14:23 | Connection pool hits 100%     | System      | Errors begin         |
| 14:28 | Alert: "DB connections maxed" | PagerDuty   | Team notified        |
| 14:35 | John acknowledges alert       | On-call     | Response started     |
| 14:42 | Checks application logs       | John        | Found timeout errors |
| 14:55 | Database team joins           | DBA Team    | Expertise added      |
| 15:10 | Identifies stuck queries      | Sarah (DBA) | Root cause found     |
| 15:15 | Kills stuck transactions      | Sarah       | Mitigation begins    |
| 15:30 | Connection pool recovering    | System      | 50% recovery         |
| 16:15 | All systems normal            | System      | Full recovery        |
| 16:38 | Monitoring confirms stable    | John        | Incident closed      |

### 🔍 Root Cause Analysis

**Direct Cause**: Database connection pool exhaustion

**5-Whys Analysis**:

1. **Why did connections exhaust?**
   → Long-running queries weren't releasing connections

2. **Why were queries long-running?**
   → Missing index on orders.customer_id after schema change

3. **Why was index missing?**
   → Migration script failed silently in production

4. **Why did migration fail silently?**
   → No post-migration validation checks

5. **Why no validation?**
   → Migration process lacks automated verification

**Root Cause**: Inadequate migration validation process

### 🌊 Blast Radius

**Systems Affected**:

- ✅ Order Service (100% degraded)
- ✅ Payment Service (87% degraded)
- ✅ User Service (45% degraded)
- ⚪ Notification Service (0% - async)
- ⚪ Analytics Service (0% - separate DB)

**User Impact**:

```
Affected Users: 34,521 (47%)
Failed Transactions: 1,234
Lost Orders: 456
Support Tickets: 89
```

**Business Impact**:

- Revenue Loss: $23,400
- SLA Breach: 99.9% → 99.2% for month
- Customer Churn Risk: 12 enterprise customers affected
- Brand Impact: 3 negative social media mentions

### 🔬 Contributing Factors

1. **Technical Factors**

   - No connection pool monitoring alerts
   - Default pool size too small (100)
   - No query timeout configured
   - Missing database migration validation

2. **Process Factors**

   - No staged rollout for schema changes
   - Insufficient load testing
   - Runbook outdated (last updated 6 months ago)

3. **Human Factors**
   - DBA team not included in migration review
   - On-call engineer unfamiliar with database issues
   - Communication delay (12 min to engage DBA)

### 🛡️ Prevention Recommendations

#### Immediate Actions (This Week)

1. **Add Missing Index**

   ```sql
   CREATE INDEX idx_orders_customer_id
   ON orders(customer_id)
   WHERE deleted_at IS NULL;
   ```

2. **Increase Connection Pool**

   ```yaml
   database:
     pool:
       min: 20
       max: 200 # was 100
       timeout: 5000ms # was unlimited
   ```

3. **Add Monitoring**
   ```typescript
   // Add to monitoring config
   alerts: [
     {
       metric: "db.connections.active",
       threshold: 0.8,
       severity: "warning",
     },
     {
       metric: "db.query.duration.p99",
       threshold: 1000,
       severity: "critical",
     },
   ];
   ```

#### Short-term (Next Sprint)

1. **Migration Validation Framework**

   ```typescript
   class MigrationValidator {
     async validate(migration: Migration) {
       await this.checkIndexes();
       await this.checkQueryPerformance();
       await this.checkConstraints();
       await this.runSmokeTests();
     }
   }
   ```

2. **Automated Rollback**
   ```yaml
   migrations:
     auto_rollback: true
     health_check_interval: 60s
     rollback_threshold:
       error_rate: 0.05
       latency_p99: 2000ms
   ```

#### Long-term (Next Quarter)

1. **Database Reliability Improvements**

   - Implement read replicas
   - Add connection pooler (PgBouncer)
   - Query performance regression tests
   - Automated index recommendations

2. **Incident Response Improvements**
   - Chaos engineering exercises
   - Quarterly incident response training
   - Automated runbook execution
   - Better observability stack

### 📘 Generated Runbook

````markdown
## Runbook: Database Connection Pool Exhaustion

### Detection

- Alert: "Database connection pool > 80%"
- Symptoms: Timeout errors, 500 responses

### Immediate Response

1. Check active connections:
   ```sql
   SELECT count(*) FROM pg_stat_activity;
   ```
````

2. Identify long-running queries:

   ```sql
   SELECT pid, now() - pg_stat_activity.query_start AS duration, query
   FROM pg_stat_activity
   WHERE state != 'idle'
   ORDER BY duration DESC;
   ```

3. Kill stuck queries if safe:
   ```sql
   SELECT pg_terminate_backend(pid);
   ```

### Mitigation

1. Increase connection pool temporarily
2. Enable read replica for reads
3. Implement circuit breaker

### Escalation

- 15 min: Page database team
- 30 min: Page service owners
- 45 min: Incident commander

```

### 📊 Metrics & KPIs

| Metric | Current | Target | Action |
|--------|---------|--------|--------|
| MTTD (Detect) | 5 min | 2 min | Better alerting |
| MTTA (Acknowledge) | 7 min | 5 min | OK |
| MTTR (Resolve) | 2h 15m | 30 min | Need automation |
| Incidents/Month | 3 | <1 | Improve testing |

### ✅ Action Items

- [ ] @DBA-Team: Add missing index (Due: Today)
- [ ] @Platform: Update connection pool config (Due: Tomorrow)
- [ ] @Platform: Implement migration validator (Due: Sprint 24)
- [ ] @SRE: Update monitoring alerts (Due: This week)
- [ ] @All: Review and update runbooks (Due: Sprint 24)
- [ ] @Leadership: Schedule blameless postmortem (Due: This week)
```

## Implementation

```typescript
async function analyzeIncident(incidentId: string, options: IncidentOptions) {
  // Gather incident data
  const incident = await gatherIncidentData(incidentId);

  // Perform root cause analysis
  const rca = await invokeAgent("site-reliability-engineer", {
    task: "root-cause-analysis",
    incident: incident,
    includeFiveWhys: true,
  });

  // Assess impact
  const impact = await invokeAgent("business-analyst", {
    task: "assess-incident-impact",
    incident: incident,
    includeRevenue: true,
  });

  // Generate prevention plan
  const prevention = await invokeAgent("devops-engineer", {
    task: "create-prevention-plan",
    rca: rca,
    generateRunbook: options.runbook,
  });

  return { incident, rca, impact, prevention };
}
```

## Related Commands

- `/postmortem` - Generate postmortem document
- `/chaos-test` - Run chaos engineering tests
- `/monitoring-gaps` - Identify monitoring blind spots
