{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.docker.storageDriver = lib.mkOption {
    type = lib.types.nullOr (
      lib.types.enum [
        "aufs"
        "btrfs"
        "devicemapper"
        "overlay"
        "overlay2"
        "zfs"
      ]
    );
    default = null;
    description = "Docker storage driver to use";
  };

  config = lib.mkIf (config.docker.storageDriver != null) {
    assertions = [
      {
        assertion = lib.elem config.docker.storageDriver [
          "aufs"
          "btrfs"
          "devicemapper"
          "overlay"
          "overlay2"
          "zfs"
        ];
        message = "Invalid docker storage driver selected";
      }
    ];

    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
      storageDriver = config.docker.storageDriver;
      autoPrune.enable = true;
    };

    users.users.${config.userSettings.username}.extraGroups = [ "docker" ];

    environment.systemPackages = with pkgs; [
      docker
      docker-compose
      #lazydocker
    ];
  };
}
