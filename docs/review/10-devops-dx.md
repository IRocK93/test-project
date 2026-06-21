# 10 — DevOps & Developer Experience Audit

**Date:** 2026-06-17
**Severity Score:** 🔴 Critical (3 Critical, 4 High, 6 Medium, 2 Low)
**Verdict:** Strong internal docs and CI, but `.gitignore` blocks critical infrastructure files and CI is partially broken.

---

## Summary

The BabyMon project has strong internal documentation (`docs/` folder with 15 well-structured markdown files), a comprehensive CI pipeline with separate jobs for API lint/test/build, Flutter golden and unit tests, and Docker build/smoke test, plus a multi-stage Dockerfile with non-root user. However, **critical git hygiene issues** and **CI configuration drift** prevent a new developer from cloning and running reliably: **(1) `.gitignore` blocks `Dockerfile*` and `docker-compose*.yml`** from version control — the Dockerfile and compose file are NOT tracked; **(2) `local.properties` is tracked** with machine-specific paths that break builds on other machines; **(3) CI runs `npm run test:ci` but no `test:ci` script exists** in `package.json`; **(4) CI lint step swallows failures with `|| true`**; **(5) 250 dirty files in the working tree** with README and SPEC deleted. No monorepo tooling exists (two independent apps). No pre-commit hooks. No `.nvmrc`.

---

## Findings

| ID | Severity | Title | Location | Evidence | Recommendation |
|---|---|---|---|---|---|
| DX01 | 🔴 Critical | **`.gitignore` blocks `Dockerfile*` and `docker-compose*.yml`** | `.gitignore:16-17` | `Dockerfile*` and `docker-compose*.yml` rules prevent the Dockerfile and compose file from being tracked. Anyone cloning gets zero containerization. | Change to `Dockerfile.local*` and remove `docker-compose*.yml` rule (or use `docker-compose.override.yml`). Then `git add -f` the real files. |
| DX02 | 🔴 Critical | **`local.properties` tracked with machine paths** | `apps/mobile/android/local.properties` | Contains `sdk.dir=C:\\Android\\Sdk`, `flutter.sdk=C:\\src\\flutter`. Breaks builds on other machines. | `git rm --cached` and add to `.gitignore`. |
| DX03 | 🔴 Critical | **CI `test:ci` script missing** | `.github/workflows/ci.yml:60` vs `apps/api/package.json` | CI runs `npm run test:ci` but `package.json` has `"test": "jest"` and `"test:e2e"` — no `test:ci`. CI hard-fails on this step. | Add `"test:ci": "jest --ci --coverage --forceExit"` to `package.json`. |
| DX04 | 🟠 High | **CI lint step swallows failures** | `.github/workflows/ci.yml:44` | `npm run lint \|\| true` — lint errors pass CI silently. | Remove `\|\| true`. |
| DX05 | 🟠 High | **Generated/derived files tracked in git** | `apps/mobile/.dart_tool/`, `.flutter-plugins-dependencies`, `ios/Flutter/ephemeral/`, `ios/Flutter/Generated.xcconfig`, `ios/Flutter/flutter_export_environment.sh` | These regenerate on every `flutter pub get` / `flutter build`. Tracking them causes merge conflicts. | `git rm --cached` all generated files. Ensure `.gitignore` covers them. |
| DX06 | 🟠 High | **README.md and SPEC.md deleted** | `git status` shows `D README.md`, `D SPEC.md` | No project overview survives in version control. New devs have no entry point. | Restore from git history or rewrite minimal versions. Cross-reference `docs/00-README-FIRST.md`. |
| DX07 | 🟠 High | **250 dirty files in working tree** | `git status --short` count ≈ 250 | Massive uncommitted refactoring spanning ~40 API files + ~40 mobile files. Risk of lost work. | Commit or stash the working tree. Split into logical PRs. |
| DX08 | 🟡 Medium | **No monorepo tooling** | No `pnpm-workspace.yaml`, `turbo.json`, `nx.json`, no root `package.json` | Two completely independent apps. `packages/shared/` directory exists but is empty. | If shared types/DTOs are needed, adopt Turborepo or pnpm workspaces. Otherwise delete `packages/shared/`. |
| DX09 | 🟡 Medium | **No `engines` field or `.nvmrc`** | `apps/api/package.json` | Node.js version not pinned. CI uses Node 20, Docker uses `node:20-bookworm`, but nothing enforces locally. | Add `"engines": { "node": ">=20.0.0" }` to `package.json`. Add `.nvmrc` with `20`. |
| DX10 | 🟡 Medium | **No Prettier config** | No `.prettierrc` at project level | Only NestJS boilerplate `.prettierrc` inside `node_modules`. | Add `.prettierrc` at `apps/api/` with `singleQuote: true, trailingComma: 'all', printWidth: 100`. |
| DX11 | 🟡 Medium | **Stray/junk files** | Root: `fix_remaining.py`, `write.bat`, `package-lock.json` (empty). Mobile: `_edit.py`, `_gen.py`. API: `nul` (Windows reserved name), `cleanup.mjs`. Junk dirs: `old doc/`, `graphify-out/`, `temp_script/`, `Sources/`, `Tests/`. | Delete or move to `.gitignore`. `nul` is especially problematic — can't be deleted normally on Windows. |
| DX12 | 🟡 Medium | **No Dependabot/Renovate** | No `.github/dependabot.yml` | No automated dependency updates. | Add `.github/dependabot.yml` for npm and pub ecosystems. |
| DX13 | 🟡 Medium | **`baby_mon.iml` tracked in git** | `apps/mobile/baby_mon.iml` | IntelliJ module file. Mobile `.gitignore` line 16 correctly ignores `*.iml` but the file was added before gitignore. | `git rm --cached` + verify `.gitignore` covers it. |
| DX14 | 🔵 Low | **CI auto-commits golden baselines to main** | `.github/workflows/ci.yml:190-219` | `update-goldens` job automatically pushes updated golden PNGs on main push. Can cause unexpected commits. | Review whether auto-commit is desired. Consider PR-based golden updates instead. |
| DX15 | 🔵 Low | **No mobile build verification in CI** | `.github/workflows/ci.yml` | CI has no `flutter build` step (APK/IPA). Only tests and golden screenshots. | Add Android build verification job. |

