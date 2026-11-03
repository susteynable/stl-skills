# Core Pipelines

Legacy Azure Pipelines reference for Tracks G through L and Track N. GitHub-hosted services follow `github-actions.md` instead. Do not copy these `develop` / `test` / `master` gates, the 5-minute China Helm timeout, or `AKSHosted` into a GitHub workflow.

## Scope classification

Canonical backend pipelines treat `develop` as **CI + API publish**.

| On `develop` | Action |
|---|---|
| Build / Test | Run |
| Package (`stey-*-api/publish` / Nexus jar) | Run |
| Artifacts (pipeline `drop` for Helm) | Skip |
| Docker publish | Skip |
| Deploy | Skip |

- Scope classification should happen before editing individual conditions.

## Develop and deploy gates

- **Package** must run on develop with `condition: succeeded()` (or equivalent that does **not** exclude `refs/heads/develop`) so dependent services can consume the published API jar from develop pushes.
- Do **not** put `ne(...develop)` on the Package **stage** — that skips compile/API publish too. Gate Docker with step conditions instead (`assets/docker-publish-gates.yml`).
- **Artifacts** should skip develop with `succeeded()`-style gating that excludes `refs/heads/develop` (Helm drop is only needed for deploy branches).
- Deploy approval must require both Build and Artifacts to be `Succeeded`.
- `Skipped` must never be enough to unlock deployment.

## Docker publish

- Publish Docker only on the intended long-lived branches, normally `test` and `master`.
- Keep Docker conditions in sync with upstream build and artifact state.
- Do **not** Docker-publish on develop even when Package runs (step-level `ne(...develop)` on Docker login + `docker:publish`).

## Helm deploy

- Normalize deploy arguments to `--timeout 5m`.
- Remove `--atomic` unless the repo has an explicit exception.
- Keep argument changes isolated from unrelated stage logic.

## AKSHosted pool

- Use `pool.name: AKSHosted`.
- Remove `vmImage` or `poolVmImage` when the job runs on that named pool.

## Split pipelines (PR vs release)

- Prefer **two** definitions (templates under `assets/`):
  - `../assets/pr-pipeline.yml` → `azure-pipelines/pr-pipeline.yml` — best-effort PR-Agent + Build/Test on `AKSHosted` (Build Validation); Build `dependsOn` PRAgent but still runs if review fails
  - `../assets/release-pipeline.yml` → `azure-pipelines/release-pipeline.yml` — **normal/release** CI/CD: Build / Package / Artifacts / Deploy (no PR-Agent)
- Canonical release path is always `azure-pipelines/release-pipeline.yml` (ADO `{RepoName}`). Never leave the release definition on `azure-pipelines/azure-pipelines.yml`.
- On migration: delete the obsolete combined `azure-pipelines/azure-pipelines.yml` and retarget `{RepoName}` → `release-pipeline.yml`; create `{RepoName}(PR)` → `pr-pipeline.yml`.

## PR-Agent (Azure Repos / Track N)

- Out of band from develop/deploy Docker/Helm tracks: use Track N + `pr-pipeline.yml`.
- Image: `steycr.azurecr.cn/steycr/pr-agent:latest` after a one-time mirror from `codiumai/pr-agent` — AKSHosted times out on Docker Hub; do not use `ubuntu-latest` + `docker.io` for Stey services.
- Docker@2 login to the service `containerRegistry` before `docker pull`.
- Azure Repos requires Branch Policy Build Validation pointing at **pr-pipeline**; YAML `pr:` is not sufficient.
- Protected branches: **min 1 human approver** + Build Validation → **`{RepoName}(PR)`** (e.g. `SteyApiConsole(PR)`; not release `{RepoName}`); do not require Build Service as a reviewer. UI + `az repos policy` recipes: `tracks/track-n-branch-policies.md`.
- New PR validation ADO pipelines must be named `{RepoName}(PR)`; YAML path stays `azure-pipelines/pr-pipeline.yml`.
- Prefer `System.AccessToken` + build-service repo permissions over a personal PAT.
- PR-Agent only runs `describe` / `review` / `improve` and posts comments — no vote reset, hard-gate, `[APPROVED]` inject, or scripted Approve; humans approve merges.
- Review is best-effort (`continueOnError` / warn + `exit 0`); Build/Test still runs if PRAgent is Succeeded / SucceededWithIssues / Failed.
- Grant Contribute to pull requests so the Build Service can post comments.
- Standards TOML: Azure Repo `WikiTechnical/.ci/pr-standards/` (master) via Items API + AccessToken — TDD/PRD/code `*-standards.toml`.

Details: `tracks/track-n-pr-agent-azure-devops.md` and `tracks/track-n-branch-policies.md`.

## Verification

- Use direct `rg` checks on the edited YAML.
- Report which stages still run on develop, publish Docker, or deploy after the change.
- Confirm Package is enabled on develop and Artifacts / Docker / Deploy remain gated off.
- For PR-Agent edits: confirm describe/review/improve are best-effort (`continueOnError` / warn + `exit 0`); Build still runs on PRAgent Failed; vote-reset / Hard-Gate / Auto-Approve / `[APPROVED]` inject steps are absent.
- For new-repo enablement: confirm ADO PR pipeline is named `{RepoName}(PR)` and branch policies have min 1 reviewer + Build Validation on that definition (see `tracks/track-n-branch-policies.md`).
