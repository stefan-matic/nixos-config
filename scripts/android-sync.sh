#!/usr/bin/env bash
# Sync dotfiles from Android shared storage and rebuild nix-on-droid
set -euo pipefail

SRC="/storage/emulated/0/NixOS"

if [ ! -d "$SRC" ]; then
    echo "Error: Source directory $SRC not found"
    exit 1
fi

echo "Syncing $SRC -> $HOME ..."
cp -r "$SRC"/. "$HOME"/
echo "Sync complete."

echo ""
echo "Rebuilding nix-on-droid..."
nix-on-droid switch --flake "$HOME/.dotfiles#fold6"
