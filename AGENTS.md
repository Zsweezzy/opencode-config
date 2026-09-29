# AGENTS.md — instructions for AI agents working in this repo

This repo is a **versioned backup** of a personal OpenCode environment. It
exists so the owner can roll back to any known-good state and restore the
environment to a fresh machine. You are working inside the backup/storage
layer, not the live environment.

It is also **public**. That is deliberate: it ships only MIT/authored content.
The third-party skill tree lives in a separate private repo, and its absence
here is enforced by `scripts/verify.sh`.

## Purpose (read first)

Two jobs, in this order:

1. **Preserve** — mirror the live environment's artifacts and keep them
   accurate, versioned, and documented.
2. **Restore** — apply any tagged snapshot back onto a machine.

Anything that compromises reproducibility (missing files, unversioned changes,
secrets, stale docs) breaks the repo's purpose.

## Golden rules

- **Sync direction is one-way.** The live machine is the source of truth.
  `scripts/backup.sh` copies home → repo. Edits made directly in this repo are
  *proposed changes*: apply them to the live machine first, or never let the
  repo drift silently — run `scripts/restore.sh --yes` after deliberate edits.
- **Never commit secrets.** `~/.config/opencode/service.json` contains a
  plaintext password and must never appear here (only `service.json.example`).
  If you add any artifact, extend `.gitignore` for it and confirm
  `scripts/verify.sh` stays green.
- **No third-party skills here.** This repo is public; the 846 third-party skill
  directories are excluded because most carry no license. Never commit a
  `skills/` directory — `scripts/verify.sh` fails the build if one appears. To
  track a skill here, first confirm it has an explicit permissive license,
  then record provenance and license status in `THIRD_PARTY_NOTICES.md` and add
  its LICENSE file alongside it. Everything unlicensed stays out.
- **Versions never go backwards without a release.** `scripts/backup.sh`
  auto-derives the bump from the change type (feat → MINOR, fixes/docs/chore →
  PATCH, breaking → MAJOR) with `--major`/`--minor`/`--patch` overrides;
  `scripts/version-bump.sh` handles explicit releases. Never edit `VERSION` or
  `CHANGELOG.md` by hand without following the same shape.
- **Docs stay truthful.** If the environment changes (skill inventory, plugin
  version, command list, agent behavior), update `FEATURES.md`, `INSTALL.md`,
  `SKILLS.md`, and the numbers in `README.md` in the same change.

## Before you finish any work

1. Run `scripts/verify.sh` — it must end with `VERIFY OK`.
2. Confirm `git status` is clean or the change is intentional and committed.
3. Confirm `VERSION` matches the latest tag (`git describe --tags`), or a
   version-bump commit exists.
4. Update `CHANGELOG.md` for user-visible changes.

## Repo map

| Path | Content | Touched by |
|---|---|---|
| `VERSION` | semver string | scripts only |
| `CHANGELOG.md` | release notes | scripts + manual releases |
| `config/` | opencode.json, cli.json, commands/, service.json.example | backups |
| `agent/super.md` | `@super` agent definition | backups + intentional edits |
| `SKILLS.md` | skill inventory, provenance, reinstall path | manual, on skill changes |
| `plugin/metadata.json` | froggy plugin facts | manual, on plugin version change |
| `deps/*.tgz` | vendored plugin tarball | `npm pack opencode-froggy@<ver>` |
| `scripts/` | backup, restore, version-bump, verify | maintenance |
| `docs/` | ARCHITECTURE.md, ROLLBACK.md | manual |
| root docs | README, FEATURES, INSTALL, SKILLS, THIRD_PARTY_NOTICES, llms.txt | manual |

## Completion criteria (checklist)

- [ ] `scripts/verify.sh` → `VERIFY OK`
- [ ] No `service.json` or secret material in the tree
- [ ] No `skills/` directory, no unlicensed third-party content
- [ ] `VERSION` == latest tag (`vX.Y.Z`)
- [ ] `CHANGELOG.md` reflects current `VERSION`
- [ ] Command/plugin counts in docs match reality
- [ ] Commit message follows Conventional Commits (`chore(backup): …`,
      `chore(release): v…`)