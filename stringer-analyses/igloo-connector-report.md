# Stringer Scan Results

**Total signals:** 76 | **Collectors:** complexity, docstale, duplication, githygiene, lotteryrisk, patterns, todos, vuln

| Priority | Count |
|----------|-------|
| P1       | 16     |
| P2       | 20     |
| P3       | 13     |
| P4       | 27     |

## complexity (4 signals)

- **Complex function: getPool (score 11.5, 26 lines, 11 branches)** — `src/db.ts:62` (confidence: 0.70)
- **Complex function: getContentMetadata (score 10.6, 79 lines, 9 branches)** — `src/routes.ts:238` (confidence: 0.67)
- **Complex function: getTemporalClient (score 8.1, 53 lines, 7 branches)** — `src/temporal.ts:9` (confidence: 0.60)
- **Complex function: readContent (score 7.6, 79 lines, 6 branches)** — `src/routes.ts:145` (confidence: 0.58)

## docstale (1 signals)

- **Doc README.md has 0 updates while . had 12 commits** — `README.md` (confidence: 0.30)

## duplication (21 signals)

- **Duplicated block (6 lines, 5 locations)** — `src/routes.ts:134` (confidence: 0.45)
- **Duplicated block (6 lines, 4 locations)** — `src/routes.ts:146` (confidence: 0.45)
- **Near-duplicate block (6 lines, 9 locations, renamed identifiers)** — `src/routes.ts:74` (confidence: 0.40)
- **Near-duplicate block (6 lines, 10 locations, renamed identifiers)** — `src/components/classic/Article.ts:30` (confidence: 0.40)
- **Duplicated block (6 lines, 3 locations)** — `test/temporal.test.ts:87` (confidence: 0.40)
- **Near-duplicate block (6 lines, 4 locations, renamed identifiers)** — `src/routes.ts:146` (confidence: 0.40)
- **Near-duplicate block (6 lines, 6 locations, renamed identifiers)** — `src/routes.ts:47` (confidence: 0.40)
- **Duplicated block (6 lines, 2 locations)** — `src/components/classic/Article.ts:47` (confidence: 0.35)
- **Near-duplicate block (6 lines, 3 locations, renamed identifiers)** — `test/contracts.test.ts:59` (confidence: 0.35)
- **Duplicated block (6 lines, 2 locations)** — `test/temporal.test.ts:104` (confidence: 0.35)
- **Duplicated block (6 lines, 2 locations)** — `src/routes.ts:103` (confidence: 0.35)
- **Duplicated block (6 lines, 2 locations)** — `src/routes.ts:226` (confidence: 0.35)
- **Duplicated block (6 lines, 2 locations)** — `src/routes.ts:176` (confidence: 0.35)
- **Near-duplicate block (6 lines, 2 locations, renamed identifiers)** — `src/routes.ts:177` (confidence: 0.30)
- **Near-duplicate block (6 lines, 2 locations, renamed identifiers)** — `src/routes.ts:337` (confidence: 0.30)
- **Near-duplicate block (6 lines, 2 locations, renamed identifiers)** — `src/routes.ts:210` (confidence: 0.30)
- **Near-duplicate block (6 lines, 2 locations, renamed identifiers)** — `src/routes.ts:51` (confidence: 0.30)
- **Near-duplicate block (6 lines, 2 locations, renamed identifiers)** — `src/components/classic/Article.ts:45` (confidence: 0.30)
- **Near-duplicate block (6 lines, 2 locations, renamed identifiers)** — `src/components/classic/Article.ts:38` (confidence: 0.30)
- **Near-duplicate block (6 lines, 2 locations, renamed identifiers)** — `src/components/classic/Article.ts:68` (confidence: 0.30)
- **Near-duplicate block (6 lines, 2 locations, renamed identifiers)** — `src/components/flex/Article.ts:21` (confidence: 0.30)

## githygiene (6 signals)

- **Possible generic secret in test/e2e/test-download-404-delete-workflow.sh:27** — `test/e2e/test-download-404-delete-workflow.sh:27` (confidence: 0.60)
- **Possible generic secret in test/e2e/test-download-404-delete-workflow.sh:123** — `test/e2e/test-download-404-delete-workflow.sh:123` (confidence: 0.60)
- **Possible generic secret in test/e2e/test-metadata-404-delete-workflow.sh:27** — `test/e2e/test-metadata-404-delete-workflow.sh:27` (confidence: 0.60)
- **Possible generic secret in test/e2e/test-metadata-404-delete-workflow.sh:124** — `test/e2e/test-metadata-404-delete-workflow.sh:124` (confidence: 0.60)
- **Possible generic secret in test/temporal.test.ts:190** — `test/temporal.test.ts:190` (confidence: 0.60)
- **Possible generic secret in test/temporal.test.ts:202** — `test/temporal.test.ts:202` (confidence: 0.60)

## lotteryrisk (7 signals)

- **Critical lottery risk: . (lottery risk 1, primary: Christian DiMare-Baits 85%)** — `.` (confidence: 0.80)
- **Critical lottery risk: bin (lottery risk 1, primary: Christian DiMare-Baits 100%)** — `bin` (confidence: 0.80)
- **Critical lottery risk: docker (lottery risk 1, primary: Christian DiMare-Baits 40%)** — `docker` (confidence: 0.80)
- **Critical lottery risk: helm/templates (lottery risk 1, primary: Christian DiMare-Baits 40%)** — `helm/templates` (confidence: 0.80)
- **Critical lottery risk: src (lottery risk 1, primary: Christian DiMare-Baits 56%)** — `src` (confidence: 0.80)
- **Critical lottery risk: src/components (lottery risk 1, primary: Christian DiMare-Baits 100%)** — `src/components` (confidence: 0.80)
- **Critical lottery risk: test (lottery risk 1, primary: Christian DiMare-Baits 59%)** — `test` (confidence: 0.80)

