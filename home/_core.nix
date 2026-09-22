# Cross-platform home-manager base shared by NixOS and Darwin hosts.
# Only modules that evaluate on both linux and darwin belong here; anything
# needing systemd, wayland, xdg.mimeApps or KDE lives in _common.nix.
{ ... }:

{
  home.stateVersion = "24.11";

  # Add ~/Scripts and ~/.local/bin (uv, pipx, etc.) to PATH
  home.sessionPath = [
    "$HOME/Scripts"
    "$HOME/.local/bin"
  ];

  # Default terminal editor for CLI tools (git, etc.)
  home.sessionVariables = {
    EDITOR = "nano";
    VISUAL = "nano";
  };

  imports = [
    # Application configurations (dotfiles)
    ../user/app/git/git.nix
    ../user/app/terminal/kitty.nix
    ../user/app/terminal/ghostty.nix
    ../user/app/terminal/tmux.nix
    ../user/app/terminal/yazi.nix
    ../user/app/taskwarrior.nix
    ../user/app/neovim
    ../user/app/direnv/direnv.nix
    ../user/shells/sh.nix
    ../user/lang/python/python.nix
    ../user/lang/go/go.nix
    ../user/lang/nodejs/nodejs.nix
    ../user/lang/rust/rust.nix
  ];

  news.display = "silent";
}
