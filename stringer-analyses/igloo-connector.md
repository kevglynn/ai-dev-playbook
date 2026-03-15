# Stringer Analysis: igloo-connector

**Repo:** pryoninc/igloo-connector
**Scanned:** 2026-03-13
**Stringer version:** 1.5.0
**Scan time:** ~8 seconds (full), <1 second (focused)

## Repo Profile

| Attribute | Value |
|-----------|-------|
| Language | TypeScript / Express |
| Purpose | Igloo digital workplace connector — bridges Igloo content with Pryon's ingestion pipeline |
| Age | ~14 months (Jan 2025 – Mar 2026) |
| Commits | 303 |
| Releases | 31 (v1.0.0 through v1.0.31) |
| Primary author | Christian DiMare-Baits (151 commits, 50%) |
| Other contributors | Chris Harty / Christopher Harty (~144 commits combined), Hirsh Parikshak (4), Hamza Yaghmmour (2), Soonthorn Ativanichayaphong (1) |
| Key dependencies | @temporalio/client, @yugabytedb/pg, express, axios, @pryon/api-schema-connect |
| Infrastructure | Docker + Helm, Bitbucket Pipelines CI, YugabyteDB, Temporal workflows |

## Scan Summary

| Metric | Value |
|--------|-------|
| Total signals | 76 |
| Collectors used | 8 (complexity, docstale, duplication, githygiene, lotteryrisk, patterns, todos, vuln) |
| P1 (Critical) | 16 |
| P2 (High) | 20 |
| P3 (Medium) | 13 |
| P4 (Low) | 27 |

## Signal Breakdown

| Category | Count | Key Findings |
|----------|-------|-------------|
| **lotteryrisk** | 7 | Christian DiMare-Baits owns 85% of root commits, 100% of src/components, 56% of src/ |
| **vulnerability** | 12 | CVEs in axios (hot path), qs, minimatch (3 CVEs), jws, js-yaml, flatted, ajv, diff, glob |
| **duplication** | 21 | routes.ts has 10+ near-duplicate blocks across handlers — 404 handling, domain calc, response envelopes |
| **todos** | 8 | Unimplemented GrantType handling, missing multi-connector filtering, upstream YugabyteDB loadBalance bug |
| **githygiene** | 6 | Possible hardcoded secrets in e2e test scripts and test fixtures |
| **patterns** | 9 | Zero test files for 4 source files in src/. Low test ratio overall |
| **complexity** | 4 | getPool (11 branches), getContentMetadata (9 branches, nested .then/.catch with async) |
| **docstale** | 1 | README.md untouched while repo had 12 commits |

## Analysis

### Lottery Risk — the headline finding

Christian is effectively the sole deep expert on this codebase. Ownership breakdown:

- **Root level:** 85% of commits
- **src/components/:** 100% (Article rendering layer — zero other contributors)
- **src/:** 56% (core API routes, DB layer, Temporal integration)
- **bin/:** 100% (tooling)
- **test/:** 59%

The README is comprehensive (Christian clearly valued documentation), but there's no architecture doc, no CONTRIBUTING.md, and inline comments are sparse. If Christian is unavailable, the connector becomes extremely difficult to maintain — not because anyone did anything wrong, but because the team is small and work naturally concentrated.

### Vulnerable Dependencies — CVEs in the hot path

12 CVEs across the dependency tree. The most concerning:

- **axios** — used for all Igloo API calls (the core data path). Active CVE.
- **jws** — JSON Web Signatures, auth-adjacent.
- **qs** — query string parsing, used by Express internally.
- **minimatch** — 3 separate CVEs.

A recent commit (`a0fa43b`, "cve package updates") addressed some but not all. Several are transitive through Temporal or Express, making clean fixes harder.

### Duplication in routes.ts — the maintenance multiplier

`routes.ts` is the heart of the connector: 452 lines, 7 route handlers. The duplication is structural:

