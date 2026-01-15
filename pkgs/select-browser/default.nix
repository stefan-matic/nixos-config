{
  stdenv,
  lib,
  kdePackages,
  makeWrapper,
}:

stdenv.mkDerivation {
  pname = "select-browser";
  version = "1.0.0";

  src = ./.;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp select-browser-kdialog.sh $out/bin/select-browser
    chmod +x $out/bin/select-browser

    wrapProgram $out/bin/select-browser \
      --prefix PATH : ${lib.makeBinPath [ kdePackages.kdialog ]}

    mkdir -p $out/share/applications
    cp select-browser.desktop $out/share/applications/
  '';

  meta = with lib; {
    description = "A script to select and launch different browsers using KDialog";
    license = licenses.mit;
    maintainers = [ maintainers.stefanmatic ];
    platforms = platforms.linux;
  };
}
