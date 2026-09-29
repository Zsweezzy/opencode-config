# Changelog

## [Unreleased]

All notable changes to this repository are documented here. Versioning follows
[Semantic Versioning](https://semver.org/spec/v2.0.0.html) (`vMAJOR.MINOR.PATCH`
git tags), format based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [v1.0.1] - 2026-09-29

### Added

- Documented the skill-curation design in `FEATURES.md`: 68 curated skills stay
  advertised, 801 carry `metadata: { opencode/autoinvoke: false }` and remain
  loadable by exact id, and a session-start prompt on a trivial `hi` measures
  **12,222 input tokens**, down from 93,058 before curation.
- `skill-routing` and `house-rules` described as on-demand skills, so the
  priority index and the standing rules are no longer paid for on every session
  start.

### Changed

- `agent/super.md` reduced to 1,857 bytes; the 71-skill priority index now lives
  in the `skill-routing` skill.
- `SKILLS.md` inventory refreshed: 848 directories / 872 `SKILL.md`, adding
  `house-rules` and `skill-routing`. `terminal-browser` is a symlink and
  `opencode` is discovered from `~/.hermes`; both are noted rather than listed
  as plain `~/.agents/skills` directories.

## [1.0.0] - 2026-09-29

### Added

- `config/opencode.json`, `config/cli.json` — global config (`default_agent:
  super`, `opencode-froggy` plugin) and TUI preferences (`tokyonight` theme,
  browser-style keybinds: `ctrl+w` closes the session, `ctrl+t` opens a new one;
  leader-key defaults preserved).
- `config/commands/` — 19 slash commands.
- `agent/super.md` — the `@super` capability-router agent definition, kept to
  1,857 bytes: role, four operating rules, and pointers to the `house-rules`
  and `skill-routing` skills. The priority index itself lives in `skill-routing`
  so it is not paid for on every session start.
- `plugin/metadata.json` + `deps/opencode-froggy-1.3.0.tgz` — the plugin pinned
  at v1.3.0 (MIT) with a vendored tarball for offline restore.
- `scripts/backup.sh`, `scripts/restore.sh`, `scripts/verify.sh`,
  `scripts/version-bump.sh` — the snapshot/restore/release loop.
- `docs/ARCHITECTURE.md`, `docs/ROLLBACK.md`, `AGENTS.md`, `llms.txt`.
- `SKILLS.md` — inventory (848 directories / 872 `SKILL.md`), provenance by
  source, license status per group, and reinstall instructions.

### Notes

- The 846 third-party skill directories are **not** included. Most carry no
  license and are therefore all-rights-reserved; see `SKILLS.md` and
  `THIRD_PARTY_NOTICES.md` §2.5–2.8. `scripts/verify.sh` fails the build if a
  `skills/` directory reappears.
- `config/service.json` is excluded (plaintext password). Only the redacted
  `config/service.json.example` is tracked.
- This repository starts at `1.0.0` with a single commit. It is the
  publish-shaped counterpart of a longer private history, so there is no prior
  version to roll back to within this repository.
