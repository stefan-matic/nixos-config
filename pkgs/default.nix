{ pkgs, ... }:
{
  # Define your custom packages here
  select-browser = pkgs.callPackage ./select-browser {};
  #deej-serial-control = pkgs.callPackage ./deej-serial-control {};
  #deej-new = pkgs.callPackage ./deej-new {};
  nordvpn = pkgs.callPackage ./nordvpn/package.nix {
    libxml2_13 = pkgs.libxml2;  # Use current libxml2, may need adjustment if 2.14+ causes issues
  };
}
