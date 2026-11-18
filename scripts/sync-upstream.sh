#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# modular-egm — Upstream EGM Synchronizer & Two-Tier Patcher
# ==============================================================================
# Fetches the latest google/elephant-goldfish-model skills, personas, and
# document standards, and re-applies modular-egm's two-tier model assignments.
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EGM_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
UPSTREAM_URL="https://github.com/google/elephant-goldfish-model.git"

TMP_DIR="$(mktemp -d)"
cleanup() {
	rm -rf "$TMP_DIR"
}
trap cleanup EXIT

printf '[modular-egm] Cloning latest %s...\n' "$UPSTREAM_URL"
git clone --depth 1 "$UPSTREAM_URL" "$TMP_DIR/upstream"

cp -R \
	"$TMP_DIR/upstream/plugin.json" \
	"$TMP_DIR/upstream/.claude-plugin" \
	"$TMP_DIR/upstream/.codex-plugin" \
	"$TMP_DIR/upstream/.agents" \
	"$TMP_DIR/upstream/agents" \
	"$TMP_DIR/upstream/resources" \
	"$TMP_DIR/upstream/skills" \
	"$TMP_DIR/upstream/assets" \
	"$EGM_ROOT/"

mkdir -p "$EGM_ROOT/docs"
cp -R \
	"$TMP_DIR/upstream/docs/claude.md" \
	"$TMP_DIR/upstream/docs/codex.md" \
	"$TMP_DIR/upstream/docs/harnesses.md" \
	"$TMP_DIR/upstream/docs/getting_started.md" \
	"$TMP_DIR/upstream/docs/faq.md" \
	"$EGM_ROOT/docs/"

# Re-apply Heavy Critique tier (fable) to Claude Code adapters
for heavy in design_critic implementation_readiness inventive_catalyst zoom_out; do
	sed -i 's/^model: inherit$/model: fable/' "$EGM_ROOT/.claude-plugin/agents/${heavy}.md"
done

# Re-apply Light Recon tier (sonnet) to Claude Code adapters
for light in comprehension codebase_details structural style synthesizer bootstrap_orchestrator; do
	sed -i 's/^model: inherit$/model: sonnet/' "$EGM_ROOT/.claude-plugin/agents/${light}.md"
done

printf '[modular-egm] Upstream EGM synced and two-tier model routing applied.\n'
