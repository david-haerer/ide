#!/usr/bin/env bash
# setup-skills.sh — install community skills from their source repos.
#
# Canonical store: ~/.agents/skills/<name>/SKILL.md (Agent Skills spec layout).
# Read natively by:
#   - codex-cli >= 0.146: $HOME/.agents/skills (source: codex-rs/core-skills/src/loader.rs
#     "// `$HOME/.agents/skills` (user-installed skills)")
#   - omp/pi: agents provider scans ~/.agent/skills + ~/.agents/skills at user
#     scope (priority 70). Also read via repo-local .agents/skills if checked in.
# No symlinks needed — every consumer reads this one directory.
#
# Sources: mattpocock/skills (all non-deprecated categories) and
# cursor/plugins pstack/skills. Name collisions (tdd, teach): mattpocock keeps
# the canonical name, pstack is prefixed pstack-<name>.
#
# Updates: rebuild the image — this script clones fresh `main` each build.
# Override repos/refs via MATT_POCOCK_REPO/REF, PSTACK_REPO/REF build-args.

set -euo pipefail

MATT_POCOCK_REPO="${MATT_POCOCK_REPO:-https://github.com/mattpocock/skills.git}"
MATT_POCOCK_REF="${MATT_POCOCK_REF:-main}"
PSTACK_REPO="${PSTACK_REPO:-https://github.com/cursor/plugins.git}"
PSTACK_REF="${PSTACK_REF:-main}"

SKILLS_ROOT="${HOME}/.agents/skills"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

rm -rf "$SKILLS_ROOT"
mkdir -p "$SKILLS_ROOT"

install_skill() {
	local src="$1" name="$2"
	cp -a "$src" "${SKILLS_ROOT}/${name}"
}

echo "==> cloning mattpocock/skills (${MATT_POCOCK_REF})"
git clone --depth 1 --branch "$MATT_POCOCK_REF" "$MATT_POCOCK_REPO" "$work/mattpocock"
# mattpocock nests skills under category dirs: skills/<category>/<name>/SKILL.md.
for skill in "$work"/mattpocock/skills/*/*/; do
	[[ -f "$skill/SKILL.md" ]] || continue
	install_skill "$skill" "$(basename "$skill")"
done

echo "==> cloning cursor/plugins (${PSTACK_REF})"
git clone --depth 1 --branch "$PSTACK_REF" "$PSTACK_REPO" "$work/pstack"
# pstack skills are flat: pstack/skills/<name>/SKILL.md
for skill in "$work"/pstack/pstack/skills/*/; do
	[[ -f "$skill/SKILL.md" ]] || continue
	name="$(basename "$skill")"
	if [[ -e "${SKILLS_ROOT}/${name}" ]]; then
		echo "    name collision -> pstack-${name}"
		name="pstack-${name}"
	fi
	install_skill "$skill" "$name"
done

count="$(find "$SKILLS_ROOT" -maxdepth 1 -mindepth 1 -type d | wc -l)"
echo "==> installed ${count} skills in ${SKILLS_ROOT}"