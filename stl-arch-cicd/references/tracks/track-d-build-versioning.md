# Track D - Build Versioning

Read `../core-toolchain.md`.

Verify:

- `ThisBuild / version` remains the package version.
- Jar and image postfixes match `../github-actions.md`: `test/*` → `-uat.<run>`, `release/*` → `-prod`, and `main` publishes no image.
- Version checks use explicit sbt output, and that image tag is the one Helm deploys.
