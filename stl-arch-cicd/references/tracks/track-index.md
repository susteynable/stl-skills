# Track Index

GitHub Actions is the live CI path. Read `../github-actions.md` before any workflow, image-tag, publish, or Helm change.

Use the smallest track set that matches the request, but keep order. Tracks G–L and N are legacy Azure Pipelines. Do not apply them to a repo that already has `.github/workflows/`.

| Track | File | Use for |
|---|---|---|
| A | `track-a-git-sync-and-scope.md` | Mandatory sync and scope |
| B | `track-b-sbt-launcher.md` | sbt launcher + tracked `.jvmopts` (`-Xmx4G`) for CI heap |
| C | `track-c-aether-publish-plugin.md` | aether publish behavior |
| D | `track-d-build-versioning.md` | version source and verification |
| E | `track-e-nexus-metadata-discovery.md` | latest Stey artifact discovery |
| F | `track-f-stey-dependency-bumps.md` | repo dependency bumps |
| G | `track-g-pipeline-scope-classification.md` | develop vs deploy scope |
| H | `track-h-develop-ci-gates.md` | develop Package (API publish) on; Artifacts/Docker/Deploy off |
| I | `track-i-deploy-stage-gates.md` | deploy approval gating |
| J | `track-j-docker-publish-gates.md` | Docker branch gates |
| K | `track-k-helm-deploy-normalization.md` | Helm arguments |
| L | `track-l-akshosted-agent-pool.md` | named pool rules |
| M | `track-m-verification-and-troubleshooting.md` | final checks and troubleshooting |
| N | `track-n-pr-agent-azure-devops.md` (+ `track-n-branch-policies.md`) | Split pipelines + best-effort PR-Agent; ADO name `{RepoName}(PR)`; branch policies: min 1 human approver + Build Validation |
