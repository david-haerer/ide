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

- `config/*` is copied to `/home/dev/.config/*` at **build time**. Runtime changes inside the container are not persisted.
- `config/opencode/opencode.json` pins model to `openrouter/moonshotai/kimi-k2.6`, disables autoupdate/sharing, and registers the `chrome-devtools` MCP server via `bunx`.
- `config/helix/config.toml` uses `ayu_dark`, relative line numbers, mouse off, and remaps `w`/`b`/`e` to subword motions.
- `config/fish/config.fish` defines abbreviations agents may see in shell sessions: `oc` (opencode), `hx` (helix), `lg` (lazygit), `dc` (docker compose), etc.

## Editing this repo

- Test config syntax before committing (e.g. `fish -n config.fish`, `hx --health` in a running container).
- There are no tests, lint scripts, or CI workflows. Verify by building the image locally.
