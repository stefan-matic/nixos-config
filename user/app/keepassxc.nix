{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    keepassxc
    keepmenu
  ];

  # Enable KeePassXC Secret Service integration for non-KDE apps (browsers, etc.)
  # KDE apps like Dolphin use KWallet directly (auto-unlocked via PAM).
  xdg.configFile."keepassxc/keepassxc.ini" = {
    text = ''
      [General]
      ConfigVersion=2

      [FdoSecrets]
      Enabled=true
      ShowNotification=false
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

  # Enable KWallet for KDE apps (Dolphin SMB, etc.) that use the KWallet API directly.
  # KeePassXC handles non-KDE apps via freedesktop Secret Service (org.freedesktop.secrets).
  # KWallet is auto-unlocked at login via PAM, so no extra password prompts.
  xdg.configFile."kwalletrc".text = ''
    [Wallet]
    Enabled=true
    First Use=false
    Default Wallet=kdewallet
  '';
}
