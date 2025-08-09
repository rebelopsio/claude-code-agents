# /perf-analyze

Analyze application performance and identify optimization opportunities.

## Usage

```
/perf-analyze [target] [options]
```

## Targets

- `frontend` - Analyze React/Next.js/Vue performance
- `backend` - Analyze API and server performance
- `database` - Analyze database queries and indexes
- `full-stack` - Complete application analysis
- `build` - Analyze build size and speed

## Options

- `--profile <file>` - Use performance profile data
- `--metrics lighthouse|webvitals|custom` - Metrics to analyze
- `--threshold <ms>` - Flag operations over threshold
- `--compare <branch>` - Compare with another branch
- `--suggest-fixes` - Generate fix implementations

## What it does

1. **Collects performance data** from multiple sources
2. **Identifies bottlenecks**:
   - Slow renders and re-renders
   - Large bundle sizes
   - Slow API endpoints
   - N+1 queries
   - Memory leaks
3. **Analyzes patterns**:
   - Unnecessary re-renders
   - Missing memoization
   - Inefficient algorithms
   - Missing indexes
4. **Generates fixes** with code examples

## Example Output

````markdown
## Performance Analysis Report

### 🔴 Critical Issues

#### 1. ProductList Component Re-rendering

**Impact**: 450ms unnecessary re-renders
**Cause**: Missing React.memo and unstable props
**Fix**:

```typescript
// Before
const ProductList = ({ products, onSelect }) => {
  return products.map(p => <Product key={p.id} {...p} />);
};

// After
const ProductList = React.memo(({ products, onSelect }) => {
  const memoizedOnSelect = useCallback(onSelect, []);
  return products.map(p => (
    <Product key={p.id} {...p} onSelect={memoizedOnSelect} />
  ));
});
```
````

#### 2. Bundle Size Issue

**Impact**: 2.3MB main bundle (should be <200KB)
**Cause**: Importing entire lodash library
**Fix**:

```javascript
// Before
import _ from "lodash";

// After
import debounce from "lodash/debounce";
import get from "lodash/get";
```

### 🟡 Warnings

#### API Response Time

**Endpoint**: /api/products
**Current**: 850ms average
**Target**: <200ms
**Issues**:

- Missing database indexes
- N+1 query in categories
- No caching layer

**Suggested Fix**:

```typescript
// Add index
CREATE INDEX idx_products_category ON products(category_id);

// Fix N+1 with eager loading
const products = await Product.findAll({
  include: [Category] // Eager load
});

// Add caching
const cached = await redis.get('products');
if (cached) return JSON.parse(cached);
```

### 📊 Metrics Summary

| Metric      | Current | Target | Status |
| ----------- | ------- | ------ | ------ |
| FCP         | 2.1s    | <1.8s  | ⚠️     |
| LCP         | 4.2s    | <2.5s  | 🔴     |
| CLS         | 0.05    | <0.1   | ✅     |
| Bundle Size | 2.3MB   | <500KB | 🔴     |
| API p95     | 1.2s    | <500ms | 🔴     |

### 🚀 Optimization Roadmap

1. **Immediate** (1-2 days)

   - Add React.memo to 5 components
   - Tree-shake lodash imports
   - Add database indexes

2. **Short-term** (1 week)

   - Implement code splitting
   - Add Redis caching
   - Optimize images with next/image

3. **Long-term** (2-4 weeks)
   - Migrate to React Server Components
   - Implement edge caching
   - Database query optimization

````

## Implementation

```typescript
async function analyzePerformance(target: string, options: PerfOptions) {
  // Collect metrics
  const metrics = await collectMetrics(target, options);

  // Use appropriate optimization agent
  const agent = target === 'frontend'
    ? 'react-component-engineer'
    : target === 'backend'
    ? 'go-performance-optimizer'
    : 'site-reliability-engineer';

  const analysis = await invokeAgent(agent, {
    task: 'analyze-performance',
    metrics: metrics,
    threshold: options.threshold
  });

  // Generate fixes if requested
  if (options.suggestFixes) {
    const fixes = await generateFixes(analysis);
    return { analysis, fixes };
  }

  return analysis;
}
````

## Related Commands

- `/profile` - Capture performance profile
- `/benchmark` - Run performance benchmarks
- `/optimize` - Apply suggested optimizations
