{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "deej-new";
  version = "1.0.0";  # Using a placeholder version since there's no explicit version

  src = fetchFromGitHub {
    owner = "TheScabbage";
    repo = "deej-linux";
    rev = "master";
    sha256 = "sha256-FDKm8zQ25To6KmKO7cX9MJfCTnvzoqhMXXaXBT4xHlc=";
  };

  vendorHash = "sha256-9g8AugKTVkT4cucMzcBS/vJk7lukzvS6jKyKMqEe2io=";

  # The main package is actually in pkg/deej/cmd directory
  subPackages = [ "pkg/deej/cmd" ];

  # Add ldflags to match the build script
  ldflags = [
    "-s"
    "-w"
    "-X main.versionTag=${version}"
    "-X main.buildType=release"
  ];

  # Rename the binary to have a more standard name
  postInstall = ''
    mv $out/bin/cmd $out/bin/deej-linux

    # Create directories for configuration
    mkdir -p $out/share/deej
    cp ${src}/config.yaml $out/share/deej/
  '';

  meta = with lib; {
    description = "Set app volumes with real sliders - a hardware volume mixer for Linux";
    homepage = "https://github.com/TheScabbage/deej-linux";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.linux;
  };
}
