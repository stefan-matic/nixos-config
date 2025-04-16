{ pkgs, ... }:
{
  # Define your custom packages here
  select-browser = pkgs.callPackage ./select-browser {};
  deej = pkgs.callPackage ./deej {};
}
