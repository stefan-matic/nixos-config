{ pkgs, ... }:

{
  home.packages = with pkgs; [
    go
  ];

  home.sessionVariables = {
    GOPATH = "$HOME/go";
  };

  home.sessionPath = [ "$HOME/go/bin" ];
}
