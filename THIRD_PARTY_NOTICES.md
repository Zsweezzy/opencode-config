# Third-Party Notices & Compliance Report

Scope: what this repository **redistributes**, and what it deliberately does
not. Full text in [`LICENSE`](LICENSE) (MIT, authored content).

## 1. Verdict summary

**This repository is safe to publish.** It contains only content that is either
authored here under MIT or carries an explicit permissive license. The 846
third-party skill directories that made the original private backup
non-publishable are **not** here — see [`SKILLS.md`](SKILLS.md).

| Category | Count | Status |
|---|---|---|
| Authored content in this repo | all | MIT, cleared |
| OpenCode runtime | 1 | MIT, not bundled (installed separately) |
| `opencode-froggy` plugin tarball | 1 | MIT, vendored in `deps/`, notice preserved |
| Third-party skill directories | 846 | **excluded from this repository** |

## 2. Components

### 2.1 OpenCode — `sst/opencode` (runtime, not bundled)

- License: **MIT** — verified from
  `https://raw.githubusercontent.com/sst/opencode/dev/LICENSE` (2026-09-29).
- Nothing is copied from it. This repository stores the user's own
  configuration, commands, and agent definition.

### 2.2 `opencode-froggy` plugin — bundled dependency

- Version: `v1.3.0` from the npm registry. License: **MIT** (read from the
  installed package).
- Bundled: `deps/opencode-froggy-1.3.0.tgz` (345,981 bytes). MIT permits
  redistribution, and the package's own LICENSE and copyright notice are
  preserved inside the tarball.
- `plugin/metadata.json` records the pin and the plugin's 16 tools / 4 skills.
- The plugin's 4 skills are **not** duplicated in this repository; they arrive
  with the package at install time.

### 2.3 obra/superpowers skills (15)

- Source: `github.com/obra/superpowers`. License: **MIT**.
- Excluded here (third-party). Restore per `SKILLS.md`.

### 2.4 mattpocock/skills (38)

- Source: `github.com/mattpocock/skills`. License: **MIT** — verified from
  `https://raw.githubusercontent.com/mattpocock/skills/main/LICENSE`
  (Copyright (c) 2026 Matt Pocock).
- Excluded here. Restore per `SKILLS.md`.

### 2.5 inference.sh quick-start guides (10)

- Source: `github.com/inference-sh/skills`. **No LICENSE file found** in the
  installed directories or upstream → all rights reserved.
- Excluded here. They also require the paid `belt` CLI to run, and were
  documented as optional during install.

### 2.6 Skills carrying an explicit LICENSE file (8)

MIT: `agent-architecture`, `appinsights-instrumentation`,
`azure-resource-visualizer`, `azure-role-selector`, `winmd-api-search`.
Apache-2.0: `anti-ui-slop`, `quality-playbook`, `resemble-detect`.

These are the only skill directories cleared for redistribution. They are
still excluded here — the inventory plus upstream is sufficient to restore
them, and keeping them out keeps one rule simple: no third-party skill content
in this repository at all.

### 2.7 All remaining skill directories (~836)

Installed from Azure/Microsoft sample skills, Azure-Samples repositories, and
community skill packs. **No LICENSE file in any of them** → all rights reserved
by default. Excluded here.

### 2.8 `opencode` skill (1)

From a local `~/.hermes/skills/autonomous-ai-agents/opencode` install. No
LICENSE file. Excluded here.

### 2.9 Authored content (this repository)

`agent/super.md`, `config/`, `scripts/`, `docs/`, `deps/` metadata,
`README.md`, `SKILLS.md`, `FEATURES.md`, `INSTALL.md`, `AGENTS.md`, `llms.txt`,
`THIRD_PARTY_NOTICES.md`, `CHANGELOG.md`, `VERSION`, `LICENSE` — all MIT,
Copyright (c) 2026 Zsweezzy.

## 3. What is intentionally NOT here

| Path | Why |
|---|---|
| `skills/**` (846 dirs) | Predominantly unlicensed; see §2.5–2.8. |
| `~/.config/opencode/service.json` | Contains a **plaintext password**. Only `config/service.json.example` (redacted) ships, guarded by `.gitignore` and `scripts/verify.sh`. |
| OpenCode caches, session history, local auth state | Machine-local runtime state, not configuration. |

## 4. Findings

1. **Publishing is clear.** Every redistributable component is MIT or authored
   under MIT, with notices retained. The unresolved component class from the
   private audit is no longer present in this tree.
2. **`verify.sh` enforces the two rules that matter:** no `skills/` directory,
   and no `config/service.json`. Both fail the build.
3. **Retain notices.** If a third-party skill is ever added to this repository,
   record its provenance and license in this file in the same change, and keep
   its LICENSE file alongside it.
4. **Prefer the vendored, pinned plugin dependency** (`deps/…tgz`) and pinned
   `VERSION`/tags so restores are reproducible and rollback-able.

## 5. Verification method

- OpenCode MIT: LICENSE fetched from `sst/opencode`, `dev` branch (2026-09-29).
- mattpocock/skills MIT: LICENSE fetched from `main` (2026-09-29).
- obra/superpowers MIT: verified from upstream repository metadata.
- opencode-froggy MIT: `package.json` + LICENSE read from the installed package.
- Skill license census:
  `find ~/.agents/skills -maxdepth 2 \( -iname 'license*' -o -iname 'copying*' \)`
  → 8 files, each inspected.
- No inference.sh or remaining-skill license was found upstream or installed.
