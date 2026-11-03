#!/usr/bin/env bash
# Validates stl-arch-cicd skill.
set -euo pipefail
SKILL_DIR="${1:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
die() { echo "ERROR: $*" >&2; exit 1; }
[[ -n "$SKILL_DIR" ]] || die "Usage: validate_skill.sh <skill-dir>"
"$SCRIPT_DIR/../../../_shared/scripts/validate_skill_base.sh" "$SKILL_DIR"
for ref in \
  references/github-actions.md \
  references/core-toolchain.md \
  references/core-pipelines.md \
  references/troubleshooting.md \
  references/tracks/track-index.md \
  references/tracks/track-a-git-sync-and-scope.md \
  references/tracks/track-b-sbt-launcher.md \
  references/tracks/track-c-aether-publish-plugin.md \
  references/tracks/track-d-build-versioning.md \
  references/tracks/track-e-nexus-metadata-discovery.md \
  references/tracks/track-f-stey-dependency-bumps.md \
  references/tracks/track-g-pipeline-scope-classification.md \
  references/tracks/track-h-develop-ci-gates.md \
  references/tracks/track-i-deploy-stage-gates.md \
  references/tracks/track-j-docker-publish-gates.md \
  references/tracks/track-k-helm-deploy-normalization.md \
  references/tracks/track-l-akshosted-agent-pool.md \
  references/tracks/track-m-verification-and-troubleshooting.md \
  references/tracks/track-n-pr-agent-azure-devops.md \
  references/tracks/track-n-branch-policies.md \
  assets/pr-pipeline.yml \
  assets/release-pipeline.yml \
  assets/pr-agent-azure-pipelines.yml
do
  [[ -f "$SKILL_DIR/$ref" ]] || die "Missing: $ref"
done
echo "OK: stl-arch-cicd references present"
