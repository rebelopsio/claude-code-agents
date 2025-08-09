# /backlog-refine

Refine and organize your product backlog with AI-powered analysis.

## Usage

```
/backlog-refine [options]
```

## Options

- `--source linear|github|jira` - Specify the issue tracker (default: linear)
- `--team <team-name>` - Filter by specific team
- `--label <label>` - Filter by label
- `--epic <epic-id>` - Focus on specific epic
- `--output markdown|csv` - Output format (default: markdown)

## What it does

1. **Fetches unrefined issues** from your issue tracker
2. **Analyzes each issue** for:
   - Clarity and completeness
   - Missing acceptance criteria
   - Estimation complexity
   - Dependencies
   - Technical debt indicators
3. **Suggests improvements**:
   - Better titles and descriptions
   - Acceptance criteria
   - Story point estimates
   - Labels and categorization
4. **Identifies patterns**:
   - Duplicate or similar issues
   - Issues that should be epics
   - Issues that should be split

## Example Output

```markdown
## Backlog Refinement Report

### High Priority Refinements Needed

#### Issue #123: "Fix login bug"

**Current State**: Vague, no acceptance criteria
**Suggested Title**: "Fix OAuth2 token refresh failure on session timeout"
**Suggested Description**:

- Problem: Users are logged out unexpectedly after 30 minutes
- Root Cause: OAuth2 refresh token not being properly stored
- Impact: 15% of users affected daily

**Acceptance Criteria**:

- [ ] OAuth2 refresh token persists across sessions
- [ ] Users remain logged in for configured timeout period
- [ ] Proper error handling for expired tokens
- [ ] Unit tests for token refresh logic

**Estimate**: 3 story points
**Labels**: `bug`, `auth`, `high-priority`

### Duplicate Issues Detected

- #124 and #156 appear to describe the same problem
- Recommendation: Merge into single issue

### Issues Requiring Split

- #789 "Redesign entire dashboard"
  - Too large (estimated 21+ points)
  - Suggest splitting into: Navigation, Widgets, Layout, Responsive Design
```

## Implementation

```typescript
async function refineBacklog(options: BacklogOptions) {
  // Fetch issues from source
  const issues = await fetchIssues(options);

  // Analyze each issue
  const refinements = await Promise.all(issues.map((issue) => analyzeIssue(issue)));

  // Detect patterns
  const patterns = detectPatterns(refinements);

  // Generate report
  return generateReport(refinements, patterns, options.output);
}

async function analyzeIssue(issue: Issue) {
  const agent = "product-owner"; // Use our product-owner agent

  return await invokeAgent(agent, {
    task: "refine",
    issue: issue,
    context: {
      checkForDuplicates: true,
      suggestSplitting: true,
      generateAcceptanceCriteria: true,
      estimateComplexity: true,
    },
  });
}
```

## Related Commands

- `/prioritize` - Prioritize refined backlog items
- `/estimate` - Bulk estimation session
- `/sprint-plan` - Plan next sprint from refined backlog
