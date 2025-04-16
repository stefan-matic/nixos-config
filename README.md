# My NixOS Config

## After resurrect

- CTRL + R u zsh kao sto imas u fishu

- incorporate snowflake cli into system (mkBashScript ili nesto tako)

- keepassxc rclone sync // treba li ovo jos s obzirom da imas syncthing? Treba jer offsite backup

- check direnv installation in default home.nix

- sessionVaribles for EDITOR TERM and BROWSER (work/home.nix example)

- cursors are not working https://stylix.danth.me/options/nixos.html?highlight=cursor#stylixcursorname

- Ikone kad ls opalis (vjerovatno nerf-fonts)

- Package deej-dev app

## KDE shortcuts

https://github.com/nix-community/plasma-manager

- natural scrolling on wayland and X11

## HYPRLAND things

- clipboard like in plasma

## Cleanup

```
nix-env --list-generations

nix-collect-garbage  --delete-old

nix-collect-garbage  --delete-generations 1 2 3

# recommeneded to sometimes run as sudo to collect additional garbage
sudo nix-collect-garbage -d

# As a separation of concerns - you will need to run this command to clean out boot
sudo /run/current-system/bin/switch-to-configuration boot
```

## Useful commands

```
nix-shell -p nix-info --run "nix-info -m"
```

## Deej Serial Control

Arduino-based volume control for applications using a serial connection. Setup includes:

- Home-manager service for controlling volume via serial connection
- Make sure Arduino is connected via USB
- User needs to be in the `dialout` group (configured automatically)
- Service auto-restarts on failure with optimal performance settings
- Control individual application volumes with physical sliders

Configuration is in `~/.config/deej/config.yaml` and allows mapping sliders to different applications.
