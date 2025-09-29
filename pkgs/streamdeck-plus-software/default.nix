{ lib, python3, fetchFromGitHub, copyDesktopItems, makeDesktopItem }:

python3.pkgs.buildPythonApplication rec {
  pname = "streamdeck-plus-software";
  version = "0.0.1";

  src = /home/stefanmatic/Workspace/personal/streamdeck-plus-software;

  propagatedBuildInputs = with python3.pkgs; [
    cairocffi
    opencv4
    pillow
    pynput
    pyperclip
    requests
    streamdeck
  ];

  nativeBuildInputs = [
    copyDesktopItems
  ];

  # Install the Python scripts
  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/streamdeck-plus-software
    
    # Copy all Python files
    cp *.py $out/share/streamdeck-plus-software/
    
    # Copy resource files
    cp *.zip $out/share/streamdeck-plus-software/
    cp *.png $out/share/streamdeck-plus-software/
    cp *.txt $out/share/streamdeck-plus-software/
    
    # Create wrapper script
    cat > $out/bin/streamdeck-plus-software << EOF
#!/bin/sh
cd $out/share/streamdeck-plus-software
exec ${python3}/bin/python sdplus.py "\$@"
EOF
    chmod +x $out/bin/streamdeck-plus-software
    
    # Create installer wrapper
    cat > $out/bin/streamdeck-plus-install << EOF
#!/bin/sh
cd $out/share/streamdeck-plus-software
exec ${python3}/bin/python install.py "\$@"
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