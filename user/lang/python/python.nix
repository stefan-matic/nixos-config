{ pkgs, ... }:

{
  home.packages = with pkgs; [
    imath
    pystring
    pipx
    uv

    (python3.withPackages (
      ps: with ps; [
        pip
        tkinter
        pyyaml
        requests
        jsonschema
        tomli
      ]
    ))
  ];

  # Ensure python3 is available in PATH
  home.shellAliases = {
    python = "python3";
  };
}
