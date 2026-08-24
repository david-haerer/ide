# IDE — Isolated Development Environment

This repo defines a Docker image, not an application. Changes are primarily to `Dockerfile`, `entrypoint.sh`, and dotfiles under `config/`.

## Build

```bash
docker build -t ide .
```

## Runtime requirements

The entrypoint expects these env vars and will fail silently or misconfigure if they are missing:

- `GIT_USER_NAME` / `GIT_USER_EMAIL` — sets `git config --global user.*`
- `GITHUB_TOKEN` — written to `~/.netrc` for GitHub auth
- `OPENROUTER_API_KEY` — written to `~/.local/share/opencode/auth.json`

## User & shell

- User: `dev` (uid/gid 1000)
- Shell: `fish` (vi bindings)
- Editor: `helix`
- `PATH` includes `/home/dev/.local/bin`

## Config conventions

- `config/*` is copied to `/home/dev/.config/*` at **build time**, except `config/omp` which is copied to `/home/dev/.omp` (omp reads `~/.omp`, not XDG). Runtime changes inside the container are not persisted.
- `config/opencode/opencode.json` pins model to `openrouter/moonshotai/kimi-k2.6`, disables autoupdate/sharing, and registers the `chrome-devtools` MCP server via `bunx`.
- `config/omp/agent/config.yml` is copied to `~/.omp/agent/config.yml` — omp's persistent settings (`modelRoles`, theme, etc.). A `setupVersion: 1` marker is included so the image ships "already set up" and skips the first-run wizard.
- `bin/setup-skills.sh` installs community skills at build time into `~/.agents/skills/<name>/SKILL.md` (Agent Skills spec layout — one canonical dir, no symlinks):
  - **codex-cli** reads `$HOME/.agents/skills` directly (verified in `codex-rs/core-skills/src/loader.rs` — the "user-installed skills" root, present since v0.146.0).
  - **omp/pi** reads the same dir via its `agents` provider (`~/.agent/skills` + `~/.agents/skills`, user scope, priority 70).
  - Sources: `mattpocock/skills` (all non-deprecated categories) and `cursor/plugins` `pstack/skills`; name collisions (`tdd`, `teach`) keep the mattpocock copy canonical and prefix pstack's as `pstack-<name>`. Rebuild the image to refresh from upstream (shallow clones at `main`); override repo/ref with `MATT_POCOCK_REPO`/`MATT_POCOCK_REF`/`PSTACK_REPO`/`PSTACK_REF` build-args.
- `config/helix/config.toml` uses `ayu_dark`, relative line numbers, mouse off, and remaps `w`/`b`/`e` to subword motions.
- `config/fish/config.fish` defines abbreviations agents may see in shell sessions: `oc` (opencode), `hx` (helix), `lg` (lazygit), `dc` (docker compose), etc.

## Editing this repo

- Test config syntax before committing (e.g. `fish -n config.fish`, `hx --health` in a running container).
- There are no tests, lint scripts, or CI workflows. Verify by building the image locally.
