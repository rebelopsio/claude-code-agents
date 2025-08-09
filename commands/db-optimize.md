# /db-optimize

Database performance optimization and query analysis.

## Usage

```
/db-optimize [database] [options]
```

## Databases

- `postgres` - PostgreSQL optimization
- `mysql` - MySQL/MariaDB optimization
- `mongodb` - MongoDB optimization
- `redis` - Redis optimization
- `all` - Analyze all databases

## Options

- `--slow-queries` - Analyze slow query log
- `--indexes` - Index optimization
- `--query-plan` - Query execution plans
- `--schema` - Schema optimization
- `--connections` - Connection pool analysis
- `--auto-fix` - Apply safe optimizations

## What it does

1. **Analyzes query performance** and patterns
2. **Identifies missing indexes** and unused ones
3. **Optimizes schema design** and data types
4. **Suggests query rewrites** for better performance
5. **Generates optimization plan** with impact analysis

## Example Output

````markdown
## Database Optimization Report

**Database**: PostgreSQL 14.5
**Size**: 847 GB
**Connections**: 145/200 active
**Cache Hit Rate**: 94.2%

### 🐌 Top Slow Queries

#### 1. Order History Query

**Frequency**: 1,240 calls/hour
**Avg Duration**: 3.4s (P99: 8.2s)
**Total Time**: 70% of database load

**Current Query**:

```sql
SELECT o.*, u.name, u.email,
       p.name as product_name,
       oi.quantity, oi.price
FROM orders o
JOIN users u ON o.user_id = u.id
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id
WHERE o.created_at > NOW() - INTERVAL '30 days'
  AND o.status != 'cancelled'
ORDER BY o.created_at DESC;
```
````

**Query Plan Issue**:

```
Seq Scan on orders (cost=0.00..123567.45 rows=500000)
  Filter: created_at > NOW() - INTERVAL '30 days'
  -> Nested Loop (cost=845.23..23456.78)
    -> Seq Scan on order_items
```

**Optimized Query**:

```sql
-- Add covering index first
CREATE INDEX idx_orders_recent
ON orders(created_at DESC, status)
INCLUDE (user_id)
WHERE status != 'cancelled';

-- Rewritten query with CTE
WITH recent_orders AS (
  SELECT * FROM orders
  WHERE created_at > NOW() - INTERVAL '30 days'
    AND status != 'cancelled'
  ORDER BY created_at DESC
  LIMIT 1000
)
SELECT /* parallel */
  o.*, u.name, u.email,
  array_agg(
    json_build_object(
      'product', p.name,
      'quantity', oi.quantity,
      'price', oi.price
    )
  ) as items
FROM recent_orders o
JOIN users u ON o.user_id = u.id
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id
GROUP BY o.id, u.name, u.email;
```

**Expected Improvement**: 3.4s → 0.12s (96% faster)

### 📊 Index Analysis

#### Missing Indexes (High Impact)

```sql
-- 1. Composite index for user queries
CREATE INDEX CONCURRENTLY idx_users_email_status
ON users(email, status)
WHERE deleted_at IS NULL;
-- Impact: 2,340 queries/hour improved by 78%

-- 2. Partial index for active orders
CREATE INDEX CONCURRENTLY idx_orders_user_active
ON orders(user_id, created_at DESC)
WHERE status IN ('pending', 'processing', 'shipped');
-- Impact: 890 queries/hour improved by 65%

-- 3. GIN index for JSONB search
CREATE INDEX CONCURRENTLY idx_products_attributes
ON products USING gin(attributes);
-- Impact: 450 queries/hour improved by 92%
```

#### Unused Indexes (Safe to Drop)

```sql
-- These indexes haven't been used in 30 days
DROP INDEX idx_old_temp_1;  -- 2.3 GB savings
DROP INDEX idx_legacy_col;  -- 1.1 GB savings
DROP INDEX idx_duplicate_2; -- 890 MB savings
-- Total space savings: 4.3 GB
```

#### Index Bloat

```
Index Name                Size    Bloat   Action
idx_orders_created_at     4.2GB   67%     REINDEX
idx_users_email          2.1GB   45%     REINDEX
idx_products_sku         1.3GB   23%     Monitor
```

### 🗂️ Schema Optimizations

#### 1. Data Type Optimizations

```sql
-- Change VARCHAR to TEXT (PostgreSQL)
ALTER TABLE posts
ALTER COLUMN content TYPE TEXT;
-- Saves 15% storage, no length checking overhead

-- Use appropriate numeric types
ALTER TABLE products
ALTER COLUMN price TYPE DECIMAL(10,2);
-- Was: DOUBLE PRECISION (unnecessary precision)

-- Add ENUM for status fields
CREATE TYPE order_status AS ENUM (
  'pending', 'processing', 'shipped', 'delivered', 'cancelled'
);
ALTER TABLE orders
ALTER COLUMN status TYPE order_status
USING status::order_status;
-- Saves 85% on status column storage
```

#### 2. Partitioning Strategy

