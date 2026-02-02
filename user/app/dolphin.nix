{ ... }:

{
  # Set Dolphin as the default file manager

  xdg.mimeApps.defaultApplications = {
    # Directory/folder handling
    "inode/directory" = "org.kde.dolphin.desktop";

    # File manager protocol handlers
    "x-scheme-handler/file" = "org.kde.dolphin.desktop";
  };

  # Environment variable to tell apps to use Dolphin
  home.sessionVariables = {
    # Some apps check this for file manager
    FILE_MANAGER = "dolphin";
  };
}
