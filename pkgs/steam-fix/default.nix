{ pkgs, lib, ... }:

pkgs.writeShellScriptBin "steam-fix" ''
  #!/usr/bin/env bash
  # Launch Steam with correct DISPLAY for xwayland-satellite
  # Issue: Niri sets DISPLAY=:0 but xwayland-satellite connects on :1
  # This causes Steam GUI to fail after other X11 apps have connected

  # Check which display xwayland-satellite is actually on
  if [ -e /tmp/.X11-unix/X1 ]; then
    echo "Found xwayland-satellite on :1, using DISPLAY=:1"
    export DISPLAY=:1
  else
    echo "Using default DISPLAY=$DISPLAY"
  fi

  # Launch Steam normally (not in gamescope - you want regular window mode)
  exec ${pkgs.steam}/bin/steam "$@"
''
