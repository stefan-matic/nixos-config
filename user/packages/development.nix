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
    terraform
    terragrunt
    opentofu
    atlantis

    # AI Development Tools
    unstable.claude-code
    unstable.claude-monitor
    unstable.amazon-q-cli
    unstable.opencode
    ollama # CLI client (service runs on ZVIJER with CUDA)

    # Build Tools
    unstable.gnumake

    # Virtualization (user-level)
    quickemu

    # Random
    terminal-typeracer
    unstable.voxtype

    stable.winboat

    mkcert

    kdePackages.qtwebsockets

    rar

    postgresql # I just need psql and pg_dump|restore

    drawio

    just
  ];
}
