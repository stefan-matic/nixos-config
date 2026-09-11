{ pkgs, ... }:

# d4-kill: force-kill a wedged Diablo IV / Battle.net / gamescope / Proton tree.
#
# Diablo IV's own VRAM leak eventually OOMs the GPU and crashes the game; a
# crash (or a rapid relaunch) leaves gamescope + wineserver + winedevice +
# Battle.net alive, holding the nested X socket. The next launch then can't
# bind a display and gamescope silently falls back to the *headless* backend
# (no window) -> "Battle.net won't start". Killing the leftovers fixes it.
#
# This is NOT a launch wrapper -- run it by hand from a terminal (or a keybind)
# whenever a launch wedges, then relaunch from Steam. It leaves the Steam
# client, niri, and xwayland-satellite untouched; it only targets the D4 tree.
#
# Needs several passes: the pressure-vessel container reparents its children,
# so a single sweep misses some. Four passes with a pause clears it reliably.

pkgs.writeShellScriptBin "d4-kill" ''
  #!/usr/bin/env bash
  set -u

  APPID=3881340194
  PGREP=${pkgs.procps}/bin/pgrep
  SLEEP=${pkgs.coreutils}/bin/sleep

  collect() {
    {
      # Whole Steam/Proton/gamescope launch chain carries the D4 AppId in argv.
      "$PGREP" -f "$APPID"
      # Leaf wine / gamescope / Battle.net procs that don't carry the AppId.
      for c in gamescope gamescope-wl gamescopereaper wineserver \
               winedevice.exe Battle.net.exe Agent.exe "Diablo IV.exe"; do
        "$PGREP" -x "$c"
      done
    } 2>/dev/null | sort -u
  }

  for _ in 1 2 3 4; do
    pids=$(collect)
    [ -z "$pids" ] && break
    # collect() only matches specific D4/gamescope/wine comms + the AppId, so
    # nothing here is a kernel thread. Kill unconditionally — wine procs
    # (wineserver/winedevice) expose an EMPTY /proc/PID/cmdline, so guarding on
    # cmdline would skip exactly the procs that block the next launch.
    for p in $pids; do
      kill -9 "$p" 2>/dev/null || true
    done
    "$SLEEP" 1
  done

  left=$(collect)
  if [ -z "$left" ]; then
    echo "d4-kill: clean — no D4 / gamescope / wine procs left. Safe to relaunch."
  else
    echo "d4-kill: these survived (likely stuck on a wedged GPU context):"
    for p in $left; do
      echo "  $p $(cat /proc/"$p"/comm 2>/dev/null)"
    done
    echo "If they persist, a reboot clears a wedged GPU/driver state."
  fi
''
