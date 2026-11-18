#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# modular-egm — Dual-Mode Nix + Elephant-Goldfish Model (EGM) Launcher
# ==============================================================================
# Usage (from host project root):
#   ./modular-egm/start.sh [--agent codex|claude|agy] [--skip-nix]
# ==============================================================================

EGM_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Determine host project root: if modular-egm is cloned inside a host repo,
# use the current working directory (or parent of EGM_ROOT if invoked from inside EGM_ROOT).
if [[ "$PWD" == "$EGM_ROOT" ]]; then
	HOST_ROOT="$(cd "$EGM_ROOT/.." && pwd)"
else
	HOST_ROOT="$PWD"
fi

SELECTED_AGENT=""
SKIP_NIX=0

while [[ $# -gt 0 ]]; do
	case "$1" in
	--agent | -a)
		SELECTED_AGENT="${2:-}"
		shift 2
		;;
	--skip-nix)
		SKIP_NIX=1
		shift
		;;
	--help | -h)
		cat <<EOF
Usage: ./modular-egm/start.sh [OPTIONS]

Options:
  -a, --agent <1|2|3|codex|claude|agy>   Pre-select AI agent harness
      --skip-nix                         Skip re-entering nix develop shell
  -h, --help                             Show this help message
EOF
		exit 0
		;;
	*)
		shift
		;;
	esac
done

# 1. Dual-Mode Nix Entry: automatically enter `nix develop` if not already active
if [[ "${EGM_NIX_ACTIVE:-0}" != "1" && "$SKIP_NIX" -eq 0 ]]; then
	if command -v nix >/dev/null 2>&1; then
		printf '\033[1;34m[modular-egm]\033[0m Entering Nix AI USE devShell (Playwright + Surgical AST tools)...\n'
		FORWARD_ARGS=("--skip-nix")
		if [[ -n "$SELECTED_AGENT" ]]; then
			FORWARD_ARGS+=("--agent" "$SELECTED_AGENT")
		fi
		exec nix --extra-experimental-features "nix-command flakes" develop "$EGM_ROOT" \
			--command "$EGM_ROOT/start.sh" "${FORWARD_ARGS[@]}"
	else
		printf '\033[1;33m[modular-egm] Warning:\033[0m `nix` not found in PATH; continuing with host environment.\n'
	fi
fi

# shellcheck source=scripts/lib-inject.sh
source "$EGM_ROOT/scripts/lib-inject.sh"

# 2. Interactive Agent Selection Prompt
if [[ -z "$SELECTED_AGENT" ]]; then
	printf '\n'
	printf '\033[1;36m======================================================================\033[0m\n'
	printf '\033[1;36m  Elephant-Goldfish Model (EGM) — Modular AI Workflow Harness\033[0m\n'
	printf '\033[1;36m======================================================================\033[0m\n'
	printf '  Host Project : %s\n' "$HOST_ROOT"
	printf '  EGM Artifacts: %s/.workspace/designs/\n' "$EGM_ROOT"
	printf '  Playwright   : %s/.workspace/playwright/ (Headless MCP)\n' "$EGM_ROOT"
	printf '\033[1;36m----------------------------------------------------------------------\033[0m\n'
	printf '  Select AI Agent Harness (Two-Tier Heavy Critique / Light Recon):\n\n'
	printf '    \033[1;32m1)\033[0m Codex        \033[0;90m[Orchestrator: \033[1;37mastra\033[0;90m  | Light Goldfish: \033[1;37mterra\033[0;90m]\033[0m\n'
	printf '    \033[1;32m2)\033[0m Claude Code  \033[0;90m[Orchestrator: \033[1;37mfable\033[0;90m  | Light Goldfish: \033[1;37msonnet\033[0;90m]\033[0m\n'
	printf '    \033[1;32m3)\033[0m Antigravity  \033[0;90m[Orchestrator: \033[1;37margon\033[0;90m  | Light Goldfish: \033[1;37mhydrogen\033[0;90m]\033[0m\n\n'
	read -r -p "  Enter choice [1-3]: " SELECTED_AGENT
