# Features

What this environment provides, and what this repository contains.

## 1. The environment

### 1.1 `@super` — primary agent with automatic skill routing

- **Mode:** `primary`; set as `default_agent`, so every new session starts on
  `@super` — you never pick or add a skill yourself.
- **Auto-load rules:** scans the available-skill index before any task, loads
  the matching skills via the `skill` tool, then executes. Never asks which
  skill to use.
- **Repo-creation gate:** always asks before creating or publishing a GitHub
  repository (name + private/public) and waits for explicit confirmation.
  Pushing to an existing repo is normal work and never triggers the gate.
- **Rust-first engineering policy** for new code:
  - Rust edition 2024, stable rustup toolchain, cargo crate layout
    (`lib.rs`/`main.rs`, modules per feature, workspaces for multi-crate).
  - `cargo fmt` + `cargo clippy --all-targets -- -D warnings` must be clean.
  - `Result<T, E>` everywhere; `thiserror` for libraries, `anyhow` for
    binaries; no `unwrap`/`expect`/`panic!` in production paths.
  - tokio async with `spawn_blocking` / `tokio::select!` /
    `FuturesUnordered`; never block the executor.
  - Newtypes, enums over strings, `Option` for absence, builder patterns;
    `unsafe` only with `SAFETY:` comments.
  - `cargo test` green, `cargo audit` for new deps, rustdoc on public items,
    `tracing` observability.
  - Python only when explicitly requested or ecosystem-bound.
- **Curated 68-skill set advertised, 801 muted** out of 848. Muted skills carry
  `metadata: { opencode/autoinvoke: false }`: absent from the advertised list,
  still loadable by exact id, and listed in `SKILLS.md` so they stay greppable.
  A session-start prompt on a trivial `hi` measures **12,222 input tokens**,
  down from 93,058 before curation.
- **`skill-routing` skill** carries the 71-skill priority index in 10
  categories: core engineering loop, Rust & code quality, planning/design/
  workflow, writing & documentation, product & GTM, security & auditing
  routers, platform families (Qdrant, GitHub/CI, GraphQL), and meta. It loads on
  demand, so it costs nothing until a task is genuinely ambiguous.
- **`house-rules` skill** carries the three standing non-negotiables and is also
  loaded on demand. Fallback routing covers everything else.
- **Ponytail mode** (`/ponytail`, plus `lite|full|ultra`): a standing directive
  to prefer the smallest working change, with an explicit list of what must
  never be simplified away (validation, error handling that prevents data loss,
  security, accessibility basics).

### 1.2 Commands

**19 slash commands** in `config/commands/`: `agent-demote`, `agent-promote`,
`commit-push`, `diff-summary`, `doc-changes`, `gh-create-pr`,
`linear-stale-check`, `ponytail`, `ponytail-audit`, `ponytail-debt`,
`ponytail-gain`, `ponytail-help`, `ponytail-review`, `release`,
`review-changes`, `review-pr`, `send-to`, `simplify-changes`, `tests-coverage`.

### 1.3 `opencode-froggy` plugin v1.3.0 (pinned, vendored)

- **16 tools:** `agent-promote`; browser control (`preview`, `tabs.list`,
  `tabs.open`); Ethereum (`eth-address-balance`, `eth-address-txs`,
  `eth-token-transfers`, `eth-transaction`); `gitingest`;
  `list-child-sessions`; OpenCode session tools (`list_mcp_resources`,
  `read_mcp_resource`, `session_move`, `session_rename`); `pdf-to-markdown`;
  `prompt-session`.
- **4 skills:** `tdd`, `extreme-programming`, `backlog-management`,
  `ask-questions-if-underspecified`.
- Vendored as `deps/opencode-froggy-1.3.0.tgz` — restores work offline and stay
  pinned to the tested version.

### 1.4 Skills — installed, not bundled here

846 directories / 870 `SKILL.md` files live in `~/.agents/skills/`, plus 4 from
the plugin → **874 advertised** in a complete install. They are third-party and
excluded from this repository; see [`SKILLS.md`](SKILLS.md) for the inventory,
provenance, and reinstall path.

### 1.5 Configuration

- `config/opencode.json` — `plugins: ["opencode-froggy"]`,
  `default_agent: "super"`.
- `config/cli.json` — `tokyonight` theme, plus browser-style keybinds
  (`ctrl+w` closes the session, `ctrl+t` opens a new one) and the
  leader-key defaults kept intact.

## 2. This repository

### 2.1 Versioning & rollback

- `VERSION` + **semver git tags** — every snapshot is recoverable.
- `scripts/backup.sh` — one command to sync home → repo, **auto-derive the
  semver bump from the change type** (feat → MINOR, fix/chore/docs → PATCH,
  breaking → MAJOR; `--type`/`--breaking` classify, `--major`/`--minor`/`--patch`
  force), update `CHANGELOG.md`, tag, and push.
- `scripts/version-bump.sh <major|minor|patch>` — explicit releases.
- `scripts/restore.sh` — dry-run by default; `--yes` backs up the existing
  environment to `*.bak-<timestamp>` then restores.
- `docs/ROLLBACK.md` — rollback procedures.

### 2.2 Documentation

- **Humans:** `README.md`, `FEATURES.md`, `INSTALL.md`, `SKILLS.md`,
  `CHANGELOG.md`, `THIRD_PARTY_NOTICES.md`, `docs/ARCHITECTURE.md`,
  `docs/ROLLBACK.md`.
- **Agents:** `AGENTS.md` (operating rules + completion criteria), `llms.txt`
  (navigation index).

### 2.3 Security & compliance

- `service.json` excluded (plaintext password); only the redacted
  `config/service.json.example` ships, guarded by `.gitignore` and
  `scripts/verify.sh`.
- `scripts/verify.sh` — JSON validity, secret scan, no `skills/`, semver +
  tag consistency, plugin metadata; must end `VERIFY OK`.
- `THIRD_PARTY_NOTICES.md` — provenance and licensing for everything bundled,
  and what is deliberately excluded.
