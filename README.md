# My NixOS Config

## After resurrect

- CTRL + R u zsh kao sto imas u fishu

- incorporate snowflake cli into system (mkBashScript ili nesto tako)

- keepassxc rclone sync // treba li ovo jos s obzirom da imas syncthing? Treba jer offsite backup

- natural scrolling on wayland and X11

- check direnv installation in default home.nix

- sessionVaribles for EDITOR TERM and BROWSER (work/home.nix example)

- cursors are not working https://stylix.danth.me/options/nixos.html?highlight=cursor#stylixcursorname

- Ikone kad ls opalis (vjerovatno nerf-fonts)

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
