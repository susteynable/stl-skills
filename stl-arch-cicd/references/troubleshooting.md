# Troubleshooting

Use this for symptom-first routing.

| Symptom | Check first |
|---|---|
| UAT `ImagePullBackOff` for `…-uat.<run>` `not found` | `github-actions.md` — `dockerVersionPostfix` matched only `test`, so `test/sprint-102` published `-dev.<run>` |
| Prod Helm did not run | `github-actions.md` — `docker manifest inspect` did not find `steycr.azurecr.io/steycr/<service>:<version>-prod` |
| `azure/login` `AADSTS700213` or no matching federated identity | Job uses `environment: prod`, or a new per-repo credential was added. Use `uat` / `prod-china` / `prod-nordics` only |
| Image landed in `steycr.azurecr.cn` | `dockerRepository` or the workflow login still targets China ACR. Push and pull `steycr.azurecr.io` |
| Build still pulls `steycr.azurecr.cn/.../eclipse-temurin` | `dockerBaseImage` must be public `eclipse-temurin:11.0.16_8-jre-focal` |
| Same release re-run never publishes the image | GitHub Packages 409 aborted the job. Continue to `docker:publish` only when the log contains `status code: 409` |
| Publish log has GitHub Packages and no new Nexus jar | API project sets `publishTo` only. Use `publishToAllSettings` and publish to this repo, not `susteynable/stl` |
| GitHub Packages 401, or another service's jar does not resolve | `github-actions.md` — `GH_MAVEN_USERNAME` / `GH_MAVEN_TOKEN`, and resolver `https://maven.pkg.github.com/susteynable/_` |
| Nexus 401/403 and no image | Publish job is missing `NEXUS_USERNAME` / `NEXUS_PASSWORD`. Nexus failure must stop before `docker:publish` |
| Runner cannot clone the repo | Workflow is on a China AKS self-hosted runner. Use `ubuntu-latest` |
| Deploy cancelled mid-rollout | `cancel-in-progress` is true. Keep it false |
| sbt fails before pipeline logic matters | Tracks B and C |
| Compile OOM / GC thrash with `Heap: … max 1.00GB` on AKSHosted | Track B — missing tracked `.jvmopts` (`-Xmx4G`); do not gitignore it; not a stale checkout of a deleted local file |
| Compile OOM despite `.jvmopts` `-Xmx4G` | Track B — project `.sbtopts` `-J-Xmx…` overriding heap, or agent memory too small for 4G |
| Latest Stey dependency cannot be found | Track E script path, resolver, credentials |
| Script reports an older version than Nexus release metadata | Track E parser order: prefer `<release>` over stale `<latest>` |
| Develop does not publish API jar (Package skipped) | Tracks G and H — Package stage must be `condition: succeeded()`; do not put `ne(...develop)` on the stage |
| Develop packages Docker / Artifacts drop / deploys | Tracks G, H, J, I — Package(+Build) may run on develop; Docker login/publish and Artifacts/Deploy must stay gated |
| Deploy approval unlocks when upstream stages are skipped | Track I |
| Docker publish runs on the wrong branch | Track J |
| Helm deploy arguments drift | Track K |
| Pipeline uses image selection with AKSHosted | Track L |
| Wrong standards applied (TDD rules on code PR, etc.) | Track N — set `STANDARDS_FILE` to matching WikiTechnical `.ci/pr-standards` file (tdd / prd / code) |
| PR-Agent never runs on Azure Repos PR | Track N — missing Build Validation on target branch (see `track-n-branch-policies.md`) |
| PR merges with zero human Approves | Track N — set Minimum number of reviewers = 1 (blocking) on protected branches |
| Merge blocked waiting for Build Service Approve | Track N — remove Build Service required-reviewer policy; only min 1 **human** approver |
| `registry-1.docker.io` / Docker Hub i/o timeout pulling `codiumai/pr-agent` | Track N — AKSHosted cannot reach docker.io; mirror to `steycr.azurecr.cn/steycr/pr-agent:latest`, Docker@2 login, set `prAgentImage` |
| `docker pull` not-found for `steycr.../pr-agent` | Track N — one-time mirror not pushed yet (see Track N mirror commands) |
| PR Build Validation runs Package/Deploy | Track N — Build Validation must point at `{RepoName}(PR)` / `pr-pipeline.yml`, not `{RepoName}` release |
| Cannot find PR pipeline in Build Validation picker | Track N — create/rename definition to `{RepoName}(PR)` (e.g. `SteyCrs(PR)`), not `… PR` or bare repo name |
| Branch CI missing after split | Track N/G — copy `assets/release-pipeline.yml`; retarget ADO `{RepoName}` from old `azure-pipelines.yml` → `azure-pipelines/release-pipeline.yml` |
| Release still points at `azure-pipelines/azure-pipelines.yml` | Track N — rename/remove that file; set `{RepoName}` YAML path to `azure-pipelines/release-pipeline.yml` |
| Build/Test runs before PR-Agent finishes | Track N — `Build` must `dependsOn: PRAgent` |
| Build/Test skipped because PR-Agent failed | Track N — review is best-effort; Build condition must allow Succeeded / SucceededWithIssues / Failed |
| PR-Agent stage fails and blocks Build Validation | Track N — fetch/run must warn + `exit 0` with `continueOnError: true`; copy current `assets/pr-pipeline.yml` |
| Build Validation still points at old `azure-pipelines.yml` or bare `{RepoName}` | Track N — create `{RepoName}(PR)` → `pr-pipeline.yml` and point Build Validation there (not release) |
| `SYSTEM_PULLREQUEST_PULLREQUESTID: unbound variable` | Track N — manual run / not a PR build; gate on `Build.Reason` (review step should warn + skip, not fail) |
| `can't open file '.../pr_agent/cli.py'` | Track N — Docker `-w` overrode image WORKDIR; mount config only |
| `Invalid URL 'org/org/_apis': No scheme supplied` | Track N — `AZURE_DEVOPS__ORG` must be full `System.CollectionUri` |
| PR-Agent comments appear as a human | Track N — still using personal PAT; switch to `System.AccessToken` |
| PR-Agent 401/403 posting comments | Track N — build service missing Contribute to pull requests (warn only; must not fail stage) |
| Old pipeline still auto-approves / casts vote:10 | Track N — remove vote-reset, purge, `[APPROVED]` inject, and Hard-Gate steps; copy current `assets/pr-pipeline.yml` |
| Required Build Service reviewer still blocks after green build | Track N — auto-approve is removed; drop required Build Service reviewer policy if it was only for scripted vote |

Recovery flow:

1. Re-run Track A scope classification.
2. Re-check the directly responsible track and its prerequisite track.
3. Verify the final YAML or sbt evidence with explicit commands, not memory.
