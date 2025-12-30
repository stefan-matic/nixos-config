{ pkgs, ... }:

{
  # Set select-browser as the default browser
  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = {
    "text/html" = "select-browser.desktop";
    "x-scheme-handler/http" = "select-browser.desktop";
    "x-scheme-handler/https" = "select-browser.desktop";
    "x-scheme-handler/about" = "select-browser.desktop";
    "x-scheme-handler/unknown" = "select-browser.desktop";
  };

  home.sessionVariables = {
    BROWSER = "select-browser";
  };
}
