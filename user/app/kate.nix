{ pkgs, ... }:

{
  # Set Kate as the default editor for development files
  # Prevents LibreOffice from opening code/config files

  xdg.mimeApps.defaultApplications = {
    # Code/Markup Languages
    "application/json" = "org.kde.kate.desktop";
    "application/x-yaml" = "org.kde.kate.desktop";
    "text/x-yaml" = "org.kde.kate.desktop";
    "application/yaml" = "org.kde.kate.desktop";
    "application/xml" = "org.kde.kate.desktop";
    "text/xml" = "org.kde.kate.desktop";
    "application/toml" = "org.kde.kate.desktop";
    "text/x-toml" = "org.kde.kate.desktop";

    # Programming Languages
    "text/x-python" = "org.kde.kate.desktop";
    "text/x-script.python" = "org.kde.kate.desktop";
    "application/x-python" = "org.kde.kate.desktop";
    "text/x-java" = "org.kde.kate.desktop";
    "text/x-c" = "org.kde.kate.desktop";
    "text/x-c++" = "org.kde.kate.desktop";
    "text/x-c++src" = "org.kde.kate.desktop";
    "text/x-csrc" = "org.kde.kate.desktop";
    "text/x-chdr" = "org.kde.kate.desktop";
    "text/x-rust" = "org.kde.kate.desktop";
    "text/x-go" = "org.kde.kate.desktop";
    "application/javascript" = "org.kde.kate.desktop";
    "text/javascript" = "org.kde.kate.desktop";
    "application/x-javascript" = "org.kde.kate.desktop";
    "text/x-typescript" = "org.kde.kate.desktop";
    "application/typescript" = "org.kde.kate.desktop";

    # Shell Scripts
    "application/x-shellscript" = "org.kde.kate.desktop";
    "text/x-shellscript" = "org.kde.kate.desktop";
    "application/x-sh" = "org.kde.kate.desktop";
    "text/x-sh" = "org.kde.kate.desktop";

    # Configuration Files
    "application/x-desktop" = "org.kde.kate.desktop";
    "text/x-ini" = "org.kde.kate.desktop";
    "application/x-wine-extension-ini" = "org.kde.kate.desktop";
    "text/x-makefile" = "org.kde.kate.desktop";
    "text/x-cmake" = "org.kde.kate.desktop";
    "application/x-cmake" = "org.kde.kate.desktop";

    # Nix Files
    "text/x-nix" = "org.kde.kate.desktop";
    "application/x-nix" = "org.kde.kate.desktop";

    # Docker/Container Files
    "text/x-dockerfile" = "org.kde.kate.desktop";
    "application/x-dockerfile" = "org.kde.kate.desktop";

    # Web Development
    # Note: text/html is handled by select-browser.nix for browser opening
    "application/xhtml+xml" = "org.kde.kate.desktop";
    "text/css" = "org.kde.kate.desktop";
    "text/x-scss" = "org.kde.kate.desktop";
    "text/x-sass" = "org.kde.kate.desktop";

    # Markdown & Documentation
    "text/markdown" = "org.kde.kate.desktop";
    "text/x-markdown" = "org.kde.kate.desktop";
    "application/x-markdowntext/x-rst" = "org.kde.kate.desktop";

    # Plain Text & Logs
    "text/plain" = "org.kde.kate.desktop";
    "text/x-log" = "org.kde.kate.desktop";
    "application/x-log" = "org.kde.kate.desktop";

    # SQL
    "application/sql" = "org.kde.kate.desktop";
    "text/x-sql" = "org.kde.kate.desktop";

    # Git Files
    "text/x-patch" = "org.kde.kate.desktop";
    "application/x-patch" = "org.kde.kate.desktop";
    "text/x-diff" = "org.kde.kate.desktop";
  };

  # Set Kate as the default text editor
  home.sessionVariables = {
    EDITOR = "kate";
    VISUAL = "kate";
  };
}
