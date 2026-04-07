{ pkgs, ... }:

{
  home.file.".config/espanso/config/default.yml".text = ''
    backend: Clipboard
  '';

  home.file.".config/espanso/match/base.yml".text = ''
    matches:
      - trigger: ":shrug"
        replace: "¯\\_(ツ)_/¯"
  '';

  systemd.user.services.espanso = {
    Unit = {
      Description = "Espanso text expander";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "/run/wrappers/bin/espanso worker";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
