# Windows Dual-Boot EFI Restoration Guide

This guide documents how to restore Windows bootloader when changing NixOS drives or setting up dual-boot after a disk replacement.

## Overview

When dual-booting NixOS and Windows, both operating systems share the same EFI partition. If you change your NixOS drive, you create a new EFI partition, but Windows boot files remain on the old EFI partition. This guide shows how to restore Windows boot files to the new EFI partition.

## Prerequisites

- Windows installation USB/DVD (recovery media)
- Access to Windows Recovery Environment
- Knowledge of your drive layout

## Current ZVIJER Drive Layout

As of 2026-01-04:

```
nvme0n1 (1TB Samsung 990 PRO) - Windows Drive
├─ nvme0n1p1 - Microsoft Reserved Partition
├─ nvme0n1p2 - Windows NTFS (UUID: 322666BE266682A9) - Mounted at /mnt/win
└─ nvme0n1p3 - NTFS Storage (UUID: 52BCAB16BCAAF41F)

nvme1n1 (2TB Samsung 990 PRO) - NixOS Drive
├─ nvme1n1p1 - EFI Partition (UUID: FDAE-C0AC) - Mounted at /boot
├─ nvme1n1p2 - LUKS encrypted root
└─ nvme1n1p3 - LUKS encrypted swap
```

## Step-by-Step Restoration Process

### Step 1: Boot Windows Recovery Environment

1. Insert Windows installation USB/DVD
2. Restart and boot from USB (F12 or Del to enter boot menu)
3. Select language and keyboard layout
4. Click "Repair your computer" (NOT "Install now")
5. Choose "Troubleshoot" → "Advanced options" → "Command Prompt"

### Step 2: Identify Drive Letters

Windows Recovery may assign different drive letters than what you expect. Run:

```cmd
diskpart
list volume
```

Look for:
- **Windows partition**: The NTFS partition with Windows installed (should be ~931 GB for nvme0n1p2)
- **EFI partition**: FAT32 partition (should be ~512 MB for nvme1n1p1)

### Step 3: Assign Drive Letters

```cmd
# Select your Windows partition (adjust volume number based on list volume output)
select volume X
assign letter=C:

# Select the EFI partition
select volume Y
assign letter=Z:

exit
```

### Step 4: Restore Windows Bootloader

Run the following command to reinstall Windows boot files to the EFI partition:

```cmd
bcdboot C:\Windows /s Z: /f UEFI
```

This copies Windows boot files from `C:\Windows` to the EFI partition mounted at `Z:`.

Expected output:
```
Boot files successfully created.
```

### Step 5: Verify Boot Files

Check that Windows boot files were created:

```cmd
dir Z:\EFI\Microsoft\Boot
```

You should see `bootmgfw.efi` and other boot files.

### Step 6: Exit and Reboot

```cmd
exit
```

Remove the Windows USB and reboot into NixOS.

### Step 7: Update NixOS GRUB Configuration

After restoring Windows boot files, update your GRUB configuration to point to the correct EFI partition.

Edit `/home/stefanmatic/.dotfiles/hosts/zvijer/configuration.nix`:

```nix
boot.loader.grub = {
  enable = true;
  devices = [ "nodev" ];
  efiSupport = true;
  useOSProber = false;
  configurationLimit = 20;
  extraEntries = ''
    menuentry "Windows 11" {
      search --fs-uuid --set=root FDAE-C0AC
      chainloader /EFI/Microsoft/Boot/bootmgfw.efi
    }
  '';
};
```

**Important**: Replace `FDAE-C0AC` with your actual EFI partition UUID from:
```bash
lsblk -f | grep vfat
# or
blkid /dev/nvme1n1p1
```

### Step 8: Rebuild NixOS Configuration

```bash
sudo nixos-rebuild switch --flake ~/.dotfiles#ZVIJER
```

### Step 9: Test Windows Boot

Reboot and test that Windows appears in the GRUB menu and boots successfully.

## Alternative: Using os-prober

Instead of manually specifying the Windows entry, you can enable os-prober to auto-detect operating systems:

```nix
boot.loader.grub = {
  enable = true;
  devices = [ "nodev" ];
  efiSupport = true;
  useOSProber = true;  # Enable auto-detection
  configurationLimit = 20;
  # Remove extraEntries or leave empty
};
```

