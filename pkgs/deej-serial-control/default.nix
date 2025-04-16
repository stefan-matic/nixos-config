{ lib, stdenv, pkgs, makeWrapper }:

stdenv.mkDerivation {
  pname = "deej-serial-control";
  version = "1.0.0";

  src = ./.;

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [ pkgs.bash pkgs.util-linux pkgs.pulseaudio ];

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/systemd/user

    # Copy the script
    cp $src/serial-volume-control.sh $out/bin/serial-volume-control.sh
    chmod +x $out/bin/serial-volume-control.sh

    # Copy and modify the systemd service file
    substitute $src/serial-volume-control.service $out/share/systemd/user/serial-volume-control.service \
      --replace '@PACKAGE_BIN_DIR@' $out/bin

    # Wrap the script with required dependencies
    wrapProgram $out/bin/serial-volume-control.sh \
      --prefix PATH : ${lib.makeBinPath [ pkgs.pulseaudio pkgs.bash pkgs.util-linux ]}
  '';

  meta = with lib; {
    description = "Arduino serial volume control script for PulseAudio/PipeWire";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
