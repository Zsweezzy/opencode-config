# Architecture

How this repository maps to the live OpenCode environment it backs up.

## 1. Source → repo → restore

| Live machine (source of truth) | This repo | Restore target (fresh machine) |
|---|---|---|
| `~/.config/opencode/opencode.json` | `config/opencode.json` | `~/.config/opencode/opencode.json` |
| `~/.config/opencode/cli.json` | `config/cli.json` | `~/.config/opencode/cli.json` |
| `~/.config/opencode/commands/` (19 files) | `config/commands/` | `~/.config/opencode/commands/` |
| `~/.config/opencode/agents/super.md` | `agent/super.md` | `~/.config/opencode/agents/super.md` |
| `~/.cache/opencode/npm/opencode-froggy@latest/*/…` (plugin) | `deps/opencode-froggy-1.3.0.tgz` + `plugin/metadata.json` | npm registry / offline cache (see `INSTALL.md` step 5) |
| `~/.agents/skills/**` (846 dirs, 870 `SKILL.md`) | **not tracked** — inventoried in `SKILLS.md` | installed separately, per `SKILLS.md` |
| — (authored) | `README.md`, `FEATURES.md`, `INSTALL.md`, `SKILLS.md`, `AGENTS.md`, `llms.txt`, `THIRD_PARTY_NOTICES.md`, `CHANGELOG.md`, `docs/`, `scripts/`, `VERSION`, `LICENSE` | kept in repo (not applied) |

## 2. What is intentionally excluded

| Path | Why |
|---|---|
| `skills/**` (846 third-party dirs) | Most carry **no license** → all rights reserved. This repo is public; `scripts/verify.sh` fails if a `skills/` directory appears. `SKILLS.md` holds the inventory, provenance, and reinstall path instead. |
| `~/.config/opencode/service.json` | Contains a **plaintext password**. Only `config/service.json.example` (redacted) is shipped. `.gitignore` + `scripts/verify.sh` guard it. |
| `~/.cache/opencode/**` (except plugin facts) | Rebuildable caches, session data, local auth state. |
| `~/.local/share/opencode/**`, session history | Machine-local runtime state, not configuration. |

## 3. Why this layout

- **Mirror-identical paths** (`config/`, `agent/`) make `restore.sh` a trivial
  copy and make diffs against the live tree readable.
- **Skills are documented, not vendored.** The alternative — shipping
  all-rights-reserved third-party content in a public repo — is not an option.
  An inventory plus install instructions is a sufficient restore path because
  skills are re-fetchable from their upstreams.
- **One top-level `VERSION`** drives semver tags for the whole snapshot — a
  single rollback unit.
- **`scripts/`** encodes the only two directions of data flow
  (`backup.sh` home→repo, `restore.sh` repo→home) plus the safety gates
  (`verify.sh`, `version-bump.sh`), so the repo never depends on memory of
  "how we did it last time".
- **`deps/`** holds the exact pinned plugin artifact, so restore does not
  depend on npm availability.
- **Docs are split by audience**: humans (`README`, `INSTALL`, `FEATURES`,
  `SKILLS`, `docs/`) vs agents (`AGENTS.md`, `llms.txt`) — both stay in sync
  with the same facts (counts, versions) via `AGENTS.md`'s completion checklist.

## 4. Data flow

```
live machine                          git repo (origin = public GitHub)
  │                                        ▲
  │ scripts/backup.sh (sync + bump + tag)  │ push
  ▼                                        │
~/.config/opencode  ───────────────►  config/ agent/
                                        ▲
  │ scripts/restore.sh --yes ◄─────────┘
  ▼
fresh machine (with *.bak-<timestamp> of anything overwritten)

~/.agents/skills  ──►  NOT synced (see SKILLS.md)
```

## 5. Counts & facts (kept current by `AGENTS.md`)

- Commands: 19. Agent: 1 (`super.md`, mode: primary, `default_agent: super`).
- Plugin: `opencode-froggy` v1.3.0 (MIT), 16 tools + 4 skills, vendored
  `deps/opencode-froggy-1.3.0.tgz` (345,981 bytes).
- Skills (live only, not tracked): 846 dirs / 870 `SKILL.md` in
  `~/.agents/skills`; +4 plugin skills → 874 advertised in a complete install.
- Runtime: OpenCode ≥ 2.0 (not vendored — install per `INSTALL.md`).
- Node/npm, git, gh, Rust: see `INSTALL.md` prerequisites.