- **404 delete workflow pattern** appears in both `readContent` (lines 172-227) and `getContentMetadata` (lines 276-319). Nearly identical: catch 404 → query content_id → trigger Temporal delete workflow → return 204. Should be a shared middleware.
- **content_domain calculation** (`type === "flex" ? host + "/" + customer_id : host`) repeated in 4+ handlers.
- **Response envelope** (`{ metadata: { uuid, response_time_millis }, ... }`) repeated with slight variations.

Bugs fixed in one handler may not be fixed in the copy. New contributors have to reverse-engineer which parts are "the same" and which differ intentionally.

### Test Coverage — almost nonexistent

Zero test files for the entire `src/` directory:
- `routes.ts` (the API surface) — untested
- `db.ts` (database layer) — untested
- `index.ts` (server entry) — untested
- `components/Article.ts` (rendering) — untested

The existing `test/pass.test.ts` contains one test: "Always passes." The e2e tests have TODOs about implementing Temporal workflow status checks.

### TODOs — deferred work accumulating

Notable incomplete work:
- **`src/routes.ts:341`** — "Handle the different GrantTypes in permission_grant" (feature gap in permissions)
- **`src/routes.ts:379`** — "Filter groups by connector_id when we have multiple Igloo Connectors" (assumes single-connector deployment)
- **`src/db.ts:53, :84`** — "Submit a ticket to @yugabytedb/pg repo complaining about loadBalance" (blocks TLS/cluster deployments)
- **`TODO.md`** — "Port the Dockerfile to Pryon base images for security" (open 14 months)

## Candidate Work Items

Triaged from 76 signals down to 4 actionable items:

### 1. Mitigate lottery risk on src/ (P2)

**Problem:** 85% single-author codebase. No architecture documentation beyond the README.

**Actions:**
- Cross-training sessions: walk a second contributor through the routing logic, DB layer, and Temporal integration
- Create a CONTRIBUTING.md with architecture overview and key design decisions
- Add a second reviewer requirement on PRs touching src/

**Acceptance criteria:** At least one additional contributor can explain the src/ architecture. Key design decisions are documented.

### 2. Audit and remediate vulnerable dependencies (P1)

**Problem:** 12 CVEs including axios (in the hot path) and auth-adjacent libs.

**Actions:**
- Run `npm audit` and categorize: direct vs transitive, exploitability, affected code paths
- Update direct dependencies where possible
- For transitive CVEs (Temporal, Express), evaluate pinning or overrides

**Acceptance criteria:** `npm audit` shows zero high/critical vulnerabilities. Remaining moderate vulns have documented justification.

### 3. Extract shared patterns in routes.ts (P2)

**Problem:** 21 duplication signals. The 404 delete workflow, domain calculation, and response envelope are copy-pasted across handlers.

**Actions:**
- Extract 404-delete-workflow into shared middleware or utility
- Extract content_domain calculation into a helper
- Standardize response envelope construction

**Acceptance criteria:** No duplicate blocks longer than 3 lines across route handlers. 404 handling logic exists in one place.

### 4. Add test coverage for src/ (P3)

**Problem:** Zero tests on the API surface, DB layer, and rendering components.

**Actions:**
- Prioritize routes.ts and db.ts (highest complexity and risk)
- Start with contract tests for each route handler (request shape → response shape)
- Add unit tests for getPool and the Article rendering components

**Acceptance criteria:** Each route handler has at least one happy-path and one error-path test. db.ts has connection pool configuration tests.

## Commands Used

```bash
# Full scan (8 collectors, 76 signals, ~8 seconds)
stringer scan . -f markdown \
  --exclude '.history/**' --exclude '.cursor/**' \
  --exclude 'node_modules/**' --exclude '.beads/**'

# Focused scan (3 collectors, 15 signals, <1 second)
stringer scan . -f markdown \
  --collectors todos,gitlog,lotteryrisk \
  --exclude '.history/**' --exclude '.cursor/**' \
  --exclude 'node_modules/**' --exclude '.beads/**'
```
