# GitHub Actions CI/CD

Live path for Susteynable Scala services. Copy an existing conversion instead of inventing a pipeline. Reference workflows: [stey-cms](https://github.com/susteynable/stey-cms/tree/main/.github/workflows) (`deploy-stey-cms.yml`, `deploy-prod-china.yml`, `deploy-prod-nordics.yml`). Same shape on `stey-connect-*`, `stey-api-*`, and the other `susteynable/stey-*` service repos.

`references/core-pipelines.md` and Tracks G–L and N are the archived Azure Pipelines path. Do not apply them to a GitHub repo. Do not re-enable a `zARCHIVED-*` Azure repo or its pipeline to change CI.

## Branch roles

| Git ref | What CI does |
|---|---|
| `main` | Default branch and PR base. A push publishes a snapshot jar only. No image, no deploy. A pull request into `main` runs tests only. |
| `feature/current` | Integration line (was Azure `develop`). Not a workflow trigger by itself. Open a PR into `main` to test. |
| `test/*` (current line `test/sprint-102`) | Push or manual run: snapshot jar, image `<version>-uat.<run>`, then deploy China UAT. |
| `release/*` | Push or manual run: release jar and image `<version>-prod`, then stop. No deploy. |
| Pull request into `main` or `release/*` | Tests only. No publish, no deploy. |

Do not trigger publish or deploy from `develop`, `test`, or `master`. Those names are the Azure mapping sources, not GitHub triggers.

## Workflows

Three workflows per service:

1. **Deploy &lt;Service&gt;** — `workflow_dispatch`, push to `main`, `test/**`, and `release/**`, pull request to `main` and `release/**`.
2. **Deploy PROD-CHINA** — `workflow_dispatch` only.
3. **Deploy PROD-NORDICS** — `workflow_dispatch` only.

Publish workflow permissions: `contents: read`, `id-token: write`, `packages: write`. Runner: `ubuntu-latest`. China AKS self-hosted runners cannot clone `github.com`.

```yaml
concurrency:
  group: deploy-<service>-${{ github.ref }}
  cancel-in-progress: false
```

Prod workflows use their own group, also with `cancel-in-progress: false`.

Jobs:

| Job | When | Environment |
|---|---|---|
| Test | Always | none |
| Publish | Push or manual run on `main`, `test/*`, or `release/*` | none. This job does not call Azure |
| Deploy UAT | Push or manual run on `test/*` only | `uat` |
| Prod check image | Manual prod workflow | `prod-china` for **both** China and Nordics checks |
| Prod deploy | After the image exists | `prod-china` or `prod-nordics` |

Never bind a job to an environment named `prod`.

## Auth, registry, Maven

- Do not add a federated credential per repo. Org apps `github-actions-susteynable` already match `environment:uat`, `environment:prod-china`, and `environment:prod-nordics`.
- China `azure/login`: `environment: azurechinacloud`, vars `UAT_*` or `PROD_CHINA_*`.
- Nordics `azure/login`: `environment: azurecloud`, vars `PROD_NORDICS_*`.
- Publish, China UAT, and Nordics prod: `docker login` to org var `GLOBAL_ACR_LOGIN_SERVER` (`steycr.azurecr.io`) with `GLOBAL_ACR_USERNAME` and org secret `GLOBAL_ACR_PASSWORD`. Do not `az acr login --name steycr` (that is China ACR `steycr.azurecr.cn`).
- China prod uses only China ACR. Org vars `CHINA_ACR_LOGIN_SERVER` (`steycr.azurecr.cn`) and `CHINA_ACR_LOGIN_USERNAME`, org secret `CHINA_ACR_PASSWORD`. The prod tag must already be in that registry. The workflow checks it and deploys it. It does not pull the global image or copy it across.
- Workflow `env` holds what every job in that file shares: `ACR`, `ACR_USERNAME`, `ACR_PASSWORD`, and `AZURE_ENVIRONMENT`. Deploy PROD-CHINA sets `AZURE_ENVIRONMENT` from `PROD_CHINA_AZURE_ENVIRONMENT`. Deploy PROD-NORDICS sets it from `PROD_NORDICS_AZURE_ENVIRONMENT`. Deploy Stey * sets the global ACR trio on the workflow `env`, and sets `AZURE_ENVIRONMENT` from `UAT_AZURE_ENVIRONMENT` on the UAT job only. Do not repeat these on steps.
- `dockerRepository := Some("steycr.azurecr.io")`, `dockerUsername := Some("steycr")`, `dockerBaseImage := "eclipse-temurin:11.0.16_8-jre-focal"`. Publish does not push to China ACR.
- Helm `--set image.repo=${ACR}/${ACR_USERNAME}/` uses the workflow `env`, so China prod is `steycr.azurecr.cn/steycr/` and UAT and Nordics are `steycr.azurecr.io/steycr/`. Values files are overridden by that `--set`. Deployment `imagePullSecrets` stays `azurecr-global`. Apply that pull secret, with the registry this deploy uses, before `helm upgrade`.
- API jars go to Nexus, then to this repo at `https://maven.pkg.github.com/susteynable/<service-repo>`, via `publishToAllSettings` (`project/PublishToAll.scala`, `aether-deploy` 0.30.0). SNAPSHOT → `maven-snapshots`. RELEASE → `maven-releases`. Do not publish to shared `maven.pkg.github.com/susteynable/stl`.
- Resolve other Stey artifacts with one resolver, `https://maven.pkg.github.com/susteynable/_`. Do not add a resolver per dependency repo. Keep Nexus ahead of that resolver.
- Those two resolvers must not share a display name. Name the publish resolver `"GitHub Packages Publish"` and leave the `susteynable/_` resolver as `"GitHub Packages"`. Do not change either URL. A repo with only one GitHub Packages resolver keeps that single name. `publishToAll` logs `Publishing to GitHub Packages Publish`.
- Workflow env on sbt jobs: `NEXUS_USERNAME`, `NEXUS_PASSWORD`, `GH_MAVEN_USERNAME`, `GH_MAVEN_TOKEN`. Do not hardcode the GitHub Packages user. Do not put those secrets in sbt sources. `GITHUB_TOKEN` does not resolve packages across the org. Secret names must not start with `GITHUB_`; `GH_` is allowed.
- Play modules that already set `publish / skip := true` stay skipped. Akka services publish `<service>-api` and docker-publish `<service>-impl`.
- GitHub Packages HTTP 409 on an existing RELEASE jar: continue to `docker:publish` when that branch publishes an image. A Nexus failure stops the job before the image push. `main` skips ACR login and `docker:publish`.

## Versions and image tags

Pass `BUILD_SOURCE_BRANCH_NAME=${{ github.ref_name }}` and `BUILD_NUMBER=${{ github.run_number }}`. sbt heap: `-J-Xmx4G -J-Xss4m`.

GitHub Actions runs `sbt test` and does not run scalafix. Leave SemanticDB off for that compile:

```scala
// CI never runs scalafix, so skip semanticdb generation there.
ThisBuild / semanticdbEnabled := !sys.env.contains("GITHUB_ACTIONS")
```

Local and IDE compiles still generate SemanticDB. Keep `semanticdbEnabled := true` only when the workflow itself runs scalafix: `stey-sbt-scalafix-rule` runs `sbt test` with `ScalafixTestkitPlugin`. A scripted build that reads SemanticDB, such as the i18n generator fixture, stays unconditional too.

| Branch | Jar | Image tag |
|---|---|---|
| `main` | `<version>-SNAPSHOT` | none. `Docker / publish / skip` is true |
| `test/*` | `<version>-SNAPSHOT` | `<version>-uat.<run>` |
| `release/*` | `<version>-RELEASE` | `<version>-prod` |
| `feature/current` and any other branch | `<version>-SNAPSHOT` | none |

`test/sprint-102` must take the `test/` image rule. Do not match the branch name `test` or `master`, and do not publish a `-dev.<run>` tag. The Helm `--set image.version=<service>:${tag}` must equal the sbt `Published image` tag.

China UAT and China prod: `helm upgrade --install --wait --timeout 15m --cleanup-on-fail --history-max 10`, and chart `progressDeadlineSeconds: 900`. Nordics prod: `--timeout 5m`. Do not use `--atomic`.

Nordics prod Helm runs only after `docker manifest inspect` finds `steycr.azurecr.io/steycr/<service>:<version>-prod`. China prod Helm runs only after the same inspect finds `steycr.azurecr.cn/steycr/<service>:<version>-prod`. Resolve a `release/*` commit with `gh api` when the workflow is started from `main` via the `release_branch` input. Do not use `az acr repository show`.

## What not to change

- Leave `azure-pipelines/` in the tree. Migrated Azure repos are already `zARCHIVED-<Name>` with `isDisabled: true` and pipeline `queueStatus: disabled`.
- Do not add a per-repo federated credential.
- Do not push application images to `steycr.azurecr.cn` from publish, UAT, or Nordics prod. China prod only reads that registry.
