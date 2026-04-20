{ pkgs, ... }:

{
  # Development tools and environments
  # IDEs, DevOps tools, cloud CLIs, language tooling

  home.packages = with pkgs; [
    # IDEs & Code Editors
    fast-track.code-cursor
    dbeaver-bin

    # Development Environments
    devbox
    fast-track.direnv
    nix-direnv

    # Version Control
    fast-track.gh
    fast-track.glab
    pre-commit
    bitbucket-cli

    # Programming Languages
    python3
    python3.pkgs.pip
    pipx
    uv # Python package manager

    # Kubernetes & Container Tools
    fast-track.kubectl
    fast-track.kubectx
    fast-track.kubernetes-helm
    fast-track.k9s
    kubelogin
    fast-track.eksctl
    fast-track.lens # Kubernetes IDE
    fast-track.argocd
    k3d
    fast-track.kustomize

    # Cloud Providers
    fast-track.awscli2
    # azure-cli from stable channel - broken on unstable (missing azure.mgmt.web module)
    stable.azure-cli
    stable.azure-cli-extensions.bastion
    stable.azure-cli-extensions.azure-firewall
    stable.azure-cli-extensions.log-analytics
    stable.azure-cli-extensions.log-analytics-solution
    stable.azure-cli-extensions.monitor-control-service
    stable.azure-cli-extensions.resource-graph
    stable.azure-cli-extensions.scheduled-query
    stable.azure-cli-extensions.application-insights
    fast-track.google-cloud-sdk

    # Infrastructure as Code
    fast-track.ansible
    ansible-lint
    fast-track.terraform
    fast-track.terragrunt
    fast-track.opentofu
    atlantis

    # AI Development Tools
    fast-track.claude-code
    fast-track.claude-monitor
    claude-desktop
    fast-track.amazon-q-cli
    fast-track.opencode
    ollama # CLI client (service runs on ZVIJER with CUDA)

    # Build Tools
    unstable.gnumake

    # Virtualization (user-level)
    quickemu

    # Random
    terminal-typeracer
    unstable.voxtype

    # winboat 0.9.0 fails to build on stable & unstable: node-abi in nixpkgs
    # doesn't recognise Electron 41 yet. Re-enable once upstream bumps node-abi.
    # stable.winboat

    mkcert

    kdePackages.qtwebsockets

    rar

    postgresql # I just need psql and pg_dump|restore
    mysql84

    drawio

    just
  ];
}
