## Deej Volume Control

### Available services:

1. **deej-serial-control** - Original implementation using a shell script
2. **deej-new** - New implementation based on TheScabbage's deej-linux fork

The deej-new package and service are still being developed. To properly use it:

1. The package definition is in `/pkgs/deej-new/default.nix`
2. The service configuration is in `/home/services/deej-new.nix`
3. To enable it, uncomment the line in `home/stefanmatic.nix`:
   ```
   services.deej-new.enable = true;
   ```

Note: Due to network issues during initial package setup, the SHA256 hashes for the package source and vendor were not automatically generated. When updating the package, you'll need to:

```bash
# Update the package to use proper SHA256 hashes
cd ~/.dotfiles
nix-build -E "with import <nixpkgs> {}; callPackage ./pkgs/deej-new {}"
```

Then copy the error message's expected hash into the package definition.

## Deej Serial Control

Arduino-based volume control for applications using a serial connection. Setup includes:

- Home-manager service for controlling volume via serial connection
- Make sure Arduino is connected via USB
- User needs to be in the `dialout` group (configured automatically)
- Service auto-restarts on failure with optimal performance settings
- Control individual application volumes with physical sliders

Configuration is in `~/.config/deej/config.yaml` and allows mapping sliders to different applications.
