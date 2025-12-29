{ config, lib, pkgs, inputs, ... }:

# DankSearch (dsearch) Configuration
# Fast file indexing and search service for DMS integration
#
# Usage:
#   Import this module in your home-manager configuration
#   The service will auto-start and maintain an index of your files

{
  # Import the dsearch home-manager module from danksearch flake
  imports = [ inputs.danksearch.homeModules.dsearch ];

  # Enable dsearch service
  programs.dsearch = {
    enable = true;
  };

  # Configuration file for dsearch
  # The module looks for config at ~/.config/dsearch/config.toml
  home.file.".config/dsearch/config.toml".text = ''
    [server]
    listen = "127.0.0.1:43654"

    [index]
    path = "${config.home.homeDirectory}/.local/share/dsearch/index.db"
    max_file_size = 10485760  # 10MB in bytes
    workers = 4
    auto_reindex = true

    [[paths]]
    path = "${config.home.homeDirectory}"
    depth = 10
    exclude_hidden = true
    blacklist = [
      ".cache",
      ".git",
      "node_modules",
      ".npm",
      ".cargo",
      ".rustup",
      ".local/share/Steam",
      ".local/share/Trash",
      "Downloads",
      ".mozilla",
      ".config/google-chrome",
      ".config/Code",
      ".config/Slack"
    ]

    [[paths]]
    path = "/etc/nixos"
    depth = 5
    exclude_hidden = false
    blacklist = []

    [[paths]]
    path = "${config.home.homeDirectory}/.dotfiles"
    depth = 10
    exclude_hidden = false
    blacklist = [".git"]

    [text_extensions]
    extensions = [
      "txt", "md", "nix", "conf", "toml", "yaml", "yml",
      "json", "xml", "html", "css", "js", "ts", "tsx", "jsx",
      "py", "rs", "go", "c", "cpp", "h", "hpp",
      "sh", "bash", "zsh", "fish",
      "kdl", "desktop", "service"
    ]
  '';

  # Note: The module automatically creates a systemd user service that:
  # - Runs 'dsearch serve' to start the API server
  # - Auto-starts on login
  # - Restarts on failure
  # - Logs to systemd journal
  #
  # View logs with: journalctl --user -u dsearch
  # Check status with: systemctl --user status dsearch
  # Manually reindex: dsearch index --force
}
