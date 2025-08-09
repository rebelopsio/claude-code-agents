# /prioritize

Intelligently prioritize product backlog items using multiple frameworks.

## Usage

```
/prioritize [framework] [options]
```

## Frameworks

- `value-effort` - Value vs Effort matrix (default)
- `rice` - Reach, Impact, Confidence, Effort scoring
- `moscow` - Must have, Should have, Could have, Won't have
- `kano` - Basic, Performance, Excitement features
- `cost-delay` - Cost of Delay prioritization
- `weighted` - Weighted scoring based on custom criteria

## Options

- `--team <name>` - Focus on specific team's backlog
- `--sprint` - Prioritize for next sprint only
- `--quarter` - Prioritize for quarterly planning
- `--include-tech-debt` - Include technical debt items
- `--max-items <n>` - Limit to top N items

## What it does

1. **Analyzes backlog items** against chosen framework
2. **Calculates scores** based on:
   - Business value
   - User impact
   - Technical complexity
   - Dependencies
   - Risk factors
3. **Generates recommendations** with reasoning
4. **Creates visual matrix** or ranked list
5. **Updates issue tracker** with priority labels (optional)

## Example Output

```markdown
## Prioritization Report (RICE Framework)

### Top Priority Items

| Rank | Issue                   | Reach | Impact | Confidence | Effort | Score | Recommendation   |
| ---- | ----------------------- | ----- | ------ | ---------- | ------ | ----- | ---------------- |
| 1    | #234: Add SSO login     | 5000  | 3      | 80%        | 5      | 2400  | 🚀 Do First      |
| 2    | #156: Mobile responsive | 8000  | 2      | 90%        | 8      | 1800  | 🎯 High Priority |
| 3    | #445: Dark mode         | 3000  | 2      | 70%        | 3      | 1400  | ✅ Do Next       |

### Detailed Analysis

#### 🚀 #234: Add SSO login

**Why prioritize**:

- Affects 5000 enterprise users (high reach)
- Significant impact on enterprise adoption
- Clear implementation path (80% confidence)
- Moderate effort (5 story points)

**Dependencies**: None
**Risks**: OAuth provider rate limits
**Recommendation**: Start in next sprint

### Value-Effort Matrix
```

High Value │ Quick Wins 🎯 │ Major Projects 🚀 │
│ • Dark mode │ • SSO login │
│ • API docs │ • Mobile app │
├────────────────┼───────────────────┤
Low Value │ Nice to Have 💭│ Time Sinks ⚠️ │
│ • Animations │ • Legacy refactor │
│ Low Effort │ High Effort │

```

### MoSCoW Breakdown

**Must Have** (P0)
- SSO login (#234)
- Critical bug fixes (#123, #125)

**Should Have** (P1)
- Mobile responsive (#156)
- Performance improvements (#789)

**Could Have** (P2)
- Dark mode (#445)
- Enhanced analytics (#667)

**Won't Have** (this quarter)
- Complete redesign (#999)
```

## Implementation

```typescript
async function prioritizeBacklog(framework: Framework, options: PriorityOptions) {
  const issues = await fetchBacklogItems(options);

  // Use business-analyst agent for analysis
  const analysis = await invokeAgent("business-analyst", {
    task: "analyze-business-value",
    issues: issues,
  });

  // Apply prioritization framework
  const scores = await calculateScores(framework, issues, analysis);

  // Generate recommendations
  const recommendations = await invokeAgent("product-owner", {
    task: "prioritize",
    scores: scores,
    context: options,
  });

  return formatReport(scores, recommendations, framework);
}
```

## Related Commands

- `/backlog-refine` - Refine items before prioritization
- `/capacity` - Check team capacity for prioritized items
- `/roadmap` - Generate roadmap from priorities
