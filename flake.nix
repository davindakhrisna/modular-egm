{
  description = "modular-egm: Drop-in Elephant-Goldfish Model (EGM) AI workflow harness with Playwright MCP and surgical AST tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {nixpkgs, ...}: let
    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
  in {
    devShells = forAllSystems (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };

        egmPlaywrightMcp = pkgs.writeShellScriptBin "egm-playwright-mcp" ''
          set -euo pipefail
          WORKSPACE_DIR="''${EGM_PLAYWRIGHT_DIR:-$PWD/modular-egm/.workspace/playwright}"
          mkdir -p "$WORKSPACE_DIR"
          export PLAYWRIGHT_BROWSERS_PATH="${pkgs.playwright-driver.browsers}"
          export PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS="true"
          exec ${pkgs.nodejs_22}/bin/npx --yes @playwright/mcp@latest \
            --headless \
            --output-dir "$WORKSPACE_DIR" \
            "$@"
        '';
      in {
        default = pkgs.mkShell {
          name = "modular-egm-ai-shell";

          packages = with pkgs; [
            # Browser Automation & Playwright MCP Runtime
            playwright-driver.browsers
            playwright-test
            nodejs_22
            egmPlaywrightMcp

            # Surgical AST & Fast Lexical Search ("AI USE" Essentials)
            ripgrep
            fd
            ast-grep
            universal-ctags

            # Data Query, VCS & Shell Utilities
            jq
            yq-go
            gh
            git
            curl
          ];

          shellHook = ''
            export EGM_NIX_ACTIVE="1"
            export PLAYWRIGHT_BROWSERS_PATH="${pkgs.playwright-driver.browsers}"
            export PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS="true"
          '';
        };
      }
    );
  };
}
