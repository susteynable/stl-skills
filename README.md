# STL Skills

Collection of Stey (Susteynable) internal skills for AI coding agents — architecture conventions, component recipes, and helper tooling. Each skill is a self-contained directory with its own `SKILL.md`.

## Skills

| Skill | Purpose |
|---|---|
| `stl-arch-akka` | Stey Akka CQRS services: aggregates, domain events, projection wiring |
| `stl-arch-cicd` | Stey Scala CI/CD on GitHub Actions: publish, image tags, global ACR, Helm to AKS |
| `stl-arch-play` | Stey Play + Tapir APIs: ApplicationLoader, routing, handler wiring |
| `stl-component-apm` | Stey JVM APM/Sentry wiring via `stey-common-apm` |
| `stl-component-i18n-messages` | Stey enum labels and system strings via `stey-common-i18n-message` |
| `stl-convention` | Stey Scala/Akka implementation style: handlers/delegates, Slick layering |
| `stl-helper-akka-journal-event-deletion` | Retiring Akka Persistence domain events in the journal-owning service |
| `stl-helper-service-src-navigator` | Locating Stey/SteyApi/SteyConnect/SteyWeb service sources |
| `stl-helper-skill-update` | Creating, updating, refactoring Cursor agent skills |
| `stl-ide-toolbox` | macOS Cursor/VS Code keybindings, Metals/Bloop/sbt IDE setup |

## Usage

Load the skill whose name matches your task (e.g. via your agent's skill loader). Skills that share a domain cross-reference each other — start with the `stl-convention` or the matching `stl-arch-*` skill and follow its reference index.
