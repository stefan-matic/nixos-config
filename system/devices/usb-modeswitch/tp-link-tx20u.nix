{ pkgs, ... }:

{
  # TP-Link TX20U AX1800 USB WiFi Dongle Configuration
  # This device requires usb_modeswitch to switch from CDROM mode to WiFi mode
  #
  # Initial ID: 0bda:1a2b (Realtek - CDROM mode with Windows drivers)
  # Target ID:  0bda:8832 (Realtek RTL8832AU WiFi adapter)

  # Install usb-modeswitch packages
  environment.systemPackages = with pkgs; [
    usb-modeswitch
    usb-modeswitch-data
  ];

  # Create custom usb_modeswitch configuration for TP-Link TX20U
  environment.etc."usb_modeswitch.d/0bda:1a2b".text = ''
    # TP-Link TX20U AX1800 / Archer TX20U Plus
    # Realtek RTL8832AU chipset
    TargetVendor=0x0bda
    TargetProduct=0x8832
    StandardEject=1
  '';

  # Udev rules to trigger usb_modeswitch and load driver
  services.udev.extraRules = ''
    # TP-Link TX20U AX1800 - switch from CDROM to WiFi mode
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="1a2b", RUN+="${pkgs.usb-modeswitch}/bin/usb_modeswitch -v 0bda -p 1a2b -c /etc/usb_modeswitch.d/0bda:1a2b"

    # Load 8852bu driver when TP-Link WiFi device appears (after modeswitch)
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="35bc", ATTRS{idProduct}=="0100", RUN+="${pkgs.kmod}/bin/modprobe 8852bu"
  '';

  # Load the rtl8852bu kernel module (supports rtl8832bu chipset)
  boot.kernelModules = [ "8852bu" ];

  # Ensure kernel module is available
  boot.extraModulePackages = with pkgs.linuxKernel.packages.linux_6_12; [
    rtl8852bu
  ];
}
