{ pkgs, lib, ... }:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in
{
  # Development tools and environments
  # IDEs, DevOps tools, cloud CLIs, language tooling
  #
  # Shared by NixOS and darwin hosts. Anything that nixpkgs only builds for
  # linux, or that ships as a macOS .app bundle Launch Services needs to know
  # about, is split out below -- on darwin those come from
  # hosts/macbook/homebrew.nix as casks instead.

  home.packages =
    with pkgs;
    [
      # Development Environments
      devbox

      # Version Control
      fast-track.gh
      fast-track.glab
      pre-commit
      bitbucket-cli

      # Programming Languages (Python lives in user/lang/python/python.nix)
      nixd # Nix language server

      # Kubernetes & Container Tools
      fast-track.kubectl
      fast-track.kubectx
      fast-track.kubernetes-helm
      fast-track.k9s
      kubelogin
      fast-track.eksctl
      fast-track.argocd
      k3d
      fast-track.kustomize

      # Cloud Providers
      fast-track.awscli2
      # azure-cli from stable channel - broken on unstable (missing azure.mgmt.web module)
      stable.azure-cli
      stable.doctl
      stable.azure-cli-extensions.bastion
      stable.azure-cli-extensions.azure-firewall
      stable.azure-cli-extensions.log-analytics
      stable.azure-cli-extensions.log-analytics-solution
      stable.azure-cli-extensions.monitor-control-service
      stable.azure-cli-extensions.resource-graph
      stable.azure-cli-extensions.scheduled-query
      stable.azure-cli-extensions.application-insights
      fast-track.google-cloud-sdk
      wrangler # Cloudflare workers

      # Infrastructure as Code
      fast-track.ansible
      ansible-lint
      fast-track.terraform
      fast-track.terragrunt
      fast-track.opentofu
      atlantis

      # AI Development Tools
      bleeding-edge.claude-code
      fast-track.claude-monitor
      fast-track.opencode
      bleeding-edge.codex
      ollama # CLI client (service runs on ZVIJER with CUDA)
      sox # Audio recording for Claude Code /voice

      # Build Tools
      unstable.gnumake

      # Random
      terminal-typeracer

      mkcert

      rar

      postgresql # I just need psql and pg_dump|restore
      mysql84

      just

      vault
      infisical

      # API test
      bruno-cli

      gitleaks
    ]
    ++ lib.optionals (!isDarwin) [
      # IDEs & Code Editors -- all three are linux builds in nixpkgs; on
      # darwin they come from the cursor / dbeaver-community / zed casks.
      fast-track.code-cursor
      dbeaver-bin
      unstable.zed-editor

      # Kubernetes IDE - electron, linux-only in nixpkgs (cask: lens)
      fast-track.lens

      # Temp disabled 2026-06-03: aaddrick patcher fails on Claude Desktop
      # 1.10628.0 (addTrustedFolder anchor not found). Re-enable when upstream fixes.
      # claude-desktop
      fast-track.amazon-q-cli

      # Speech-to-text, wayland-bound
      unstable.voxtype

      # Virtualization (user-level) - KVM/QEMU wrapper
      quickemu

      # winboat 0.9.0 fails to build on stable & unstable: node-abi in nixpkgs
      # doesn't recognise Electron 41 yet. Re-enable once upstream bumps node-abi.
      # stable.winboat

      kdePackages.qtwebsockets

      # electron apps (casks: drawio, bruno)
      drawio
      bruno
    ];
}
