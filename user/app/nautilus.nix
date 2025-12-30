{ config, pkgs, ... }:

{
  # Nautilus (GNOME Files) configuration
  # Enhanced with Dolphin-like features: free space, mounted drives, detailed columns

  dconf.settings = {
    # Nautilus preferences
    "org/gnome/nautilus/preferences" = {
      # Default view settings
      default-folder-viewer = "list-view";  # Use list view by default for more columns

      # Sidebar settings
      always-use-location-entry = false;

      # Show hidden files (optional, set to true if you want to see dotfiles)
      show-hidden-files = false;

      # Search settings
      recursive-search = "always";

      # Thumbnail settings
      show-image-thumbnails = "always";
    };

    # List view configuration - show more columns
    "org/gnome/nautilus/list-view" = {
      default-zoom-level = "standard";
      use-tree-view = false;

      # Enable all useful columns
      default-visible-columns = [
        "name"
        "size"
        "type"
        "owner"
        "group"
        "permissions"
        "date_modified"
        "date_accessed"
      ];

      # Column order
      default-column-order = [
        "name"
        "size"
        "type"
        "owner"
        "group"
        "permissions"
        "date_modified"
        "date_accessed"
        "date_created"
        "recency"
        "starred"
      ];
    };

    # Icon view configuration (for when you switch views)
    "org/gnome/nautilus/icon-view" = {
      default-zoom-level = "standard";
    };

    # Window state
    "org/gnome/nautilus/window-state" = {
      initial-size = "(1200, 800)";
      maximized = false;
      sidebar-width = 200;
    };

    # GTK file chooser - also affects file dialogs
    "org/gtk/settings/file-chooser" = {
      sort-directories-first = true;
      show-hidden = false;
      show-size-column = true;
      show-type-column = true;
      sidebar-width = 200;
      type-format = "category";
    };

    # Desktop icons (if you use GNOME desktop)
    "org/gnome/nautilus/desktop" = {
      home-icon-visible = true;
      trash-icon-visible = true;
      volumes-visible = true;  # Show mounted drives on desktop
    };
  };

  # Install additional Nautilus extensions for more functionality
  home.packages = with pkgs; [
    # Nautilus extensions
    sushi                    # Quick preview with spacebar (GNOME Sushi)
    nautilus-open-any-terminal  # Open terminal in current directory
  ];

  # Session variables for Nautilus
  home.sessionVariables = {
    # Use Ghostty as default terminal for nautilus-open-any-terminal
    NAUTILUS_TERMINAL = "ghostty";
  };
}
