{ stdenv, lib, fetchFromGitHub, go, pkg-config, gtk3, libappindicator-gtk3, webkitgtk, buildGoModule, makeWrapper }:

buildGoModule rec {
  pname = "deej";
  version = "0.9.10";

  src = fetchFromGitHub {
    owner = "omriharel";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-T6S3FQ9vxl4R3D+uiJ83z1ueK+3pfASEjpRI+HjIV0M==";
  };

  vendorHash = "sha256-1gjFPD7YV2MTp+kyC+hsj+NThmYG3hlt6AlOzXmEKyA=";

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    gtk3
    libappindicator-gtk3
    webkitgtk
  ];

  # Build the main package
  buildPhase = ''
    export GOPATH=$TMPDIR/go
    export CGO_ENABLED=1
    export GOOS=linux
    export GOARCH=amd64
    go build -o deej ./cmd
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp deej $out/bin/
    chmod +x $out/bin/deej

    # Create a wrapper script that sets up the environment
    makeWrapper $out/bin/deej $out/bin/deej-wrapper \
      --prefix PATH : ${lib.makeBinPath [ gtk3 libappindicator-gtk3 webkitgtk ]} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ gtk3 libappindicator-gtk3 webkitgtk ]}
  '';

  meta = with lib; {
    description = "An open-source hardware volume mixer for Windows and Linux PCs";
    homepage = "https://github.com/omriharel/deej";
    license = licenses.mit;
    maintainers = [ maintainers.stefanmatic ];
    platforms = platforms.linux;
  };
}
