# Track D - Build Versioning

Read `../core-toolchain.md`.

Verify:

- `ThisBuild / version` remains the package version.
- Jar and image postfixes match `../github-actions.md`, including `test/*` → `-uat.<run>` and `release/*` → a bare image tag.
- Version checks use explicit sbt output, and that image tag is the one Helm deploys.
