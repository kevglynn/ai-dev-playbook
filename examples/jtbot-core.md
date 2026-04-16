# Stringer Analysis: jtbot-core

**Repo:** pryoninc/jtbot-core
**Scanned:** 2026-03-10
**Stringer version:** 1.5.0
**Scan time:** ~80 seconds (full, 15 collectors)

## Repo Profile

| Attribute | Value |
|-----------|-------|
| Language | TypeScript / React (frontend), AWS Amplify + Lambda (backend) |
| Purpose | JTBot — Pryon's conversational AI assistant platform. The core UI and backend services |
| Scale | Large production codebase — 2,571 raw signals indicates substantial code volume |
| Key stack | React, GraphQL, AWS Amplify, Lambda, Cognito/EntraID auth |
| Beads state | 128 beads (100 Jira-synced from BUB2 project + 22 pre-existing + 6 stringer-sourced) |

## Scan Summary

| Metric | Value |
|--------|-------|
| Total signals | 2,571 |
| Collectors used | 15 (full suite) |
| Scan time | ~80 seconds |
| Focused scan (todos, gitlog, lotteryrisk) | Significantly faster |

This is a large, actively developed production codebase. The signal count (2,571) is roughly 34x what igloo-connector produced (76), reflecting the difference in codebase size and complexity.

## Triage Approach

2,571 signals cannot and should not become 2,571 issues. The triage process:

1. Ran focused scan with `--collectors todos,gitlog,lotteryrisk` to surface highest-signal categories
2. Reviewed ~100 signals across churn, lottery risk, and code patterns
3. Applied human judgment: "Would this have been filed manually? Does it reveal something non-obvious?"
4. Created 6 beads — the ones that passed the bar

**Key lesson:** `bd import` doesn't exist in beads v0.59.0 despite stringer docs referencing it (filed beads #2505, stringer #275). The correct workflow is agent-assisted triage: run stringer, read the report, create individual beads for the findings that matter.

## The 6 Beads Created

### jtbot-core-1dl — useChatState.ts churn (P2)

**Signal:** 57 changes in 90 days.

**What it means:** This file is the central state management for the chat interface. 57 modifications in 3 months means it's being touched almost every other day. This suggests either:
- Unclear responsibilities (the file does too much)
- Shifting requirements concentrated in one place
- Bug fixes layered on top of each other

**Action:** Decompose useChatState into smaller, focused hooks with clear boundaries. This was later picked up by Gas Town polecats — bead jc-ds8 ("Decompose useChatState.ts") was successfully merged to the gastown branch.

### jtbot-core-apg — amplify/backend.ts churn (P2)

**Signal:** 56 changes in 90 days.

**What it means:** The Amplify backend configuration file is nearly as volatile as the chat state. This is the infrastructure-as-code layer for AWS resources. High churn here suggests:
- Frequent environment/config adjustments
- Possible trial-and-error deployment patterns
- Backend architecture still stabilizing

**Action:** Review whether backend.ts is accumulating responsibilities that should be split across separate Amplify resource definitions. Stabilize the deployment configuration.

### jtbot-core-bsg — Lottery risk in src/ (P2)

**Signal:** src/ directory has 87% single-author commits.

**What it means:** Similar to igloo-connector but at much larger scale. One contributor owns the vast majority of the frontend source code. In a production platform like JTBot, this represents significant organizational risk.

**Action:** Cross-training, architecture documentation, and deliberate code review rotation to build shared ownership. Pair programming sessions on the highest-risk modules (chat state, navigation, permissions).

### jtbot-core-j4v — EntraID placeholder in production auth code (P1 bug)

**Signal:** TODO/placeholder discovered in authentication flow.

**What it means:** This is the highest-priority finding. An EntraID (Azure AD) integration has placeholder code in the production authentication path. This is not tech debt — it's an incomplete feature in a security-critical path.

