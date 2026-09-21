{ ... }:

{
  # Dolphin-style Finder keys via Karabiner-Elements.
  #
  # Finder hardcodes Return=rename and requires cmd-delete to trash, which is
  # backwards for anyone coming from a linux file manager. These cannot be
  # changed through `defaults`, so they are remapped at the event-tap level
  # and scoped to Finder only -- every other app keeps stock behaviour.
  #
  # Karabiner does not auto-enable rules dropped into assets/. After the first
  # rebuild: Karabiner-Elements -> Complex Modifications -> Add rule ->
  # enable "Dolphin-style Finder keys". It persists from then on.
  xdg.configFile."karabiner/assets/complex_modifications/dolphin-finder.json".text = builtins.toJSON {
    title = "Dolphin-style Finder keys";
    rules = [
      {
        description = "Finder: Return opens, Delete trashes, F2 renames";
        manipulators =
          let
            inFinder = [
              {
                type = "frontmost_application_if";
                bundle_identifiers = [ "^com\\.apple\\.finder$" ];
              }
            ];
          in
          [
            {
              type = "basic";
              description = "Return -> open (cmd-down)";
              from = {
                key_code = "return_or_enter";
                modifiers.optional = [ "caps_lock" ];
              };
              to = [
                {
                  key_code = "down_arrow";
                  modifiers = [ "left_command" ];
                }
              ];
              conditions = inFinder;
            }
            {
              type = "basic";
              description = "Delete -> move to Trash (cmd-delete)";
              from = {
                key_code = "delete_or_backspace";
                modifiers.optional = [ "caps_lock" ];
              };
              to = [
                {
                  key_code = "delete_or_backspace";
                  modifiers = [ "left_command" ];
                }
              ];
              conditions = inFinder;
            }
            {
              type = "basic";
              description = "F2 -> rename";
              from = {
                key_code = "f2";
                modifiers.optional = [ "any" ];
              };
              to = [ { key_code = "return_or_enter"; } ];
              conditions = inFinder;
            }
          ];
      }
    ];
  };
}
