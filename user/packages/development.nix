{ pkgs, ... }:

{
  # Development tools and environments
  # IDEs, DevOps tools, cloud CLIs, language tooling

  home.packages = with pkgs; [
    # IDEs & Code Editors
    unstable.code-cursor
    dbeaver-bin

    # Development Environments
    devbox
    direnv
    nix-direnv

    # Version Control
    gh
    glab
    pre-commit
    bitbucket-cli

    # Programming Languages
    python3
    python3.pkgs.pip
    pipx
    uv # Python package manager

    # Kubernetes & Container Tools
    kubectl
    kubectx
    kubernetes-helm
    k9s
    kubelogin
    eksctl
    lens # Kubernetes IDE
    argocd
    k3d
    kustomize

    # Cloud Providers
    awscli2
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
    google-cloud-sdk

    # Infrastructure as Code
    ansible
    ansible-lint
    bleeding.terraform
    bleeding.terragrunt
    bleeding.opentofu
    atlantis

    # AI Development Tools
    bleeding.claude-code
    bleeding.claude-monitor
    bleeding.amazon-q-cli
    bleeding.opencode
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