**Action:** Complete the EntraID integration or remove the placeholder to prevent it from being accidentally activated. This should block any auth-related deployments until resolved.

### jtbot-core-xbi — Silent error swallowing in ChatApp.tsx (P2)

**Signal:** Error handling pattern that catches and discards exceptions.

**What it means:** ChatApp.tsx (likely the main chat component) has catch blocks that swallow errors without logging, reporting, or surfacing them to the user. This makes debugging production issues nearly impossible — failures happen silently and the user sees nothing or sees stale state.

**Action:** Replace silent catches with proper error handling: log the error, report to monitoring, and show the user an appropriate error state. At minimum, add `console.error` and error boundary fallbacks.

### jtbot-core-ecy — useNavigation.ts useReducer tech debt (P3)

**Signal:** Complex state management pattern flagged by code analysis.

**What it means:** The navigation hook uses `useReducer` in a way that has accumulated complexity — likely a large reducer with many action types, or state shape that's evolved beyond what a single reducer can cleanly manage.

**Action:** Evaluate whether the navigation state should be split into multiple concerns, or whether a state machine library (like XState) would provide clearer transitions. Lower priority — this is tech debt, not a bug.

## Patterns Observed

### Churn correlates with architectural stress

The two highest-churn files (useChatState.ts and amplify/backend.ts) represent the two most common architectural pressure points in modern web apps:
- **Frontend state management** — when state grows faster than the architecture can absorb
- **Infrastructure configuration** — when the deployment model is still being figured out

Both are symptoms of a codebase that's growing faster than its architecture is being maintained.

### Lottery risk at this scale is organizational risk

87% single-author in src/ for a production platform is a different magnitude of risk than in a small connector. If the primary contributor is unavailable for even 2 weeks, the team's velocity drops to near-zero on frontend changes.

### Auth code requires higher scrutiny

The EntraID placeholder (jtbot-core-j4v) was the only P1 finding. Stringer's value here was surfacing a security-relevant TODO that might have been invisible in normal code review — buried in a file that "looks complete" until you read the comments.

## Comparison with igloo-connector

| Dimension | igloo-connector | jtbot-core |
|-----------|----------------|------------|
| Signals | 76 | 2,571 |
| Scan time | ~8s | ~80s |
| Beads created | 4 candidates | 6 beads |
| Triage ratio | 76 → 4 (5%) | 2,571 → 6 (0.2%) |
| Top risk | Lottery risk (85%) | Auth placeholder + lottery risk (87%) |
| Churn | Low (small repo) | High — 57 changes/90d on central file |

The triage ratio dropping from 5% to 0.2% makes the point: larger codebases produce exponentially more noise, but the number of truly actionable items doesn't scale linearly. The value of stringer is not the signal count — it's finding the 6 needles in 2,571 pieces of hay.

## Commands Used

```bash
# Full scan (15 collectors, 2,571 signals, ~80 seconds)
stringer scan . -f markdown \
  --exclude '.history/**' --exclude '.cursor/**' \
  --exclude 'node_modules/**' --exclude '.beads/**'

# Focused scan (faster, highest-signal categories)
stringer scan . -f markdown \
  --collectors todos,gitlog,lotteryrisk \
  --exclude '.history/**' --exclude '.cursor/**' \
  --exclude 'node_modules/**' --exclude '.beads/**'
```

## Outcome

All 6 beads were created in the jtbot-core beads database and are tracked alongside the 100 Jira-synced issues and 22 pre-existing beads. Several were subsequently picked up by Gas Town polecats for execution:
- **jc-ds8** (Decompose useChatState.ts) — merged to gastown branch
- **jc-z93** (React.lazy code-splitting) — merged
- **jc-bi3** (Virtualize ConversationHistorySidebar) — merged

The stringer-sourced beads integrated seamlessly with the Jira-sourced and manually-created beads — demonstrating that signal discovery and org-level tracking can coexist in the same system.
