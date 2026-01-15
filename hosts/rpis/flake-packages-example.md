# Example packages configuration for flake.nix to build SD card images
# Add this to your flake.nix outputs.packages section

# In your flake.nix, add these to the packages output:
{
  # Raspberry Pi 4 SD card images
  magic-mirror-sd = nixosConfigurations.magic-mirror.config.system.build.sdImage;
  arcade-sd = nixosConfigurations.arcade.config.system.build.sdImage;
  routercheech-sd = nixosConfigurations.routercheech.config.system.build.sdImage;
  
  # Pi Zero 2W SD card images (when you create Zero 2W configurations)
  # sensor-node-zero2w-sd = nixosConfigurations.sensor-node-zero2w.config.system.build.sdImage;
  # iot-gateway-zero2w-sd = nixosConfigurations.iot-gateway-zero2w.config.system.build.sdImage;

  # Cross-platform builds - these can be built from x86_64 for ARM64 targets
  # Use these when building on your main computer for Pi deployment
}

# To use these in your actual flake.nix, you would modify the outputs like this:
# 
# outputs = { self, nixpkgs, ... }@inputs: {
#   nixosConfigurations = {
#     # Your existing host configurations...
#     
#     # Pi configurations with SD image support
#     magic-mirror = nixpkgs.lib.nixosSystem {
#       system = "aarch64-linux";
#       specialArgs = { inherit inputs; };
#       modules = [
#         ./hosts/rpis/magic-mirror/configuration.nix
#         # Add SD image module for building images
#         ./hosts/_common/sd-image-config.nix
#       ];
#     };
#     
#     arcade = nixpkgs.lib.nixosSystem {
#       system = "aarch64-linux"; 
#       specialArgs = { inherit inputs; };
#       modules = [
#         ./hosts/rpis/arcade/configuration.nix
#         ./hosts/_common/sd-image-config.nix
#       ];
#     };
#     
#     routercheech = nixpkgs.lib.nixosSystem {
#       system = "aarch64-linux";
#       specialArgs = { inherit inputs; };
#       modules = [
#         ./hosts/rpis/routercheech/configuration.nix
#         ./hosts/_common/sd-image-config.nix
#       ];
#     };
#   };
#
#   # Add the packages for building SD images
#   packages.x86_64-linux = {
#     # SD card images that can be built from x86_64
#     magic-mirror-sd = self.nixosConfigurations.magic-mirror.config.system.build.sdImage;
#     arcade-sd = self.nixosConfigurations.arcade.config.system.build.sdImage;
#     routercheech-sd = self.nixosConfigurations.routercheech.config.system.build.sdImage;
#   };
#   
#   packages.aarch64-linux = {
#     # Native ARM64 builds (if building on ARM64 host)
#     magic-mirror-sd = self.nixosConfigurations.magic-mirror.config.system.build.sdImage;
#     arcade-sd = self.nixosConfigurations.arcade.config.system.build.sdImage;
#     routercheech-sd = self.nixosConfigurations.routercheech.config.system.build.sdImage;
#   };
# };

# Build commands:
#
# Build SD image on x86_64 host (cross-compilation):
# nix build .#magic-mirror-sd
# nix build .#arcade-sd
# nix build .#routercheech-sd
#
# Build SD image on ARM64 host (native):
# nix build .#magic-mirror-sd --system aarch64-linux
#
# Flash to SD card:
# sudo dd if=result/sd-image/nixos-sd-image-*.img of=/dev/sdX bs=4M status=progress conv=fsync
#
# Where /dev/sdX is your SD card device (check with `lsblk`)