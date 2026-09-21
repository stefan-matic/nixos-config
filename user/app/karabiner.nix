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

  # Neutralise cmd-H (Hide Application).
  #
  # Coming from linux you reach for cmd where Alt used to be, and `h` is the
  # paneru focus-left key -- so alt-h (focus left) and cmd-h (hide the whole
  # app) sit one key apart. Hiding yanks every window of that app out of the
  # strip, paneru re-flows to close the gap, and it reads as windows jumping
  # around. paneru handles it correctly (Event::ApplicationHidden), but it is
  # rarely what was meant.
  #
  # Separate file, so it appears as its own entry in Karabiner's rule list
  # and can be toggled independently of the Finder rule above.
  #
  # NOTE: `mandatory` means those modifiers must be held and anything not
  # listed must NOT be -- so cmd+option+H (Hide Others) still passes through
  # untouched. Only bare cmd-H is swallowed.
  xdg.configFile."karabiner/assets/complex_modifications/no-cmd-h.json".text = builtins.toJSON {
    title = "Disable cmd-H (Hide Application)";
    rules = [
      {
        description = "cmd-H does nothing (cmd-option-H still hides others)";
        manipulators = [
          {
            type = "basic";
            from = {
              key_code = "h";
              modifiers = {
                mandatory = [ "command" ];
                optional = [ "caps_lock" ];
              };
            };
            to = [ { key_code = "vk_none"; } ];
          }
        ];
      }
    ];
  };
}