## patterns (9 signals)

- **No test file found for bin/scratch.py** — `bin/scratch.py` (confidence: 0.30)
- **No test file found for src/components/Article.ts** — `src/components/Article.ts` (confidence: 0.30)
- **No test file found for src/components/classic/Article.ts** — `src/components/classic/Article.ts` (confidence: 0.30)
- **No test file found for src/components/flex/Article.ts** — `src/components/flex/Article.ts` (confidence: 0.30)
- **No test file found for src/db.ts** — `src/db.ts` (confidence: 0.30)
- **No test file found for src/index.ts** — `src/index.ts` (confidence: 0.30)
- **No test file found for src/routes.ts** — `src/routes.ts` (confidence: 0.30)
- **Low test ratio in src/components/classic: 0 test files / 4 source files** — `src/components/classic` (confidence: 0.40)
- **Low test ratio in src: 0 test files / 4 source files** — `src` (confidence: 0.45)

## todos (16 signals)

- **TODO: TODO comment (no description)** — `TODO.md:1` (confidence: 0.50)
- **TODO: Support multiple image builds.** — `profile.sh:51` (confidence: 0.50)
- **TODO: Submit a ticket to @yugabytedb/pg repo complaining about loadBalance** — `src/db.ts:53` (confidence: 0.50)
- **TODO: Submit a ticket to @yugabytedb/pg repo complaining about loadBalance** — `src/db.ts:84` (confidence: 0.50)
- **TODO: Handle the different GrantTypes in permission_grant** — `src/routes.ts:341` (confidence: 0.50)
- **TODO: Filter groups by connector_id when we have multiple Igloo Connectors** — `src/routes.ts:379` (confidence: 0.50)
- **TODO: TODO comment (no description)** — `TODO.md:1` (confidence: 0.50)** — `stringer-focused.md:24` (confidence: 0.60)
- **TODO: Support multiple image builds.** — `profile.sh:51` (confidence: 0.50)** — `stringer-focused.md:25` (confidence: 0.60)
- **TODO: Submit a ticket to @yugabytedb/pg repo complaining about loadBalance** — `src/db.ts:53` (confidence: 0.50)** — `stringer-focused.md:26` (confidence: 0.60)
- **TODO: Submit a ticket to @yugabytedb/pg repo complaining about loadBalance** — `src/db.ts:84` (confidence: 0.50)** — `stringer-focused.md:27` (confidence: 0.60)
- **TODO: Handle the different GrantTypes in permission_grant** — `src/routes.ts:341` (confidence: 0.50)** — `stringer-focused.md:28` (confidence: 0.60)
- **TODO: Filter groups by connector_id when we have multiple Igloo Connectors** — `src/routes.ts:379` (confidence: 0.50)** — `stringer-focused.md:29` (confidence: 0.60)
- **TODO: Implement Temporal workflow status check if CLI is available** — `test/e2e/test-download-404-delete-workflow.sh:253` (confidence: 0.50)** — `stringer-focused.md:30` (confidence: 0.60)
- **TODO: Implement Temporal workflow status check if CLI is available** — `test/e2e/test-metadata-404-delete-workflow.sh:254` (confidence: 0.50)** — `stringer-focused.md:31` (confidence: 0.60)
- **TODO: Implement Temporal workflow status check if CLI is available** — `test/e2e/test-download-404-delete-workflow.sh:253` (confidence: 0.50)
- **TODO: Implement Temporal workflow status check if CLI is available** — `test/e2e/test-metadata-404-delete-workflow.sh:254` (confidence: 0.50)

## vuln (12 signals)

- **Vulnerable dependency: qs [CVE-2025-15284]** — `package-lock.json` (confidence: 0.80)
- **Vulnerable dependency: qs [CVE-2026-2391]** — `package-lock.json` (confidence: 0.80)
- **Vulnerable dependency: glob [CVE-2025-64756]** — `package-lock.json` (confidence: 0.95)
- **Vulnerable dependency: minimatch [CVE-2026-27904]** — `package-lock.json` (confidence: 0.95)
- **Vulnerable dependency: minimatch [CVE-2026-26996]** — `package-lock.json` (confidence: 0.60)
- **Vulnerable dependency: minimatch [CVE-2026-27903]** — `package-lock.json` (confidence: 0.95)
- **Vulnerable dependency: jws [CVE-2025-65945]** — `package-lock.json` (confidence: 0.95)
- **Vulnerable dependency: flatted [CVE-2026-32141]** — `package-lock.json` (confidence: 0.95)
- **Vulnerable dependency: axios [CVE-2026-25639]** — `package-lock.json` (confidence: 0.95)
- **Vulnerable dependency: js-yaml [CVE-2025-64718]** — `package-lock.json` (confidence: 0.80)
- **Vulnerable dependency: diff [CVE-2026-24001]** — `package-lock.json` (confidence: 0.60)
- **Vulnerable dependency: ajv [CVE-2025-69873]** — `package-lock.json` (confidence: 0.60)

