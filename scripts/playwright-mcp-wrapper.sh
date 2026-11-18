#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# modular-egm — Headless Playwright MCP Launcher
# ==============================================================================
# Stores all screenshots, DOM snapshots, console traces, and network logs
# inside modular-egm/.workspace/playwright/ so the host repo remains untouched.
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EGM_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUT_DIR="${EGM_PLAYWRIGHT_DIR:-$EGM_ROOT/.workspace/playwright}"

mkdir -p "$OUTPUT_DIR"

if command -v egm-playwright-mcp >/dev/null 2>&1; then
	export EGM_PLAYWRIGHT_DIR="$OUTPUT_DIR"
	exec egm-playwright-mcp "$@"
fi

export PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS="true"
exec npx --yes @playwright/mcp@latest \
	--headless \
	--output-dir "$OUTPUT_DIR" \
	"$@"
