{
  pkgs,
  lib,
  ...
}:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in
{
  programs.neovim = {
    enable = true;

    viAlias = true;
    vimAlias = true;
    defaultEditor = false;

    withPython3 = false;
    withRuby = false;

    # LSP servers, formatters & tools (installed via Nix, not Mason)
    extraPackages =
      with pkgs;
      [
        # LSP servers
        nil # Nix
        lua-language-server
        pyright
        gopls
        typescript-language-server
        bash-language-server
        yaml-language-server
        vscode-langservers-extracted # JSON, HTML, CSS
        terraform-ls

        # Formatters
        nixfmt
        stylua
        black
        prettierd
        shfmt

        # Tools needed by Telescope / LazyVim
        ripgrep
        fd
      ]
      ++ lib.optionals (!isDarwin) [
        # Treesitter grammar compilation on NixOS
        gcc
      ]
      ++ lib.optionals isDarwin [
        # Treesitter grammar compilation on darwin - clang, not gcc
        clang
      ];
  };

  # LazyVim config files — recursive so lazy.nvim can write lazy-lock.json
  xdg.configFile."nvim" = {
    source = ./nvim;
    recursive = true;
  };
}
