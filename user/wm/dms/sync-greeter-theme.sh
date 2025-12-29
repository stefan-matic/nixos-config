#!/usr/bin/env bash
# DMS Greeter Theme Synchronization Script
# This script synchronizes wallpapers and themes from your user config to the greeter
#
# Usage: ./sync-greeter-theme.sh [username]
# If no username is provided, uses $USER

set -euo pipefail

USERNAME="${1:-$USER}"
GREETER_CACHE="/var/cache/dms-greeter"
USER_HOME="/home/$USERNAME"
USER_CONFIG="$USER_HOME/.config"
USER_SHARE="$USER_HOME/.local/share"

echo "DMS Greeter Theme Sync for user: $USERNAME"
echo "=========================================="

# Check if running as root (required for some operations)
if [[ $EUID -ne 0 ]]; then
   echo "This script should be run with sudo for proper ACL permissions"
   echo "Usage: sudo ./sync-greeter-theme.sh [username]"
   exit 1
fi

# Ensure greeter cache directory exists
echo "Creating greeter cache directory..."
mkdir -p "$GREETER_CACHE"
chown greeter:greeter "$GREETER_CACHE"
chmod 755 "$GREETER_CACHE"

# Add user to greeter group for ACL access
echo "Setting up ACL permissions..."
usermod -a -G greeter "$USERNAME" 2>/dev/null || true

# Set minimal ACL permissions on parent directories
setfacl -m g:greeter:rx "$USER_HOME" || {
  echo "Warning: Could not set ACL on $USER_HOME"
}

setfacl -m g:greeter:rx "$USER_CONFIG" || {
  echo "Warning: Could not set ACL on $USER_CONFIG"
}

# Create symlinks for DMS configuration
echo "Synchronizing DMS configuration..."
if [ -d "$USER_CONFIG/quickshell" ]; then
  ln -sfn "$USER_CONFIG/quickshell" "$GREETER_CACHE/quickshell"
  setfacl -R -m g:greeter:rX "$USER_CONFIG/quickshell" || true
  echo "  ✓ Synced quickshell config"
else
  echo "  ⚠ No quickshell config found at $USER_CONFIG/quickshell"
fi

# Create symlinks for wallpapers
echo "Synchronizing wallpapers..."
if [ -d "$USER_SHARE/wallpapers" ]; then
  ln -sfn "$USER_SHARE/wallpapers" "$GREETER_CACHE/wallpapers"
  setfacl -R -m g:greeter:rX "$USER_SHARE/wallpapers" || true
  echo "  ✓ Synced wallpapers"
else
  echo "  ⚠ No wallpapers found at $USER_SHARE/wallpapers"
fi

# Create symlinks for matugen themes
echo "Synchronizing matugen themes..."
if [ -d "$USER_CONFIG/matugen" ]; then
  ln -sfn "$USER_CONFIG/matugen" "$GREETER_CACHE/matugen"
  setfacl -R -m g:greeter:rX "$USER_CONFIG/matugen" || true
  echo "  ✓ Synced matugen themes"
else
  echo "  ⚠ No matugen config found at $USER_CONFIG/matugen"
fi

# Override cache directory location
echo ""
echo "Theme synchronization complete!"
echo ""
echo "Note: The greeter will automatically use the synced themes."
echo "If you update wallpapers or themes, run this script again to sync."
echo ""
echo "You may need to log out and back in for group changes to take effect."
