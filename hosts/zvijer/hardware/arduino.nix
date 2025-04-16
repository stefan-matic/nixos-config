{ config, pkgs, ... }:

{
  # Allow users in the "dialout" group to access serial ports
  services.udev.extraRules = ''
    # Rules for Arduino devices used with deej
    SUBSYSTEM=="tty", ATTRS{idVendor}=="2341", ATTRS{idProduct}=="*", GROUP="dialout", MODE="0660", SYMLINK+="arduino"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="*", GROUP="dialout", MODE="0660", SYMLINK+="arduino"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="2a03", ATTRS{idProduct}=="*", GROUP="dialout", MODE="0660", SYMLINK+="arduino"
    # Also add a catch-all rule for any ACM devices
    KERNEL=="ttyACM[0-9]*", GROUP="dialout", MODE="0660"
  '';

  # Add your user to the dialout group
  users.users.stefanmatic.extraGroups = [ "dialout" ];
}
