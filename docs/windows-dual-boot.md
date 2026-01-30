# Windows Dual-Boot Guide

Restore Windows bootloader after NixOS drive changes.

## When Needed

After changing NixOS drive, Windows boot files need to be copied to the new EFI partition.

## Quick Fix (From NixOS)

If Windows boots from BIOS but not GRUB:

```bash
# Copy Windows boot files to NixOS EFI partition
sudo mkdir -p /boot/EFI/Microsoft
sudo cp -r /mnt/win/EFI/Microsoft/Boot /boot/EFI/Microsoft/
sudo nixos-rebuild switch --flake ~/.dotfiles#ZVIJER
```

## Full Restoration (Windows Recovery)

### 1. Boot Windows Recovery

- Boot from Windows USB
- "Repair your computer" → Troubleshoot → Command Prompt

### 2. Find Drives

```cmd
diskpart
list volume
select volume X    # Windows partition
assign letter=C:
select volume Y    # EFI partition
assign letter=Z:
exit
```

### 3. Restore Bootloader

```cmd
bcdboot C:\Windows /s Z: /f UEFI
```

### 4. Update NixOS GRUB

In `hosts/zvijer/configuration.nix`:

```nix
boot.loader.grub.extraEntries = ''
  menuentry "Windows 11" {
    search --fs-uuid --set=root YOUR-EFI-UUID
    chainloader /EFI/Microsoft/Boot/bootmgfw.efi
  }
'';
```

Get UUID: `blkid /dev/nvme1n1p1 | grep -oP 'UUID="\K[^"]+'`

### 5. Rebuild

```bash
sudo nixos-rebuild switch --flake ~/.dotfiles#ZVIJER
```

## Quick Reference

```bash
# Find EFI UUID
lsblk -f | grep vfat

# Check Windows boot files exist
ls /boot/EFI/Microsoft/Boot/bootmgfw.efi

# Check GRUB config
cat /boot/grub/grub.cfg | grep -A5 "Windows"
```
