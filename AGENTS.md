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
- `config/omp/agent/config.yml` is copied to `~/.omp/agent/config.yml` — omp's persistent settings (`modelRoles`, theme, etc.). A `setupVersion: 2` marker (omp's current `CURRENT_SETUP_VERSION`) plus a pinned `composer.shape` is included so the image ships "already set up" and skips the first-run wizard, which would otherwise ask about rounded border / composer shape and other settings on every startup.
  - Kagi is the default web-search provider: `config/omp/agent/config.yml` sets `providers.webSearchOrder: [kagi]`, and the key is supplied at runtime via the `KAGI_API_KEY` env var (never baked into the image). `config/omp/agent/mcp.json` additionally registers Kagi's hosted MCP server (`https://mcp.kagi.com/mcp`, `kagi_search_fetch`/`kagi_extract`) with `Authorization: Bearer ${KAGI_API_KEY}` — omp expands the placeholder and reads the same env var.
  - Skills are **vendored** in `skills/` (copied to `~/.agents/skills` at build time): `grill-with-docs`, `to-questionnaire`, `writing-for-agents`, `grilling`, `domain-modeling` (mattpocock/skills), `unslop`, `technical-writing` (cursor/plugins pstack), and local `meeting-briefing`. Each vendored skill has an `ORIGIN` file pinning its source repo, commit, and in-repo path. Refresh by re-copying from upstream and updating `ORIGIN`. Larger opinionated packs (addyosmani/agent-skills, pbakaus/impeccable) belong at **project level** via `.agents/skills` in the project repo.
  - **codex-cli** reads `$HOME/.agents/skills` directly (verified in `codex-rs/core-skills/src/loader.rs` — the "user-installed skills" root, present since v0.146.0).
  - **omp/pi** reads the same dir via its `agents` provider (`~/.agent/skills` + `~/.agents/skills`, user scope, priority 70).
- `config/helix/config.toml` uses `ayu_dark`, relative line numbers, mouse off, and remaps `w`/`b`/`e` to subword motions.
- `config/fish/config.fish` defines abbreviations agents may see in shell sessions: `oc` (opencode), `hx` (helix), `lg` (lazygit), `dc` (docker compose), etc.

## Editing this repo

- Test config syntax before committing (e.g. `fish -n config.fish`, `hx --health` in a running container).
- There are no tests, lint scripts, or CI workflows. Verify by building the image locally.
