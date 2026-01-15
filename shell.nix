# Development shell for NixOS dotfiles
# Usage: nix-shell
# Or with direnv: echo "use nix" > .envrc && direnv allow

{
  pkgs ? import <nixpkgs> { },
}:

pkgs.mkShell {
  name = "nixos-dotfiles-dev";

  buildInputs = with pkgs; [
    # Nix formatters and linters
    nixfmt-rfc-style # RFC style formatter
    statix # Nix linter
    deadnix # Dead code detector

    # Multi-language formatter
    treefmt

    # Additional formatters for other file types
    nodePackages.prettier # Markdown, YAML, JSON

    # Nix language server (for editor integration)
    nil

    # Git tools
    git
    gh # GitHub CLI

    # Optional: pre-commit hooks
    pre-commit
  ];

  shellHook = ''
    echo "NixOS Dotfiles Development Environment"
    echo ""
    echo "Available tools:"
    echo "  nixfmt        - Format Nix files (RFC style)"
    echo "  treefmt       - Format all files"
    echo "  statix        - Lint Nix files"
    echo "  deadnix       - Find dead Nix code"
    echo "  nil           - Nix language server"
    echo ""
    echo "Quick commands:"
    echo "  treefmt                    # Format all files"
    echo "  nixfmt --check .           # Check Nix formatting"
    echo "  ./scripts/validate-config.sh  # Run all checks"
    echo ""
  '';
}
