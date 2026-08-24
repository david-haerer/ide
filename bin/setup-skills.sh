#!/usr/bin/env bash
# setup-skills.sh — install community skills from their source repos.
#
# Layout:
#   ~/.agents/skills/<name>/SKILL.md   canonical store (Agent Skills spec layout)
#   ~/.codex/skills/<name> -> symlink  legacy bridge: codex-cli < 0.147 reads
#                                     ~/.codex/skills ($CODEX_HOME/skills), not
#                                     ~/.agents/skills. omp's codex provider
#                                     reads ~/.codex/skills too.
#
# Consumers:
#   - omp/pi: agents provider scans ~/.agent/skills + ~/.agents/skills (pri 70);
#     codex provider scans ~/.codex/skills (pri 70). Both follow symlinks.
#   - codex-cli: ~/.codex/skills (symlinked dirs followed, documented).
#
# Updates: rebuild the image — this script clones fresh `main` each build.
# Override refs/repos via the MATT_POCOCK_*/PSTACK_* env vars (build-args).

set -euo pipefail

MATT_POCOCK_REPO="${MATT_POCOCK_REPO:-https://github.com/mattpocock/skills.git}"
MATT_POCOCK_REF="${MATT_POCOCK_REF:-main}"
PSTACK_REPO="${PSTACK_REPO:-https://github.com/cursor/plugins.git}"
PSTACK_REF="${PSTACK_REF:-main}"

SKILLS_ROOT="${HOME}/.agents/skills"
CODEX_ROOT="${HOME}/.codex/skills"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

# Both roots are owned by this script.
rm -rf "$SKILLS_ROOT" "$CODEX_ROOT"
mkdir -p "$SKILLS_ROOT" "$CODEX_ROOT"

install_skill() {
	local src="$1" name="$2"
	cp -a "$src" "${SKILLS_ROOT}/${name}"
	ln -s "${SKILLS_ROOT}/${name}" "${CODEX_ROOT}/${name}"
}

echo "==> cloning mattpocock/skills (${MATT_POCOCK_REF})"
git clone --depth 1 --branch "$MATT_POCOCK_REF" "$MATT_POCOCK_REPO" "$work/mattpocock"
# mattpocock nests skills under category dirs: skills/<category>/<name>/SKILL.md.
# Canonical names win; colliding pstack skills get prefixed below.
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
echo "==> installed ${count} skills in ${SKILLS_ROOT} (symlinked into ${CODEX_ROOT})"