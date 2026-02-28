{ config, lib, pkgs, ... }:

let
  configJson = builtins.toJSON {
    version = "2.2.0";
    autoload = {
      "Razer Razer Naga V2 Pro" = "Niri";
    };
  };

  presetJson = builtins.toJSON [
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
in
{
  # Input Remapper configuration for Razer Naga V2 Pro
  # Maps side buttons to useful shortcuts for Niri window manager
  #
  # Files are copied (not symlinked) because input-remapper needs to write
  # to config.json during startup migration. Read-only nix store symlinks
  # cause OSError: [Errno 30] Read-only file system.

  home.activation.inputRemapperConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    config_dir="${config.xdg.configHome}/input-remapper-2"
    preset_dir="$config_dir/presets/Razer Razer Naga V2 Pro"

    mkdir -p "$config_dir"
    mkdir -p "$preset_dir"

    # Remove symlinks if home-manager previously managed these
    [ -L "$config_dir/config.json" ] && rm "$config_dir/config.json"
    [ -L "$preset_dir/Niri.json" ] && rm "$preset_dir/Niri.json"

    # Write config as mutable files (input-remapper needs write access)
    cat > "$config_dir/config.json" << 'CONFIGEOF'
${configJson}
CONFIGEOF

    cat > "$preset_dir/Niri.json" << 'PRESETEOF'
${presetJson}
PRESETEOF
  '';
}
