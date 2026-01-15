{
  config,
  pkgs,
  userSettings,
  ...
}:

{
  home.packages = [ pkgs.git ];
  programs.git.enable = true;
  programs.git.settings.user.name = userSettings.name;
  programs.git.settings.user.email = userSettings.email;
  programs.git.settings = {
    init.defaultBranch = "main";
  };
}
