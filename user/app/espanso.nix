{ ... }:

{
  home.file.".config/espanso/config/default.yml".text = ''
    backend: Clipboard
  '';

  home.file.".config/espanso/match/base.yml".text = ''
    matches:
      - trigger: ":shrug"
        replace: "¯\\_(ツ)_/¯"
  '';
}
