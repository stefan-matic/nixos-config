{ config, lib, ... }:

{
  # Input Remapper configuration for Razer Naga V2 Pro
  # Maps side buttons to useful shortcuts for Niri window manager

  # Main config - sets autoload for devices
  xdg.configFile."input-remapper-2/config.json".text = builtins.toJSON {
    version = "2.1.1";
    autoload = {
      # Device name -> Preset name (without .json extension)
      "Razer Razer Naga V2 Pro" = "Niri";
    };
  };

  # Razer Naga V2 Pro preset for Niri
  # Side button mappings:
  #   Button 2 (code 2) -> Alt+Left (previous workspace)
  #   Button 4 (code 4) -> Alt+Right (next workspace)
  #   Button 6 (code 6) -> Super (open launcher)
  xdg.configFile."input-remapper-2/presets/Razer Razer Naga V2 Pro/Niri.json".text = builtins.toJSON [
    {
      input_combination = [
        {
          type = 1;
          code = 2;
          origin_hash = "2fb4547b2e836f8c6f4bbb7f48c1a737";
        }
      ];
      target_uinput = "keyboard";
      output_symbol = "Alt_L + KEY_LEFT";
      mapping_type = "key_macro";
    }
    {
      input_combination = [
        {
          type = 1;
          code = 4;
          origin_hash = "2fb4547b2e836f8c6f4bbb7f48c1a737";
        }
      ];
      target_uinput = "keyboard";
      output_symbol = "Alt_L + KEY_RIGHT";
      mapping_type = "key_macro";
    }
    {
      input_combination = [
        {
          type = 1;
          code = 6;
          origin_hash = "2fb4547b2e836f8c6f4bbb7f48c1a737";
        }
      ];
      target_uinput = "keyboard";
      output_symbol = "Super_L";
      mapping_type = "key_macro";
    }
  ];
}
