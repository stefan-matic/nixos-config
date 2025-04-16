{ pkgs, ... }:
{
  # Define your custom packages here
  select-browser = pkgs.callPackage ./select-browser {};
  deej-serial-control = pkgs.callPackage ./deej-serial-control {};
}
