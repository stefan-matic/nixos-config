{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    keepassxc
    keepmenu
  ];

  # Enable KeePassXC Secret Service integration
  # This allows applications like Dolphin to use KeePassXC for password storage
  # instead of KWallet when connecting to SMB shares, etc.
  xdg.configFile."keepassxc/keepassxc.ini" = {
    text = ''
      [General]
      ConfigVersion=2

      [FdoSecrets]
      Enabled=true
      ShowNotification=true
      ConfirmAccessItem=false
      ConfirmDeleteItem=true

      [Browser]
      Enabled=true

      [SSHAgent]
      Enabled=true

      [Security]
      LockDatabaseIdle=false
      LockDatabaseScreenLock=true

      [GUI]
      ApplicationTheme=dark
      MinimizeOnClose=true
      ShowTrayIcon=true
      TrayIconAppearance=monochrome-light
    '';
    # Don't overwrite if user has customized settings
    force = false;
  };

  # Disable KWallet entirely so KDE apps (Dolphin) use freedesktop Secret Service (KeePassXC)
  xdg.configFile."kwalletrc".text = ''
    [Wallet]
    Enabled=false
    First Use=false
  '';

  # Mask kwalletd6 service to prevent it from starting
  systemd.user.services.kwalletd6 = {
    Unit = {
      Description = "KWallet daemon (masked - using KeePassXC instead)";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.coreutils}/bin/true";
    };
  };
}
