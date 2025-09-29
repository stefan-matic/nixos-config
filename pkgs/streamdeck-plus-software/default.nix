{ lib, python3, copyDesktopItems, makeDesktopItem, stdenv }:

stdenv.mkDerivation rec {
  pname = "streamdeck-plus-software";
  version = "0.0.1";

  src = ./src;

  nativeBuildInputs = [
    copyDesktopItems
    python3
  ];

  buildInputs = with python3.pkgs; [
    cairocffi
    opencv4
    pillow
    pynput
    pyperclip
    requests
    streamdeck
  ];

  dontBuild = true;

  # Install the Python scripts
  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/streamdeck-plus-software
    
    # Copy all files from source
    cp -r $src/* $out/share/streamdeck-plus-software/
    
    # Create wrapper script
    cat > $out/bin/streamdeck-plus-software << EOF
#!/bin/sh
cd $out/share/streamdeck-plus-software
export PYTHONPATH="${python3.pkgs.makePythonPath (with python3.pkgs; [
  cairocffi opencv4 pillow pynput pyperclip requests streamdeck
])}:\$PYTHONPATH"
exec ${python3}/bin/python3 sdplus.py "\$@"
EOF
    chmod +x $out/bin/streamdeck-plus-software
    
    # Create installer wrapper
    cat > $out/bin/streamdeck-plus-install << EOF
#!/bin/sh
cd $out/share/streamdeck-plus-software
export PYTHONPATH="${python3.pkgs.makePythonPath (with python3.pkgs; [
  cairocffi opencv4 pillow pynput pyperclip requests streamdeck
])}:\$PYTHONPATH"
exec ${python3}/bin/python3 install.py "\$@"
EOF
    chmod +x $out/bin/streamdeck-plus-install
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "streamdeck-plus-software";
      exec = "streamdeck-plus-software";
      icon = "streamdeck-plus-software";
      desktopName = "Stream Deck Plus";
      comment = "Control Elgato Stream Deck Plus devices";
      categories = [ "Utility" "AudioVideo" ];
    })
  ];

  # Install icon
  postInstall = ''
    mkdir -p $out/share/pixmaps
    cp $out/share/streamdeck-plus-software/icon.png $out/share/pixmaps/streamdeck-plus-software.png
  '';

  meta = with lib; {
    description = "Alternative software for Elgato Stream Deck Plus devices";
    homepage = "https://github.com/goglesquirmintontheiii/streamdeck-plus-software";
    license = licenses.unfree; # No license specified in the repository
    maintainers = [ ];
    platforms = platforms.linux;
  };
}