```sql
-- Partition large orders table by month
CREATE TABLE orders_2024_01 PARTITION OF orders
FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

CREATE TABLE orders_2024_02 PARTITION OF orders
FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');

-- Auto-partition creation
CREATE OR REPLACE FUNCTION create_monthly_partition()
RETURNS void AS $$
DECLARE
  partition_name TEXT;
  start_date DATE;
  end_date DATE;
BEGIN
  start_date := DATE_TRUNC('month', NOW());
  end_date := start_date + INTERVAL '1 month';
  partition_name := 'orders_' || TO_CHAR(start_date, 'YYYY_MM');

  EXECUTE format(
    'CREATE TABLE IF NOT EXISTS %I PARTITION OF orders
     FOR VALUES FROM (%L) TO (%L)',
    partition_name, start_date, end_date
  );
END;
$$ LANGUAGE plpgsql;
```

### 🔄 Connection Pool Optimization

**Current Settings**:

```yaml
pool:
  min: 10
  max: 200
  idle_timeout: 10s
  connection_timeout: 30s
```

**Recommended Settings**:

```yaml
pool:
  min: 25 # Increased (was 10)
  max: 150 # Decreased (was 200)
  idle_timeout: 60s # Increased (was 10s)
  connection_timeout: 5s # Decreased (was 30s)
  statement_timeout: 30s # New
  idle_in_transaction_timeout: 60s # New
```

**Reasoning**:

- Fewer max connections reduces memory usage
- Longer idle timeout reduces connection churn
- Statement timeout prevents runaway queries

### 💾 Cache Optimization

#### Query Cache Analysis

```
Cache Type      Hit Rate   Size     Recommendation
Shared Buffer   94.2%      8GB      Increase to 12GB
Work Mem        78.3%      4MB      Increase to 8MB
Temp Buffers    45.6%      8MB      Increase to 16MB
```

**Configuration Changes**:

```sql
-- postgresql.conf
shared_buffers = 12GB          # was 8GB
effective_cache_size = 36GB    # was 24GB
work_mem = 8MB                 # was 4MB
maintenance_work_mem = 2GB     # was 1GB
```

### 📈 Performance Metrics

**Before Optimization**:

- Avg Query Time: 245ms
- P99 Query Time: 3.4s
- Queries/Second: 4,500
- CPU Usage: 78%
- I/O Wait: 35%

**After Optimization** (Projected):

- Avg Query Time: 67ms (-73%)
- P99 Query Time: 450ms (-87%)
- Queries/Second: 12,000 (+167%)
- CPU Usage: 45% (-42%)
- I/O Wait: 12% (-66%)

### 🚀 Implementation Plan

#### Phase 1: Quick Wins (Today)

```bash
# 1. Add missing indexes
psql -f add_missing_indexes.sql

# 2. Update connection pool
kubectl apply -f db-pool-config.yaml

# 3. Vacuum and analyze
vacuumdb --analyze --verbose -d production
```

#### Phase 2: Query Optimization (This Week)

- Rewrite top 10 slow queries
- Implement query result caching
- Add database proxy (PgBouncer)

#### Phase 3: Schema Changes (Next Sprint)

- Implement partitioning
- Data type optimizations
- Archive old data

### ⚠️ Risks and Mitigations

| Change         | Risk                 | Mitigation                |
| -------------- | -------------------- | ------------------------- |
| New Indexes    | Lock during creation | Use CONCURRENTLY          |
| Query Rewrites | Different results    | Extensive testing         |
| Partitioning   | Application changes  | Backward compatible views |
| Cache increase | Memory pressure      | Gradual rollout           |

### 📊 Monitoring Dashboard

```sql
-- Create monitoring view
CREATE VIEW db_health AS
SELECT
  NOW() as checked_at,
  (SELECT count(*) FROM pg_stat_activity) as connections,
  (SELECT count(*) FROM pg_stat_activity WHERE state = 'active') as active_queries,
  (SELECT avg(duration) FROM pg_stat_statements) as avg_query_ms,
  pg_database_size('production')/1024/1024/1024 as size_gb,
  (SELECT sum(idx_scan) FROM pg_stat_user_indexes) as index_scans,
  (SELECT sum(seq_scan) FROM pg_stat_user_tables) as seq_scans;
```

````

## Implementation

```typescript
async function optimizeDatabase(database: string, options: OptimizeOptions) {
  // Analyze database performance
  const analysis = await analyzeDatabasePerformance(database);

  // Get optimization recommendations
  const optimizations = await invokeAgent('postgres-developer', {
    task: 'optimize-database',
    analysis: analysis,
    includeIndexes: options.indexes,
    includeQueries: options.slowQueries
  });

  // Generate implementation plan
  const plan = await invokeAgent('database-architect', {
    task: 'create-optimization-plan',
    optimizations: optimizations,
    autoFix: options.autoFix
  });

  if (options.autoFix) {
    const results = await applySafeOptimizations(plan);
    return { analysis, optimizations, plan, results };
  }

  return { analysis, optimizations, plan };
}
````

## Related Commands

- `/query-analyze` - Detailed query analysis
- `/index-advisor` - Index recommendations
- `/db-migration` - Database migration planning
