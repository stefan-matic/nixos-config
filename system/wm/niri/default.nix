{ config, lib, pkgs, systemSettings, ... }:

{
  options.programs.niri.config = lib.mkOption {
    type = lib.types.lines;
    default = "";
    description = "Niri configuration content (config.kdl)";
  };

  config = lib.mkIf (config.programs.niri.enable && config.programs.niri.config != "") {
    # Write Niri config to /etc/xdg/niri/config.kdl (system-wide default)
    environment.etc."xdg/niri/config.kdl".text = config.programs.niri.config;
  };
}
