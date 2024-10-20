# My NixOS Config


TO-DO:
------

    pyprland
    hyprpicker
    hyprcursor
    hyprlock
    hypridle
    hyprpaper




prebaciti sve stvari koje trebas uraditi u clickup

- incorporate snowflake cli into system (mkBashScript ili nesto tako)

- keepassxc rclone sync


 - natural scrolling on wayland and X11

 - add minimal defaults

 - check direnv installation in default home.nix

 sessionVaribles for EDITOR TERM and BROWSER (work/home.nix example)

 - CLI for quick commands based on librephoenix

 - DIgital clock plasma change display to dd/MM/yyyy

 - cursors are not working https://stylix.danth.me/options/nixos.html?highlight=cursor#stylixcursorname

 - what does nix flake update actually do?
   - should it be run regularly?

 - Ikone kad ls opalis (vjerovatno nerf-fonts)

 - clipboard like in plasma

 - CTRL + R u zsh kao sto imas u fishu


Cleanup
-------

```
nix-env --list-generations

nix-collect-garbage  --delete-old

nix-collect-garbage  --delete-generations 1 2 3

# recommeneded to sometimes run as sudo to collect additional garbage
sudo nix-collect-garbage -d

# As a separation of concerns - you will need to run this command to clean out boot
sudo /run/current-system/bin/switch-to-configuration boot
```