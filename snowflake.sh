#!/usr/bin/env bash

# Default location
FLAKE_DIR="$HOME/.dotfiles"
BACKUP_OPTION=""
EXTRA_ARGS=()

# Function to rebuild NixOS
rebuild_nixos() {
    echo "Rebuilding NixOS..."
    sudo nixos-rebuild switch --flake "$FLAKE_DIR" "${EXTRA_ARGS[@]}"
}

# Function to switch home-manager configuration
switch_home_manager() {
    echo "Switching home-manager configuration..."
    home-manager switch --flake "$FLAKE_DIR" $BACKUP_OPTION "${EXTRA_ARGS[@]}"
}

# Function to update Nix flake
update_flake() {
    echo "Updating Nix flake..."
    nix flake update "$FLAKE_DIR" "${EXTRA_ARGS[@]}"
}

# Function to display help message
show_help() {
    echo "Usage: snowflake [OPTIONS] COMMAND [EXTRA_ARGS...]"
    echo "Options:"
    echo "  -l, --location DIR   Specify the flake directory (default: ~/.dotfiles)"
    echo "  -b, --backup         Apply '-b backup' option to home-manager command"
    echo "Commands:"
    echo "  os, system    Rebuild NixOS"
    echo "  hm, home      Switch home-manager configuration"
    echo "  update        Update Nix flake"
    echo "  all           Perform all actions (rebuild, switch, and update)"
    echo "  help          Display this help message"
    echo "EXTRA_ARGS are passed directly to the underlying command"
}

# Parse command line options
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -l|--location)
            FLAKE_DIR="$2"
            shift
            ;;
        -b|--backup)
            BACKUP_OPTION="-b backup"
            ;;
        os|system|hm|home|update|all|help)
            COMMAND="$1"
            shift
            EXTRA_ARGS=("$@")
            break
            ;;
        *)
            EXTRA_ARGS+=("$1")
            ;;
    esac
    shift
done

# Main script logic
case "$COMMAND" in
    os|system)
        rebuild_nixos
        ;;
    hm|home)
        switch_home_manager
        ;;
    update)
        update_flake
        ;;
    all)
        rebuild_nixos
        switch_home_manager
        update_flake
        ;;
    help)
        show_help
        ;;
    *)
        echo "Invalid command. Use 'snowflake help' to see available commands."
        exit 1
        ;;
esac
