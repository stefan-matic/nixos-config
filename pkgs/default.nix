{ pkgs, ... }:
{
  # Define your custom packages here
  select-browser = pkgs.callPackage ./select-browser { };
  #deej-serial-control = pkgs.callPackage ./deej-serial-control {};
  #deej-new = pkgs.callPackage ./deej-new {};
  steam-fix = pkgs.callPackage ./steam-fix { };
  opendeck = pkgs.callPackage ./opendeck { };
}
