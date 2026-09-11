{ pkgs, ... }:
{
  # Define your custom packages here
  select-browser = pkgs.callPackage ./select-browser { };
  #deej-serial-control = pkgs.callPackage ./deej-serial-control {};
  #deej-new = pkgs.callPackage ./deej-new {};
  steam-fix = pkgs.callPackage ./steam-fix { };
  d4-kill = pkgs.callPackage ./d4-kill { };
  opendeck = pkgs.callPackage ./opendeck { };
}
