{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bun
    nodejs
  ];

  # Redirect `npm install -g` into the user's home (the default global prefix
  # lives inside the read-only Nix store and can't be written to).
  home.sessionVariables.NPM_CONFIG_PREFIX = "$HOME/.npm-global";
  home.sessionPath = [ "$HOME/.npm-global/bin" ];
}
