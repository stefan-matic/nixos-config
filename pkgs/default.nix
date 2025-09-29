{ pkgs, ... }:
{
  # Define your custom packages here
  select-browser = pkgs.callPackage ./select-browser {};
  deej-serial-control = pkgs.callPackage ./deej-serial-control {};
  deej-new = pkgs.callPackage ./deej-new {};
  streamdeck-plus-software = pkgs.callPackage ./streamdeck-plus-software {};
}
