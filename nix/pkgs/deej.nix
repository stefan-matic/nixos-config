{ lib, stdenv, fetchFromGitHub, go, pkg-config, gtk3, libappindicator, libayatana-appindicator }:

stdenv.mkDerivation rec {
  pname = "deej";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "omriharel";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-7QZ6Q6Q6Q6Q6Q6Q6Q6Q6Q6Q6Q6Q6Q6Q6Q6Q6Q6Q6Q6Q6Q6Q=";
  };

  nativeBuildInputs = [ go pkg-config ];
  buildInputs = [ gtk3 libappindicator libayatana-appindicator ];

  buildPhase = ''
    export CGO_ENABLED=1
    export CGO_CFLAGS="-I${gtk3.dev}/include/gtk-3.0 -I${gtk3.dev}/include/gio-unix-2.0"
    export CGO_LDFLAGS="-L${gtk3}/lib -L${libappindicator}/lib -L${libayatana-appindicator}/lib"
    export XDG_DATA_DIRS="${gtk3}/share/gsettings-schemas/${gtk3.name}:${libappindicator}/share/gsettings-schemas/${libappindicator.name}:$XDG_DATA_DIRS"
    go build -o deej
  '';

  installPhase = ''
    install -Dm755 deej $out/bin/deej
  '';

  meta = with lib; {
    description = "A hardware volume mixer for Windows and Linux";
    homepage = "https://github.com/omriharel/deej";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
