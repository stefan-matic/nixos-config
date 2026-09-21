{ ... }:

{
  # Application-launch hotkeys, the half of the niri keymap paneru cannot do.
  #
  # Paneru's [bindings] table only drives window commands -- it has no way to
  # spawn a process. Its Lua config can (os.execute), but init.lua *replaces*
  # paneru.toml wholesale, which would mean re-expressing the entire window
  # config in Lua. skhd is the smaller, declarative answer: paneru keeps
  # window management, skhd owns the launch chords. They share `alt` without
  # conflict because the chord sets are disjoint.
  #
  # skhd needs its own Accessibility grant on first run.
  services.skhd = {
    enable = true;
    skhdConfig = ''
      # === niri: Mod+Return -> terminal ===
      # -n forces a new window even when Ghostty is already running.
      alt - return : open -na Ghostty

      # === niri: Mod+E -> dolphin ===
      alt - e : open -a Marta

      # === niri: Mod+T -> kate ===
      alt - t : open -a Zed

      # === niri: Mod+Q -> close-window ===
      # Paneru has no close command; macOS closes with cmd-w, so translate.
      alt - q : osascript -e 'tell application "System Events" to keystroke "w" using command down'

      # === niri: Mod+Shift+F -> fullscreen-window ===
      # Native macOS fullscreen (ctrl-cmd-f), distinct from paneru's
      # window_fullwidth on alt-f which only maximises within the strip.
      alt + shift - f : osascript -e 'tell application "System Events" to keystroke "f" using {control down, command down}'

      # === niri: Mod+Tab / Mod+O -> toggle-overview ===
      # Mission Control is the closest macOS analogue.
      alt - tab : open -a "Mission Control"

      # === niri: Mod+Alt+L -> lock screen ===
      alt + cmd - l : pmset displaysleepnow

      # === niri: Print / Ctrl+Shift+X -> grim+slurp+swappy ===
      # Shottr is the annotate-after-capture equivalent; cmd-shift-4 is the
      # built-in region capture it hooks into.
      ctrl + shift - x : open -a Shottr
    '';
  };
}