---

## Onboarding Assessment

**A new developer CANNOT clone and run this project in its current state:**

- **Clone** succeeds but Dockerfile and compose are missing (blocked by `.gitignore`)
- **No README** — first file a developer looks for is deleted
- **No Node version** — nothing tells them which Node.js to install
- **`local.properties` conflicts** on any non-Windows machine or different SDK path
- **CI broken** — `test:ci` script doesn't exist
- **Lint errors masked** — CI ignores them

**Good news:** If they find `docs/00-README-FIRST.md`, it provides a clear quickstart. This should be promoted to the root README.

---

## Things Done Well

1. **CI coverage comprehensive** — separate jobs for API lint/test/build, Flutter golden + unit + analyzer, Docker build + smoke test, Slack notifications, golden auto-update.
2. **Multi-stage Dockerfile** — builder → production separation, non-root user (`nestjs`), production-only deps, Prisma generate for target platform.
3. **Excellent `docs/` folder** — 15 numbered markdown files: onboarding quickstart, architecture, auth flow, known gotchas with root cause analysis, file inventory, screen-building guide, deployment, diagnostic guide, achievements, XP system spec, theme system spec.
4. **Knowledge graph** (`.understand-anything/knowledge-graph.json`) — 50+ node entries with complexity ratings and git commit hash tracking.
5. **Docker compose** — PostgreSQL + backend + test DB services with health checks and dependency ordering.
6. **`.env.example` well-documented** — every variable has comments explaining generation and location (Stripe Dashboard, AWS console).
7. **`analysis_options.yaml`** — strict-casts, strict-inference, hand-picked lint rules.
8. **`.eslintrc.js`** — properly configured TypeScript ESLint with NestJS conventions.
9. **Flutter codegen tooling** — `build_runner`, `json_serializable`, `drift_dev` configured.
10. **Prisma configured** — migrate, seed, studio scripts, `env("DATABASE_URL")` datasource.

---

## Action Plan

| # | Action | Effort |
|---|---|---|
| 1 | **Fix `.gitignore`** — remove Dockerfile/compose rules. `git add -f` the real files. | S |
| 2 | **Add `test:ci` script** to `package.json`. | S |
| 3 | **`git rm --cached` local.properties** and add to `.gitignore`. | S |
| 4 | **Restore README.md** (promote `docs/00-README-FIRST.md` to root). | S |
| 5 | **Fix CI lint step** — remove `\|\| true`. | S |
| 6 | **Untrack generated Flutter files** (`.dart_tool/`, `.flutter-plugins-dependencies`, ephemeral, Generated.xcconfig). | S |
| 7 | Add `engines` field to `package.json` + `.nvmrc`. | S |
| 8 | Clean stray files (`nul`, `_edit.py`, `_gen.py`, `fix_remaining.py`, `write.bat`, empty dirs). | S |
| 9 | Add Prettier config at `apps/api/`. | S |
| 10 | Add Dependabot config. | S |
| 11 | Add pre-commit hooks (husky/lefthook: lint-staged, secret scanning). | M |
| 12 | Commit or stash the 250-file working tree. | M |
| 13 | Evaluate monorepo tooling (Turborepo) if shared types are needed. | M |
| 14 | Add mobile build verification to CI. | M |
