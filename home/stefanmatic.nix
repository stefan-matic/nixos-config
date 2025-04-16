{ config, pkgs, inputs, outputs, ... }:

let
  userSettings = {
    username = "stefanmatic";
    name = "Stefan Matic";
    email = "stefanmatic94@gmail.com";
    theme = "dracula";
    term = "alacritty"; # Default terminal command;
    font = "Intel One Mono"; # Selected font
    fontPkg = pkgs.intel-one-mono; # Font package
    editor = "nano"; # Default editor;
  };
in

{
	imports = [
    ./_common.nix
    #../user/app/obs-studio.nix
    ./services/deej-serial-control.nix
  ];

  _module.args = {
    inherit userSettings;
  };

  home.packages =
    with pkgs; [
      prusa-slicer

      dbeaver-bin
      slack
      #yubioath-flutter

      terraform
      opentofu
      kubectl
      awscli2
    ];

  services.kdeconnect = {
    enable = true;
    indicator = true;
  };

  # Enable the deej-serial-control service
  services.deej-serial-control.enable = true;

  # Add user to dialout group for Arduino access
  home.activation.addToDialoutGroup = pkgs.lib.hm.dag.entryAfter ["writeBoundary"] ''
    echo "Adding user to dialout group for Arduino access..."
    sudo usermod -a -G dialout ${userSettings.username}
  '';

  # deej configuration
  xdg.configFile."deej/config.yaml".text = ''
    # Slider mapping
    slider_mapping:
      0: master
      1: google-chrome-stable
      2: spotify
      3: discord
      4: firefox

    # Process names are case-sensitive
    # You can use 'master' to indicate system-wide volume
    # You can use 'mic' to control your microphone's input level
    # On Linux, use the process command line (eg. 'firefox' or 'firefox-bin')

    # Set this to true if you want the controls inverted (i.e. top is 0%, bottom is 100%)
    invert_sliders: false

    # Set this to true if you want to use your system tray to display a deej icon
    tray_icon: true

    # Set this to true if you want the tray icon to be colored
    colored_tray_icon: true

    # Set this to true if you want to see verbose debug prints in your console
    verbose_logging: true

    # Serial connection (adjust this based on your Arduino device)
    com_port: /dev/ttyACM0
    baud_rate: 9600

    # Adjust noise reduction based on your hardware quality
    # Supported values: "low" (excellent hardware), "default" (regular hardware), "high" (bad, noisy hardware)
    noise_reduction: default

    # Additional debug settings
    debug: true
    log_level: debug
  '';
}


