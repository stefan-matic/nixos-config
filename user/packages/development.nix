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
    pre-commit

    # Programming Languages
    nodejs
    python3
    python3.pkgs.pip
    uv # Python package manager

    # Kubernetes & Container Tools
    kubectl
    kubectx
    kubernetes-helm
    k9s
    kubelogin
    eksctl
    lens # Kubernetes IDE

    # Cloud Providers
    awscli2
    azure-cli
    azure-cli-extensions.bastion
    azure-cli-extensions.azure-firewall
    azure-cli-extensions.log-analytics
    azure-cli-extensions.log-analytics-solution
    azure-cli-extensions.monitor-control-service
    azure-cli-extensions.resource-graph
    azure-cli-extensions.scheduled-query
    azure-cli-extensions.application-insights
    google-cloud-sdk

    # Infrastructure as Code
    ansible
    terraform
    terragrunt
    opentofu

    # AI Development Tools
    unstable.claude-code
    unstable.claude-monitor
    unstable.amazon-q-cli

    # Build Tools
    unstable.gnumake

    # Virtualization (user-level)
    quickemu

    terminal-typeracer

    winboat
  ];
}
