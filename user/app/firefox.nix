{ pkgs, lib, ... }:

let
  # Helper to build Firefox addons from AMO (addons.mozilla.org)
  buildFirefoxXpiAddon =
    {
      pname,
      version,
      addonId,
      url,
      sha256,
    }:
    pkgs.stdenv.mkDerivation {
      inherit pname version;
      src = pkgs.fetchurl { inherit url sha256; };
      preferLocalBuild = true;
      allowSubstitutes = true;
      buildCommand = ''
        dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
        mkdir -p "$dst"
        install -v -m644 "$src" "$dst/${addonId}.xpi"
      '';
    };

  # Extensions from NUR
  nurAddons = pkgs.nur.repos.rycee.firefox-addons;

  # Custom addons not in NUR
  customAddons = {
    aws-extend-switch-roles = buildFirefoxXpiAddon {
      pname = "aws-extend-switch-roles";
      version = "2.0.6";
      addonId = "aws-extend-switch-roles3@eiri.abe";
      url = "https://addons.mozilla.org/firefox/downloads/file/4221163/aws_extend_switch_roles3-2.0.6.xpi";
      sha256 = "sha256-FgRofXK1JqgJYnPWi81+9MwPm6834ruf6LgLo8HZ3H4=";
    };

    better-history = buildFirefoxXpiAddon {
      pname = "better-history-ng";
      version = "2.2.0";
      addonId = "{058af685-fc17-47a4-991a-bab91a89533d}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4391640/better_history_ng-2.2.0.xpi";
      sha256 = "sha256-k/pvDdJEUshy7lPdhvsni7NnQP7IUhv/mV6rqVTzuXQ=";
    };

    checker-plus-calendar = buildFirefoxXpiAddon {
      pname = "checker-plus-google-calendar";
      version = "31.0";
      addonId = "{92e6fe1c-f4a0-4764-a899-c5e5e819ef88}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4420193/AXooxdIHNMHB-31.0.xpi";
      sha256 = "sha256-3KrWgzXVcPx3X3iiYiHt3oxDk+aBx3q30+NvwpOrdzc=";
    };

    clear-cache = buildFirefoxXpiAddon {
      pname = "clearcache";
      version = "4.7";
      addonId = "clearcache@michel.de.almeida";
      url = "https://addons.mozilla.org/firefox/downloads/file/4675168/clearcache-4.7.xpi";
      sha256 = "sha256-Sji4Dg63wYUkh7RDi4n0HxTYTmI3qNRWPTsy62LxKWI=";
    };

    cookies-txt = buildFirefoxXpiAddon {
      pname = "cookies-txt";
      version = "0.7";
      addonId = "{12cf650b-1822-40aa-bff0-996df6948878}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4303773/cookies_txt-0.7.xpi";
      sha256 = "sha256-XtlumzQHbWc1+Icwy1xkVLgRv/ntwfbkOHT7nQYG/8Y=";
    };

    tab-retitle = buildFirefoxXpiAddon {
      pname = "tab-retitle";
      version = "1.5.2";
      addonId = "{c3414030-c135-490d-bdb8-4734cd05f7a5}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3468684/tab_retitle-1.5.2.xpi";
      sha256 = "sha256-P0Fx8ZvTe19hmPXbi+tJyixcXMQm+uVDXKBMNTP04io=";
    };

    keepassxc-browser = buildFirefoxXpiAddon {
      pname = "keepassxc-browser";
      version = "1.9.11";
      addonId = "keepassxc-browser@keepassxc.org";
      url = "https://addons.mozilla.org/firefox/downloads/file/4628286/keepassxc_browser-1.9.11.xpi";
      sha256 = "sha256-vuUjrI2WjTauOuMXsSsbK76F4sb1ud2w+4IsLZCvYTk=";
    };
  };

  # Common extensions for all profiles
  commonExtensions = [
    nurAddons.onepassword-password-manager
    nurAddons.ublock-origin
    nurAddons.multi-account-containers
    nurAddons.tree-style-tab
    nurAddons.cookie-quick-manager
    nurAddons.tab-session-manager
    nurAddons.translate-web-pages
    customAddons.better-history
    customAddons.clear-cache
    customAddons.cookies-txt
    customAddons.tab-retitle
    customAddons.keepassxc-browser
  ];

  # Work-related extensions
  workExtensions = [
    customAddons.aws-extend-switch-roles
    customAddons.checker-plus-calendar
  ];

  # Common Firefox settings
  commonSettings = {
    # Privacy settings
    "privacy.donottrackheader.enabled" = true;
    "privacy.trackingprotection.enabled" = true;
    "privacy.trackingprotection.socialtracking.enabled" = true;

    # Disable telemetry
    "toolkit.telemetry.enabled" = false;
    "toolkit.telemetry.unified" = false;
    "browser.ping-centre.telemetry" = false;

    # Enable userChrome customizations
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

    # Tree Style Tab: hide native tab bar (optional, uncomment if desired)
    # "browser.tabs.tabmanager.enabled" = false;

    # Multi-Account Containers settings
    "privacy.userContext.enabled" = true;
    "privacy.userContext.ui.enabled" = true;
  };

  # Container definitions (shared across profiles)
  containerConfig = {
    # Generic numbered containers
    "Container 1" = {
      id = 1;
      color = "blue";
      icon = "fingerprint";
    };
    "Container 2" = {
      id = 2;
      color = "turquoise";
      icon = "briefcase";
    };
    "Container 3" = {
      id = 3;
      color = "green";
      icon = "dollar";
    };
    "Container 4" = {
      id = 4;
      color = "yellow";
      icon = "cart";
    };
    "Container 5" = {
      id = 5;
      color = "orange";
      icon = "gift";
    };
    "Container 6" = {
      id = 6;
      color = "red";
      icon = "vacation";
    };
  };

in
{
  programs.firefox = {
    enable = true;

    # Use the standard Firefox package
    package = pkgs.firefox;

    # Policies applied to all profiles (system-wide settings)
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableFirefoxAccounts = false; # Keep sync enabled
      DisableSetDesktopBackground = true;
      DisplayBookmarksToolbar = "newtab";
      DontCheckDefaultBrowser = true;
      SearchBar = "unified";
    };

    profiles = {
      # Main personal profile
      main = {
        id = 0;
        name = "Main";
        isDefault = true;
        extensions.packages = commonExtensions;
        settings = commonSettings // {
          "browser.startup.homepage" = "about:home";
        };
        containers = containerConfig;
      };

      # Trustsoft work profile
      trustsoft = {
        id = 1;
        name = "Trustsoft";
        isDefault = false;
        extensions.packages = commonExtensions ++ workExtensions;
        settings = commonSettings // {
          "browser.startup.homepage" = "about:home";
        };
        containers = containerConfig;
      };

      # OpenVPN work profile
      openvpn = {
        id = 2;
        name = "OpenVPN";
        isDefault = false;
        extensions.packages = commonExtensions ++ workExtensions;
        settings = commonSettings // {
          "browser.startup.homepage" = "about:home";
        };
        containers = containerConfig;
      };
    };
  };
}
