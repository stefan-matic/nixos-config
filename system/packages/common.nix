{ pkgs, ... }:

{
  # Common system packages for all hosts
  # Essential tools needed for system operation and administration

  environment.systemPackages = with pkgs; [
    # Essential System Tools
    git # Version control (needed by system)
    vim # Emergency editor
    wget
    dig
    openssl
    inetutils

    # Basic Utilities
    which
    tree

    # Archives (system-level for all users)
    zip
    unzip
    xz
    p7zip

    # Python for system scripts and /bin/python3 symlink
    python3
  ];
}
