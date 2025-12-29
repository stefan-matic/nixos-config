{ pkgs, ... }:

{
  # Common user applications for all hosts
  # These are personal apps that every user configuration should have

  home.packages = with pkgs; [
    # Browsers
    chromium
    firefox

    # Terminal Emulator
    ghostty

    # System Information
    fastfetch

    # Network utilities (user-level)
    ipcalc
    ldns

    # Security & Encryption
    gnupg
    veracrypt

    # Media Players
    vlc
    mpv

    # Productivity
    libreoffice-qt6-fresh

    # File Management
    qdirstat

    # Screenshots & OCR (user utilities)
    tesseract4

    # Custom scripts
    (pkgs.writeScriptBin "screenshot-ocr" ''
      #!/bin/sh
      imgname="/tmp/screenshot-ocr-$(date +%Y%m%d%H%M%S).png"
      txtname="/tmp/screenshot-ocr-$(date +%Y%m%d%H%M%S)"
      txtfname=$txtname.txt
      grim -g "$(slurp)" $imgname;
      tesseract $imgname $txtname;
      wl-copy -n < $txtfname
    '')
  ];
}
