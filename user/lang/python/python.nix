{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Python setup
    python3
    python3.pkgs.pip
    python3.pkgs.tkinter # tkinter is now a separate package
    imath
    pystring
  ];

  # Ensure python3 is available in PATH
  home.shellAliases = {
    python = "python3";
  };
}
