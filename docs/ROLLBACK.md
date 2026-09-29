# Versioning & Rollback

This repo exists so you can **always roll back** to a known-good environment.

## 1. Version naming

- `VERSION` (repo root) holds the current `MAJOR.MINOR.PATCH` — semantic
  versioning (SemVer 2.0.0).
- Every release is a git tag: `v1.0.0`, `v1.0.1`, `v1.1.0`, `v2.0.0`, …
- Rules:
  - **PATCH** — default for `scripts/backup.sh` snapshots: syncs the live
    environment, records a `CHANGELOG.md` entry under `[Unreleased]`, bumps
    PATCH, commits, tags `vX.Y.Z`, and pushes.
  - **MINOR** — a meaningful environment addition (new command, plugin
    update, feature): `scripts/backup.sh --type feat` (auto → MINOR) or
    `scripts/version-bump.sh minor`.
  - **MAJOR** — a breaking change to the environment or policy (e.g., a
    different agent architecture or a restructuring of restore):
    `scripts/backup.sh --breaking` (auto → MAJOR) or
    `scripts/version-bump.sh major`.
- `backup.sh` derives the level from Conventional-Commits signals: unreleased
  commits since the last tag (`feat:` → MINOR, `BREAKING CHANGE`/`!` → MAJOR)
  plus the snapshot's own `--type` (default `chore` → PATCH). Explicit
  `--major`/`--minor`/`--patch` always win.
- `version-bump.sh` moves the `[Unreleased]` block into a dated `[x.y.z]`
  section, commits as `chore(release): vX.Y.Z`, tags, and pushes.

## 2. Rolling back

### 2.1 One-command rollback of the whole environment

```bash
cd ~/opencode-config
git fetch --tags origin
git checkout v1.0.0          # or any earlier tag
scripts/restore.sh           # dry-run first
scripts/restore.sh --yes     # apply; previous state kept in *.bak-<timestamp>
```

### 2.2 Roll back a single area (without touching the rest)

```bash
git checkout v1.0.0 -- config/opencode.json agent/super.md
# then apply manually to the live machine; never commit the revert to main
```

### 2.3 Restore from a backup of the backup (worst case)

Every applied restore creates `~/.config/opencode.bak-<timestamp>` on the target
machine. If an old tag ever points at a broken snapshot, those timestamped
copies are the escape hatch — copy files back from them. Skills are not
restored by `restore.sh`; see [`../SKILLS.md`](../SKILLS.md) for how to recover
them.

## 3. Changelog discipline

- `## [Unreleased]` always exists; `backup.sh` appends snapshot bullets there.
- No release happens without a `CHANGELOG.md` entry for the released version.
- Breaking changes are called out in the changelog body (see vX.Y.Z sections).

## 4. Keeping history honest

- **Never** `git push --force` to the backup remote; rollback depends on
  append-only history.
- **One-time correction exception:** a tag created moments ago by a tooling bug
  and never used as a restore point may be torn out — reset to the previous
  tag, re-release correctly, delete the bad tag on origin, and force-push
  `main` once. Note the correction in the change summary.
- **Never** edit `VERSION` by hand — use `backup.sh` / `version-bump.sh`.
- If a snapshot captured bad state, do **not** rewrite that tag: cut a new
  PATCH following the fix (e.g. `v1.0.0` bad → fix → `v1.0.1`), and note the
  bad tag in `docs/ROLLBACK.md`.

## 5. Worked example

```bash
scripts/backup.sh            # v1.0.1 → v1.0.2 (small edit; chore → PATCH)
scripts/backup.sh --type feat   # new command → MINOR (v1.1.0)
scripts/backup.sh --breaking    # policy change → MAJOR (v2.0.0)
scripts/backup.sh --no-push  # snapshot locally if the remote is unreachable
scripts/backup.sh --no-bump  # sync + commit without a new version/tag
scripts/version-bump.sh minor -m "add /gh-create-pr command"
# … oops, v1.1.0 broke restore …
git checkout v1.0.1 && scripts/restore.sh --yes   # back to known-good
```