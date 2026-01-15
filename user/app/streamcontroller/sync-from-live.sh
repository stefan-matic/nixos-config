#!/usr/bin/env bash
# Sync StreamController configuration from live Flatpak data back to dotfiles
# Usage: ./sync-from-live.sh [--commit "message"]

set -e

LIVE_DIR="$HOME/.var/app/com.core447.StreamController/data"
DOTFILES_DIR="$HOME/.dotfiles/user/app/streamcontroller"
AUTO_COMMIT=false
COMMIT_MSG=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --commit)
            AUTO_COMMIT=true
            COMMIT_MSG="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--commit \"commit message\"]"
            exit 1
            ;;
    esac
done

echo "==> Syncing StreamController configs from live installation to dotfiles..."
echo ""

# Check if live directory exists
if [[ ! -d "$LIVE_DIR" ]]; then
    echo "Error: StreamController data directory not found at: $LIVE_DIR"
    echo "Make sure StreamController is installed via Flatpak."
    exit 1
fi

# Copy all page configurations (dynamically discover them)
echo "Copying page configurations..."
mkdir -p "$DOTFILES_DIR/pages"
if [[ -d "$LIVE_DIR/pages" ]]; then
    for page in "$LIVE_DIR/pages"/*.json; do
        if [[ -f "$page" ]]; then
            cp -v "$page" "$DOTFILES_DIR/pages/"
        fi
    done
else
    echo "Warning: No pages directory found in $LIVE_DIR"
fi

# Copy settings
echo ""
echo "Copying settings..."
mkdir -p "$DOTFILES_DIR/settings"
if [[ -d "$LIVE_DIR/settings" ]]; then
    for setting in "$LIVE_DIR/settings"/*.json; do
        if [[ -f "$setting" ]]; then
            cp -v "$setting" "$DOTFILES_DIR/settings/"
        fi
    done
else
    echo "Warning: No settings directory found in $LIVE_DIR"
fi

echo ""
echo "==> Sync complete!"
echo ""

# Show what changed
cd "$DOTFILES_DIR"
if git diff --quiet .; then
    echo "No changes detected."
else
    echo "Changes detected:"
    echo ""
    git diff --stat .
    echo ""
    echo "==> Detailed changes:"
    git diff .
    echo ""
fi

# Auto-commit if requested
if [[ "$AUTO_COMMIT" == true ]]; then
    if git diff --quiet .; then
        echo "Nothing to commit."
    else
        cd ~/.dotfiles
        git add user/app/streamcontroller/
        git commit -m "${COMMIT_MSG:-Update StreamController configuration}"
        echo ""
        echo "Changes committed!"
    fi
fi

# Next steps
echo ""
echo "Next steps:"
if [[ "$AUTO_COMMIT" != true ]]; then
    echo "  1. Review changes: cd $DOTFILES_DIR && git diff"
    echo "  2. Update README.md if you added/changed buttons"
    echo "  3. Commit changes: git add . && git commit -m 'Update StreamController configuration'"
    echo "  4. Apply to system: home-manager switch --flake ~/.dotfiles#stefanmatic@ZVIJER"
else
    echo "  1. Update README.md if you added/changed buttons"
    echo "  2. Apply to system: home-manager switch --flake ~/.dotfiles#stefanmatic@ZVIJER"
fi
echo ""
echo "Tip: Use --commit \"message\" to automatically commit changes"
