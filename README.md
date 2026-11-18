# modular-egm

Drop-in Elephant-Goldfish Model (EGM) workflow harness paired with a Nix devShell providing headless Playwright MCP and surgical AST/search tools (`ast-grep`, `ripgrep`, `fd`, `universal-ctags`, `jq`, `yq`, `gh`).

## Usage

Clone inside any host repository and run the launcher from the host project root:

```bash
git clone <repo-url> modular-egm
./modular-egm/start.sh
```

Options:
- `./modular-egm/start.sh --agent <1|2|3|codex|claude|agy>`
- `./modular-egm/start.sh --skip-nix`

## How It Works

1. Enters `nix develop ./modular-egm` while keeping `$PWD` at the host repository root.
2. Excludes `modular-egm/` via `.git/info/exclude`.
3. Appends a delimited EGM rule block to `AGENTS.md` / `CLAUDE.md` and strips it automatically on shell exit (`EXIT` / `INT` / `TERM`).
4. Writes all specs, review reports, and Playwright artifacts inside `modular-egm/.workspace/` (`designs/`, `playwright/`, `scratch/`).

## Model Tiers

Configured in `egm.toml`:

| Harness | Orchestrator & Heavy Critique | Light Recon & Comprehension |
| :--- | :--- | :--- |
| 1. Codex (`codex`) | `astra` | `terra` |
| 2. Claude Code (`claude`) | `fable` | `sonnet` |
| 3. Antigravity (`agy`) | `argon` | `hydrogen` |

- **Heavy Critique**: Root Elephant (`egm-brainstorm`, `egm-draft`, `egm-resolve`), `egm-design`, `egm-implementation-readiness`, `egm-inventive-catalyst`, `egm-zoom-out`.
- **Light Recon**: `egm-comprehension`, `egm-codebase-details`, `egm-structural`, `egm-style`, `egm-synthesizer`, `egm-bootstrap-orchestrator`.

## Upstream Sync

```bash
./modular-egm/scripts/sync-upstream.sh
```
