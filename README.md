# opencode-config

A versioned, restorable snapshot of a personal [OpenCode](https://github.com/sst/opencode)
environment: config, commands, the `@super` agent definition, and the tooling
that backs them up.

> [!IMPORTANT]
> **No skills are published here.** The original private backup contained 846
> third-party skill directories, the large majority of which carry no license
> and are therefore all-rights-reserved. Those are deliberately excluded. The
> inventory and reinstall instructions live in [`SKILLS.md`](SKILLS.md); the
> full per-component licensing analysis lives in
> [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md).

## What's inside

| Path | Content |
|---|---|
| `config/opencode.json` | Global config: `default_agent`, plugins |
| `config/cli.json` | TUI preferences: theme, keybinds |
| `config/commands/` | 19 slash commands |
| `config/service.json.example` | Redacted placeholder — the real file holds a password and is gitignored |
| `agent/super.md` | The `@super` capability-router agent definition |
| `plugin/metadata.json` | Pinned facts for the `opencode-froggy` plugin |
| `deps/opencode-froggy-1.3.0.tgz` | Vendored MIT tarball for offline restore |
| `scripts/` | `backup.sh`, `restore.sh`, `verify.sh`, `version-bump.sh` |
| `docs/` | [ARCHITECTURE.md](docs/ARCHITECTURE.md), [ROLLBACK.md](docs/ROLLBACK.md) |

Total: ~490 KB, single initial commit, no history to unwind.

## Quick start

```sh
git clone https://github.com/Zsweezzy/opencode-config.git
cd opencode-config
scripts/verify.sh          # must print VERIFY OK
scripts/restore.sh         # dry run: prints the plan
scripts/restore.sh --yes   # applies it
```

Then follow [`INSTALL.md`](INSTALL.md) for the parts `restore.sh` does not
cover: the OpenCode runtime itself, the plugin, and skills.

## Back up your own environment

```sh
scripts/backup.sh              # sync, auto-bump the version, tag, commit, push
scripts/backup.sh --no-push    # local only
scripts/backup.sh --dry-run    # show what would sync
```

The bump level is derived from the change type (`feat` → MINOR, `fix`/`docs`/
`chore` → PATCH, breaking → MAJOR), overridable with `--major`/`--minor`/
`--patch`.

## The plugin

`opencode-froggy` is declared in `config/opencode.json` and resolved by OpenCode
from npm automatically. The MIT-licensed tarball in `deps/` is a convenience
for restoring without network access.

## License

Everything authored here is MIT — see [`LICENSE`](LICENSE). Third-party
components keep their own terms; see
[`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md).
