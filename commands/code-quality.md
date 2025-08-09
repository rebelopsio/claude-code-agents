# /code-quality

Comprehensive code quality analysis and improvement suggestions.

## Usage

```
/code-quality [scope] [options]
```

## Scopes

- `file <path>` - Analyze specific file
- `pr` - Analyze current pull request
- `module <name>` - Analyze entire module
- `codebase` - Full codebase analysis

## Options

- `--metrics complexity|duplication|maintainability|all`
- `--autofix` - Apply automatic fixes
- `--style-guide <path>` - Custom style guide
- `--compare <branch>` - Compare with branch
- `--threshold <score>` - Quality threshold (default: 7/10)

## What it does

1. **Analyzes code quality** across multiple dimensions
2. **Calculates metrics**: complexity, duplication, test coverage
3. **Identifies issues**: code smells, anti-patterns, violations
4. **Suggests improvements** with examples
5. **Generates report** with quality score

## Example Output

````markdown
## Code Quality Report

### 📊 Quality Score: 7.2/10

| Dimension       | Score | Grade | Trend |
| --------------- | ----- | ----- | ----- |
| Maintainability | 7.5   | B     | ↗    |
| Reliability     | 8.1   | B+    | →     |
| Security        | 6.8   | C+    | ↘    |
| Performance     | 7.2   | B-    | ↗    |
| Testability     | 6.4   | C     | →     |

### 🔴 Critical Issues (3)

#### 1. High Cyclomatic Complexity

**File**: `services/OrderService.ts:processOrder()`
**Complexity**: 24 (threshold: 10)
**Issue**: Method is too complex to maintain and test

**Current Code**:

```typescript
async processOrder(order: Order) {
  if (order.status === 'pending') {
    if (order.payment) {
      if (order.payment.type === 'credit') {
        // 20 more nested conditions...
      }
    }
  }
}
```
````

**Refactored**:

```typescript
async processOrder(order: Order) {
  const validator = new OrderValidator(order);
  const processor = this.getProcessor(order.payment.type);

  await validator.validate();
  await processor.process(order);
  await this.notifyCustomer(order);
}

private getProcessor(type: PaymentType): PaymentProcessor {
  return this.processors[type] || new DefaultProcessor();
}
```

#### 2. Code Duplication

**Files**: `api/users.ts`, `api/products.ts`, `api/orders.ts`
**Duplication**: 87% similar code
**Lines**: 45-120 in each file

**Solution**: Extract to shared middleware

```typescript
// middleware/validation.ts
export const validateRequest = (schema: Schema) => {
  return async (req: Request, res: Response, next: Next) => {
    try {
      await schema.validate(req.body);
      next();
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  };
};

// Usage in routes
router.post("/users", validateRequest(userSchema), createUser);
router.post("/products", validateRequest(productSchema), createProduct);
```

### 🟡 Code Smells (8)

#### Long Method

- `UserController.updateProfile()` - 145 lines (max: 50)
- `DataProcessor.transform()` - 98 lines

#### God Class

- `AppService` - 2,456 lines, 47 public methods
- Suggestion: Split into UserService, AuthService, NotificationService

#### Magic Numbers

```typescript
// Found in calculations.ts
if (value > 86400) {
  // What is 86400?
  return value / 86400;
}

// Better:
const SECONDS_IN_DAY = 86400;
if (value > SECONDS_IN_DAY) {
  return value / SECONDS_IN_DAY;
}
```

### 📈 Metrics Breakdown

#### Cyclomatic Complexity by File

```
services/
├── OrderService.ts    ████████████ 24 🔴
├── UserService.ts     ██████░░░░░░ 12 ⚠️
├── AuthService.ts     ████░░░░░░░░ 8  ✅
└── EmailService.ts    ██░░░░░░░░░░ 4  ✅
```

#### Test Coverage Impact

| File              | Coverage | Quality Impact |
| ----------------- | -------- | -------------- |
| OrderService.ts   | 23%      | -2.1 points    |
| UserController.ts | 45%      | -1.3 points    |
| validators.ts     | 0%       | -1.8 points    |

### 🎯 Improvement Opportunities

#### Quick Wins (< 1 hour)

1. Extract magic numbers to constants (+0.3 quality)
2. Remove dead code in `utils/legacy.ts` (+0.2 quality)
3. Fix ESLint errors (+0.4 quality)

#### Medium Effort (1 day)

1. Refactor `OrderService.processOrder()` (+0.8 quality)
2. Extract duplicate validation logic (+0.6 quality)
3. Add missing TypeScript types (+0.5 quality)

#### Major Refactoring (1 week)

1. Split God classes (+1.2 quality)
2. Implement dependency injection (+0.9 quality)
3. Migrate to functional components (+0.7 quality)

### 🔧 Auto-Fixed Issues

Applied 47 automatic fixes:

- ✅ 23 formatting issues (Prettier)
- ✅ 12 import ordering issues
- ✅ 8 unused variables removed
- ✅ 4 const assertions added

### 📝 Recommendations

1. **Establish Code Review Guidelines**

   - Enforce maximum method length: 50 lines
   - Cyclomatic complexity limit: 10
   - Minimum test coverage: 80%

2. **Tooling Setup**

   ```json
   // .eslintrc.json additions
   {
     "rules": {
       "complexity": ["error", 10],
       "max-lines-per-function": ["error", 50],
       "no-duplicate-imports": "error"
     }
   }
   ```

3. **Architecture Improvements**
   - Implement Clean Architecture principles
   - Add dependency injection container
   - Create shared validation layer

````

## Implementation

```typescript
async function analyzeCodeQuality(scope: string, options: QualityOptions) {
  // Collect metrics
  const metrics = await collectQualityMetrics(scope);

  // Analyze with code-reviewer agent
  const analysis = await invokeAgent('code-reviewer', {
    task: 'analyze-quality',
    metrics: metrics,
    threshold: options.threshold
  });

  // Generate improvements
  const improvements = await invokeAgent('software-architect', {
    task: 'suggest-refactoring',
    issues: analysis.issues
  });

  if (options.autofix) {
    const fixes = await applyAutoFixes(analysis.issues);
    return { analysis, improvements, fixes };
  }

  return { analysis, improvements };
}
````

## Related Commands

- `/refactor` - Refactor specific code
- `/lint` - Run linting with fixes
- `/architect-review` - Architecture analysis
