# Track A - Git Sync And Scope

Read `../core-toolchain.md` and `../core-pipelines.md` only as needed.

Verify:

- `git pull --rebase` ran before edits.
- On a GitHub service repo, the edited branch is `main`, `feature/current`, `test/*`, or `release/*`. Do not revive Azure `develop` / `test` / `master` as the CI triggers.
- Request scope is reduced to the minimum track set. CI behavior changes start from `../github-actions.md`.
