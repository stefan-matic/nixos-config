#!/usr/bin/env bash
# Sync StreamController configuration from live Flatpak data back to dotfiles
# Usage: ./sync-from-live.sh

set -e

LIVE_DIR="$HOME/.var/app/com.core447.StreamController/data"
DOTFILES_DIR="$HOME/.dotfiles/user/app/streamcontroller"

echo "==> Syncing StreamController configs from live installation to dotfiles..."
echo ""

# Copy page configurations
echo "Copying page configurations..."
cp -v "$LIVE_DIR/pages/Main.json" "$DOTFILES_DIR/pages/"
cp -v "$LIVE_DIR/pages/Emoji.json" "$DOTFILES_DIR/pages/"

# Copy settings
echo ""
echo "Copying settings..."
cp -v "$LIVE_DIR/settings/settings.json" "$DOTFILES_DIR/settings/"
cp -v "$LIVE_DIR/settings/migrations.json" "$DOTFILES_DIR/settings/"

echo ""
echo "==> Sync complete!"
echo ""
echo "Next steps:"
echo "  1. Review changes: cd $DOTFILES_DIR && git diff"
echo "  2. Update README.md if you added/changed buttons"
echo "  3. Commit changes: git add . && git commit -m 'Update StreamController configuration'"
echo "  4. Apply to system: home-manager switch --flake ~/.dotfiles#stefanmatic@ZVIJER"
