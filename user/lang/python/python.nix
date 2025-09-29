{ pkgs, ... }:

{
  home.packages = with pkgs; [
      # Python setup
      python3Full
      python3.pkgs.pip
      imath
      pystring
  ];
  
  # Ensure python3 is available in PATH
  home.shellAliases = {
    python = "python3";
  };
}