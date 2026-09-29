# Install Guide

How to take this repository and turn it into a working OpenCode environment on
a fresh machine (or restore over a broken one).

## 1. Prerequisites

| # | Dependency | Version | Why | Install |
|---|---|---|---|---|
| 1 | **git** | ≥ 2.40 | Clone, tags, rollback | `sudo apt install git` (Debian/Ubuntu), `sudo pacman -S git` (Arch), or https://git-scm.com |
| 2 | **OpenCode** | ≥ 2.0 | The runtime | `curl -fsSL https://opencode.ai/install \| bash` |
| 3 | **Node.js + npm** | ≥ 22 LTS / npm ≥ 10 | OpenCode resolves the `opencode-froggy` plugin from npm | https://nodejs.org or `nvm` |
| 4 | **GitHub CLI** `gh` | any recent | Cloning and pushing | `sudo apt install gh` or https://cli.github.com, then `gh auth login` |
| 5 | **Rust toolchain** *(optional)* | latest stable | The `@super` agent's Rust-first policy (`cargo fmt`, `clippy`, `test`, `audit`) | https://rustup.rs |

## 2. Get the repository

```bash
git clone https://github.com/Zsweezzy/opencode-config.git
cd opencode-config
git checkout v1.0.0        # or the tag you want to restore
```

## 3. Install OpenCode (if not present)

```bash
curl -fsSL https://opencode.ai/install | bash
opencode --version
```

## 4. Restore the environment

```bash
scripts/restore.sh        # DRY RUN: prints exactly what will happen
scripts/restore.sh --yes  # moves existing config to *.bak-<timestamp>, then restores
```

| Repo path | → machine path |
|---|---|
| `config/opencode.json` | `~/.config/opencode/opencode.json` |
| `config/cli.json` | `~/.config/opencode/cli.json` |
| `config/commands/*` | `~/.config/opencode/commands/` |
| `agent/super.md` | `~/.config/opencode/agents/super.md` |

`cli.json` holds the theme (`tokyonight`) and the TUI keybinds; delete it after
restore if you want OpenCode's defaults.

`config/service.json` is **not** in this repository — it holds a plaintext
password. Copy `config/service.json.example` to `~/.config/opencode/service.json`
and fill in the real value if you use the HTTP service.

## 5. Plugin (`opencode-froggy`)

- **Default:** just start OpenCode. The `plugins: ["opencode-froggy"]` entry in
  `opencode.json` makes it fetch `opencode-froggy@latest` (pinned to **v1.3.0**
  here) from npm into its plugin cache. Verify with
  `ls ~/.cache/opencode/npm/ | grep froggy`.
- **Offline:** unpack the vendored tarball into the plugin cache:
  ```bash
  mkdir -p ~/.cache/opencode/npm/opencode-froggy@latest/offline/node_modules
  tar -xzf deps/opencode-froggy-1.3.0.tgz \
    -C ~/.cache/opencode/npm/opencode-froggy@latest/offline/node_modules
  ```
  (OpenCode scans its npm cache; the hash directory varies by version.)

## 6. Skills

Skills are **not** bundled here — see [`SKILLS.md`](SKILLS.md) for why, the
846-directory inventory, provenance, and how to reinstall. Restore them
afterwards:

```bash
mkdir -p ~/.agents/skills
# then per skill: git clone <upstream> ~/.agents/skills/<skill-id>
```

The plugin contributes 4 more (`tdd`, `extreme-programming`, `backlog-management`,
`ask-questions-if-underspecified`) once step 5 is done.

## 7. First launch

```bash
opencode
```

- A new session starts on **`@super`** (`default_agent` in `opencode.json`).
- Sanity checks: `/agents` shows `@super` as primary; `scripts/verify.sh` in the
  repo ends with `VERIFY OK`.

## 8. Troubleshooting

| Problem | Fix |
|---|---|
| `command not found: opencode` | Re-run the installer from step 3; put the installer's reported path on `PATH`. |
| Plugin not loading | npm unreachable → use the offline path in step 5; confirm `plugins: ["opencode-froggy"]` is still in `config/opencode.json`. |
| Restore overwrote something | Previous files are at `~/.config/opencode.bak-<timestamp>`; copy back selectively. |
| `verify.sh` reports a secret | `config/service.json` must never be committed — remove it and check `.gitignore`. |
| `verify.sh` says `skills/ is present` | Someone committed the skill tree. Delete it; `scripts/verify.sh` enforces this. |
| Skill count lower than expected | Expected — skills are installed separately. Compare against the list in `SKILLS.md`. |
