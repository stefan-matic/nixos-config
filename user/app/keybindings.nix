{ ... }:

{
  # Linux-style text navigation for Cocoa text views.
  #
  # macOS uses option for word motion and command for line ends; linux uses
  # control for both. This file remaps the control variants via the Cocoa
  # text system's key-binding dictionary.
  #
  # SCOPE, and it is a real limitation: this only affects apps built on the
  # Cocoa text system -- Mail, Notes, Safari fields, TextEdit, Finder rename,
  # most native apps. Electron (Slack, VS Code, Bruno, Discord) and terminal
  # apps implement their own editing and ignore it entirely. Inside ghostty
  # the shell's own readline/zle bindings apply instead.
  #
  # Key codes: UF700-UF703 arrows, U007F backspace, UF728 forward-delete,
  # UF729 home, UF72B end. Modifier prefixes: ^ control, ~ option,
  # $ shift, @ command.
  home.file."Library/KeyBindings/DefaultKeyBinding.dict".text = ''
    {
      /* ctrl + arrows jump by word, as on linux */
      "^\UF702" = "moveWordBackward:";
      "^\UF703" = "moveWordForward:";
      "^$\UF702" = "moveWordBackwardAndModifySelection:";
      "^$\UF703" = "moveWordForwardAndModifySelection:";

      /* ctrl + backspace / delete removes a whole word */
      "^\U007F" = "deleteWordBackward:";
      "^\UF728" = "deleteWordForward:";

      /* home / end (fn+left / fn+right) go to line ends, not document ends,
         which is what every linux toolkit does */
      "\UF729" = "moveToBeginningOfLine:";
      "\UF72B" = "moveToEndOfLine:";
      "$\UF729" = "moveToBeginningOfLineAndModifySelection:";
      "$\UF72B" = "moveToEndOfLineAndModifySelection:";

      /* ctrl + home / end go to document ends */
      "^\UF729" = "moveToBeginningOfDocument:";
      "^\UF72B" = "moveToEndOfDocument:";
      "^$\UF729" = "moveToBeginningOfDocumentAndModifySelection:";
      "^$\UF72B" = "moveToEndOfDocumentAndModifySelection:";
    }
  '';
}