**Note**: os-prober may be slower and less reliable than manual entries.

## Common Issues

### "Boot device not found" or "Operating system not found"

**Cause**: Windows boot files not on the EFI partition or wrong UUID in GRUB config.

**Solution**: Verify Windows boot files exist:
```bash
ls -la /boot/EFI/Microsoft/Boot/
```

If missing, repeat Steps 1-6 to restore boot files.

### Windows boots but can't find system partition

**Cause**: BCD (Boot Configuration Data) references old disk.

**Solution**: In Windows Recovery Command Prompt:
```cmd
bootrec /rebuildbcd
bootrec /fixboot
```

### "Access denied" when running bcdboot

**Cause**: Wrong drive letter assignment or permissions issue.

**Solution**: Verify drive letters in diskpart and ensure you're in Administrator Command Prompt.

### Windows boots from BIOS but not from GRUB

**Cause**: Windows boot files are on the NTFS partition instead of the EFI partition.

**Explanation**: Some Windows installations store the bootloader on the NTFS partition itself rather than a separate EFI partition. The UEFI firmware can boot from this using a boot entry stored in NVRAM, but GRUB expects boot files on the EFI partition.

**Diagnosis**:
1. Check if Windows boots when manually selecting the drive from BIOS
2. Check UEFI boot entries: `efibootmgr -v`
3. Look for Windows boot files on the mounted Windows partition:
   ```bash
   ls -la /mnt/win/EFI/Microsoft/Boot/
   ```

**Solution**: Copy Windows boot files from NTFS to EFI partition:
```bash
# Ensure Windows partition is mounted (check hardware-configuration.nix)
sudo mkdir -p /boot/EFI/Microsoft
sudo cp -r /mnt/win/EFI/Microsoft/Boot /boot/EFI/Microsoft/

# Verify files were copied
ls -la /boot/EFI/Microsoft/Boot/bootmgfw.efi

# Rebuild NixOS to update GRUB
sudo nixos-rebuild switch --flake ~/.dotfiles#ZVIJER
```

After this, GRUB will be able to find and chainload the Windows bootloader.

## Future Disk Changes

When changing disks in the future, follow this checklist:

### Before Changing NixOS Drive:

1. **Backup your configuration**:
   ```bash
   cd ~/.dotfiles
   git add -A
   git commit -m "Backup before disk change"
   git push
   ```

2. **Document current drive layout**:
   ```bash
   lsblk -f > ~/disk-layout-backup.txt
   blkid > ~/blkid-backup.txt
   ```

3. **Note your current EFI UUID**:
   ```bash
   grep "search --fs-uuid" ~/.dotfiles/hosts/zvijer/configuration.nix
   ```

### After Installing NixOS on New Drive:

1. **Mount Windows partition** (add to hardware-configuration.nix):
   ```nix
   fileSystems."/mnt/win" = {
     device = "/dev/disk/by-uuid/YOUR-WINDOWS-UUID";
     fsType = "ntfs-3g";
     options = [ "rw" "uid=1000" "gid=100" "umask=0022" "fmask=0022" "dmask=0022" "nofail" ];
   };
   ```

2. **Restore Windows bootloader** (follow Steps 1-6 above)

3. **Update GRUB config** with new EFI UUID (Step 7)

4. **Rebuild and test** (Steps 8-9)

## Quick Reference Commands

```bash
# Find EFI partition UUID
lsblk -f | grep vfat
blkid | grep vfat

# Find Windows partition UUID
blkid | grep ntfs

# List EFI boot files
ls -la /boot/EFI/

# Check GRUB config
cat /boot/grub/grub.cfg | grep -A5 "Windows"

# Rebuild NixOS
sudo nixos-rebuild switch --flake ~/.dotfiles#ZVIJER
```

## References

- [NixOS GRUB Documentation](https://nixos.wiki/wiki/Bootloader)
- [Microsoft bcdboot Documentation](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/bcdboot-command-line-options-techref-di)
- [Dual Boot Setup Guide](https://nixos.wiki/wiki/Dual_Booting_NixOS_and_Windows)