fi

case "$SELECTED_AGENT" in
1 | codex | Codex)
	HARNESS_KEY="codex"
	HARNESS_NAME="Codex"
	CLI_BIN="codex"
	ORCHESTRATOR_MODEL="${EGM_CODEX_ORCHESTRATOR:-astra}"
	WORKER_MODEL="${EGM_CODEX_WORKER:-terra}"
	;;
2 | claude | "claude-code")
	HARNESS_KEY="claude"
	HARNESS_NAME="Claude Code"
	CLI_BIN="claude"
	ORCHESTRATOR_MODEL="${EGM_CLAUDE_ORCHESTRATOR:-fable}"
	WORKER_MODEL="${EGM_CLAUDE_WORKER:-sonnet}"
	;;
3 | agy | antigravity)
	HARNESS_KEY="antigravity"
	HARNESS_NAME="Antigravity"
	CLI_BIN="agy"
	ORCHESTRATOR_MODEL="${EGM_AGY_ORCHESTRATOR:-argon}"
	WORKER_MODEL="${EGM_AGY_WORKER:-hydrogen}"
	;;
*)
	printf '\033[1;31m[modular-egm] Error:\033[0m Invalid selection "%s". Choose 1 (codex), 2 (claude), or 3 (antigravity).\n' "$SELECTED_AGENT" >&2
	exit 1
	;;
esac

# 3. Register Atomic Cleanup Trap (restores host AGENTS.md / CLAUDE.md on exit)
on_exit() {
	printf '\n\033[1;34m[modular-egm]\033[0m Cleaning up injected EGM blocks and restoring host workspace...\n'
	egm_cleanup_workspace "$HOST_ROOT"
	printf '\033[1;32m[modular-egm]\033[0m Host project clean. Design artifacts preserved in %s/.workspace/\n' "$EGM_ROOT"
}
trap on_exit EXIT INT TERM

# 4. Inject EGM Rulebook, Git Exclude & Playwright MCP Config
egm_prepare_workspace "$HOST_ROOT" "$EGM_ROOT" "$HARNESS_NAME" "$ORCHESTRATOR_MODEL" "$WORKER_MODEL"

export EGM_PLAYWRIGHT_DIR="$EGM_ROOT/.workspace/playwright"
export EGM_ARTIFACT_DIR="$EGM_ROOT/.workspace/designs"
export EGM_ORCHESTRATOR_MODEL="$ORCHESTRATOR_MODEL"
export EGM_WORKER_MODEL="$WORKER_MODEL"

cd "$HOST_ROOT"

printf '\n\033[1;32m[modular-egm]\033[0m Launching \033[1;37m%s\033[0m (Orchestrator: \033[1;36m%s\033[0m | Worker: \033[1;36m%s\033[0m)\n' \
	"$HARNESS_NAME" "$ORCHESTRATOR_MODEL" "$WORKER_MODEL"
printf '\033[0;90m  Skills ready: /egm-brainstorm, /egm-draft, /egm-review, /egm-resolve, /egm-bootstrap, /egm-lite\033[0m\n\n'

if ! command -v "$CLI_BIN" >/dev/null 2>&1; then
	printf '\033[1;31m[modular-egm] Error:\033[0m Host binary `%s` not found in PATH.\n' "$CLI_BIN" >&2
	exit 127
fi

# 5. Launch the Chosen Agent CLI
case "$HARNESS_KEY" in
codex)
	"$CLI_BIN" \
		--model "$ORCHESTRATOR_MODEL" \
		-c "mcp_servers.playwright.command=\"$EGM_ROOT/scripts/playwright-mcp-wrapper.sh\""
	;;
claude)
	"$CLI_BIN" \
		--model "$ORCHESTRATOR_MODEL" \
		--plugin-dir "$EGM_ROOT" \
		--mcp-config "$EGM_ROOT/.workspace/mcp.json"
	;;
antigravity)
	egm_install_agy_plugin "$EGM_ROOT"
	"$CLI_BIN" \
		--model "$ORCHESTRATOR_MODEL"
	;;
esac
