{ stdenv, lib, fetchFromGitHub, go, pkg-config, gtk3, libappindicator-gtk3, webkitgtk, buildGoModule }:

buildGoModule rec {
  pname = "deej";
  version = "0.9.10";

  src = fetchFromGitHub {
    owner = "omriharel";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # We'll need to update this
  };

  vendorSha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # We'll need to update this

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    gtk3
    libappindicator-gtk3
    webkitgtk
  ];

  buildPhase = ''
    export GOPATH=$TMPDIR/go
    export CGO_ENABLED=1
    go build -o deej
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp deej $out/bin/
  '';

  meta = with lib; {
    description = "An open-source hardware volume mixer for Windows and Linux PCs";
    homepage = "https://github.com/omriharel/deej";
    license = licenses.mit;
    maintainers = [ maintainers.stefanmatic ];
    platforms = platforms.linux;
  };
}
