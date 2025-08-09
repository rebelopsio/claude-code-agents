# /test-coverage

Analyze test coverage and generate missing tests.

## Usage

```
/test-coverage [options]
```

## Options

- `--target <percent>` - Target coverage percentage (default: 80)
- `--generate` - Generate missing tests
- `--focus <path>` - Focus on specific directory/file
- `--type unit|integration|e2e` - Test type to analyze
- `--framework` - Override test framework detection

## What it does

1. **Analyzes current coverage** across the codebase
2. **Identifies gaps** in test coverage
3. **Prioritizes** untested critical paths
4. **Generates tests** for uncovered code
5. **Creates coverage report** with actionable insights

## Example Output

````markdown
## Test Coverage Report

### 📊 Overall Coverage

| Metric     | Current | Target | Status |
| ---------- | ------- | ------ | ------ |
| Statements | 67.3%   | 80%    | ❌     |
| Branches   | 54.2%   | 80%    | ❌     |
| Functions  | 71.5%   | 80%    | ⚠️     |
| Lines      | 68.9%   | 80%    | ❌     |

### 🔴 Critical Untested Code

#### 1. PaymentService.processPayment()

**File**: `services/PaymentService.ts:45-89`
**Risk**: High - Handles financial transactions
**Coverage**: 0%

**Generated Test**:

```typescript
// services/__tests__/PaymentService.test.ts
import { PaymentService } from "../PaymentService";
import { mockStripeClient } from "../../__mocks__/stripe";

describe("PaymentService", () => {
  let service: PaymentService;

  beforeEach(() => {
    service = new PaymentService(mockStripeClient);
  });

  describe("processPayment", () => {
    it("should process valid payment successfully", async () => {
      const payment = {
        amount: 100,
        currency: "USD",
        customerId: "cus_123",
      };

      mockStripeClient.charges.create.mockResolvedValue({
        id: "ch_123",
        status: "succeeded",
      });

      const result = await service.processPayment(payment);

      expect(result.status).toBe("succeeded");
      expect(mockStripeClient.charges.create).toHaveBeenCalledWith({
        amount: 10000, // cents
        currency: "USD",
        customer: "cus_123",
      });
    });

    it("should handle payment failure", async () => {
      mockStripeClient.charges.create.mockRejectedValue(new Error("Card declined"));

      await expect(service.processPayment({})).rejects.toThrow("Payment failed: Card declined");
    });

    it("should validate payment amount", async () => {
      const payment = { amount: -100 };

      await expect(service.processPayment(payment)).rejects.toThrow("Invalid payment amount");
    });
  });
});
```
````

#### 2. AuthMiddleware.validateToken()

**File**: `middleware/auth.ts:12-34`
**Risk**: High - Security critical
**Coverage**: 23%

### 📈 Coverage by Module

```
src/
├── components/ ████████░░ 82% ✅
├── services/   ████░░░░░░ 45% ❌
├── utils/      ███████░░░ 71% ⚠️
├── middleware/ ██░░░░░░░░ 23% 🔴
└── api/        ██████░░░░ 65% ⚠️
```

### 🎯 Test Generation Priority

1. **PaymentService** (0% → 80%)

   - 12 test cases needed
   - Estimated time: 2 hours

2. **AuthMiddleware** (23% → 80%)

   - 8 test cases needed
   - Estimated time: 1.5 hours

3. **UserRepository** (45% → 80%)
   - 6 test cases needed
   - Estimated time: 1 hour

### 💡 Recommendations

#### Quick Wins (< 1 hour)

- Add tests for `utils/validators.ts` (+15% coverage)
- Test error handlers in `api/errors.ts` (+8% coverage)

#### Missing Test Types

- **Integration Tests**: API endpoints lack integration tests
- **E2E Tests**: Critical user flows untested
- **Performance Tests**: No load testing for APIs

#### Testing Best Practices

1. Add test data factories for consistent mocking
2. Implement snapshot testing for React components
3. Use code coverage in CI/CD pipeline
4. Set up mutation testing for critical paths

### 📝 Generated Test Files

Created 8 test files:

- `services/__tests__/PaymentService.test.ts`
- `middleware/__tests__/auth.test.ts`
- `repositories/__tests__/UserRepository.test.ts`
- `utils/__tests__/validators.test.ts`
- `api/__tests__/userController.test.ts`
- `components/__tests__/CheckoutForm.test.tsx`
- `hooks/__tests__/useAuth.test.ts`
- `e2e/__tests__/checkout.e2e.test.ts`

````

## Implementation

```typescript
async function analyzeTestCoverage(options: CoverageOptions) {
  // Get current coverage
  const coverage = await getCoverageReport();

  // Identify gaps
  const gaps = identifyCoverageGaps(coverage, options.target);

  // Prioritize by risk
  const prioritized = await invokeAgent('qa-engineer', {
    task: 'prioritize-test-gaps',
    gaps: gaps,
    riskAnalysis: true
  });

  if (options.generate) {
    // Generate tests for gaps
    const tests = await invokeAgent('test-engineer', {
      task: 'generate-tests',
      gaps: prioritized,
      framework: options.framework
    });

    // Write test files
    await writeTestFiles(tests);
  }

  return formatCoverageReport(coverage, prioritized, tests);
}
````

## Related Commands

- `/test-gen` - Generate specific test cases
- `/mutation-test` - Run mutation testing
- `/test-quality` - Analyze test quality metrics
