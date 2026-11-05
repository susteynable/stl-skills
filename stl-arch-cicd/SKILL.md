---
name: stl-arch-cicd
description: >
  Use when changing Stey Scala CI/CD on GitHub Actions: test/publish/UAT
  workflows, manual China and Nordics prod deploys, sbt version and image
  tags, Nexus plus per-repo GitHub Packages publish, global ACR, Helm on AKS.
  Azure Pipelines, AKSHosted, and PR-Agent are legacy and apply only to a
  repo that is still on Azure DevOps.
---

# Stey CI/CD Architecture

## Purpose

Keep Stey service build and deploy changes on the GitHub Actions path: branch roles, sbt publish and image tags, Nexus plus each service repo's GitHub Packages, global ACR, and Helm deploys to China and Nordics AKS.

## Workflow

1. Read `references/github-actions.md` before editing CI. Copy [stey-cms](https://github.com/susteynable/stey-cms/tree/main/.github/workflows) rather than designing a new workflow.
2. Read Track A, then the minimum toolchain tracks from `references/tracks/track-index.md`.
3. Use `references/core-toolchain.md` for sbt, aether, version tags, Nexus, and dependency bumps.
4. Finish with Track M, using the GitHub rows in `references/troubleshooting.md`.

Azure Pipelines (Tracks G–L and N, `references/core-pipelines.md`, `assets/*pipeline*.yml`) are legacy. Use them only when the repo is still on Azure DevOps and has no GitHub workflows. Migrated repos are `zARCHIVED-*` and disabled; change those services on GitHub.

## Guardrails

- `main` publishes a snapshot jar only. Do not build an image or deploy from `main`. `feature/current` is not a workflow trigger.
- `test/*` publishes a snapshot jar and `<version>-uat.<run>`, then deploys China UAT. Match the `test/` prefix, not the branch name `test`.
- `release/*` publishes a release jar and `<version>-prod`, then stops. Do not deploy from that push. China prod and Nordics prod are separate manual workflows and deploy `<version>-prod`.
- Set `Docker / publish / skip := !publishesDockerImage` so `main` does not push an image. Do not tag `main` as `-dev.<run>`.
- Runner is `ubuntu-latest`. Do not use the China AKS self-hosted pool for GitHub Actions.
- Environments are only `uat`, `prod-china`, and `prod-nordics`. The Nordics image check still uses `prod-china`.
- Do not add a federated credential per repo. Log in to `steycr.azurecr.io` with `GLOBAL_ACR_PASSWORD`. The JRE base image is public `eclipse-temurin:11.0.16_8-jre-focal`.
- API jars publish to Nexus first, then `https://maven.pkg.github.com/susteynable/<service-repo>`. Resolve other artifacts from `https://maven.pkg.github.com/susteynable/_` with `GH_MAVEN_USERNAME` and `GH_MAVEN_TOKEN`. Do not publish to shared `susteynable/stl`. A GitHub Packages 409 still continues to `docker:publish`. A Nexus failure does not.
- Keep `publish / skip := true` on Play modules that already skip jar publish.
- Helm: China `--timeout 15m` and `progressDeadlineSeconds: 900`; Nordics `--timeout 5m`. No `--atomic`. `cancel-in-progress: false`.
- Do not invent Nexus URLs, credentials, or latest versions. Do not bump Akka or Slick through the Stey dependency workflow.
- Keep project-root `.jvmopts` tracked with `-Xmx4G` / `-Xss4m`. Workflow sbt steps also pass `-J-Xmx4G -J-Xss4m`.

## Tracks

| Track | Focus |
|---|---|
| A | Git sync and scope |
| B | sbt launcher and heap |
| C | aether publish plugin |
| D | build versioning |
| E | Nexus metadata discovery |
| F | Stey dependency bumps |
| M | verification and troubleshooting |
| G–L, N | Legacy Azure Pipelines, AKSHosted, PR-Agent, branch policies |

## Reference Index

| When you need... | Read |
|---|---|
| GitHub workflows, tags, ACR, Maven, Helm | `references/github-actions.md` |
| Track order | `references/tracks/track-index.md` |
| sbt, aether, versioning, Nexus, dependency bumps | `references/core-toolchain.md` |
| Shared sbt heap | `references/core-toolchain.md`; template `assets/jvmopts` |
| GitHub failure symptoms | `references/troubleshooting.md` |
| Legacy Azure pipeline gates | `references/core-pipelines.md` |
| Nexus discovery script | `scripts/fetch_stey_nexus_latest.sh` |

## Activation Keywords

`GitHub Actions`, `workflow_dispatch`, `test/sprint-102`, `feature/current`, `release/*`, `prod-china`, `prod-nordics`, `GLOBAL_ACR_PASSWORD`, `steycr.azurecr.io`, `azurecr-global`, `publishToAll`, `GH_MAVEN_USERNAME`, `GH_MAVEN_TOKEN`, `susteynable/_`, `docker:publish`, `ImagePullBackOff`, `ubuntu-latest`, `sbt`, `.jvmopts`, `Xmx4G`, `aether`, `Nexus`, `fetch_stey_nexus_latest.sh`.
