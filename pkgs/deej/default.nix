{ lib
, stdenv
, fetchFromGitHub
, buildGoModule
, pkg-config
, glib
, gtk3
, libappindicator
, webkitgtk_4_0
}:

let
  version = "0.9.10";
in

buildGoModule {
  pname = "deej";
  inherit version;

  src = fetchFromGitHub {
    owner = "omriharel";
    repo = "deej";
    rev = "v${version}";
    hash = "sha256-T6S3FQ9vxl4R3D+uiJ83z1ueK+3pfASEjpRI+HjIV0M=";
  };

  vendorHash = "sha256-1gjFPD7YV2MTp+kyC+hsj+NThmYG3hlt6AlOzXmEKyA=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ glib gtk3 libappindicator webkitgtk_4_0 ];

  # The main executable is in the cmd directory
  buildPhase = ''
    runHook preBuild
    cd cmd
    go build -o deej
    runHook postBuild
  '';

  # Install the binary
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp deej $out/bin/
    runHook postInstall
  '';

  meta = with lib; {
    description = "Set app volumes with real sliders! deej is an Arduino & Go project to let you build your own hardware mixer for Windows and Linux";
    homepage = "https://github.com/omriharel/deej";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
