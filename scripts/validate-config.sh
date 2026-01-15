#!/usr/bin/env bash
# Local validation script - mirrors GitLab CI checks
# Run this before pushing to catch issues early

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}NixOS Configuration Validation${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Track results
FAILED_CHECKS=()
PASSED_CHECKS=()

run_check() {
    local name=$1
    local command=$2

    echo -e "${YELLOW}Running: ${name}${NC}"
    if eval "$command" > /tmp/nix-check-$$.log 2>&1; then
        echo -e "${GREEN}✓ ${name} passed${NC}"
        PASSED_CHECKS+=("$name")
    else
        echo -e "${RED}✗ ${name} failed${NC}"
        echo -e "${RED}Error output:${NC}"
        cat /tmp/nix-check-$$.log
        FAILED_CHECKS+=("$name")
    fi
    echo ""
}

# Flake metadata check
echo -e "${BLUE}=== Flake Metadata ===${NC}"
run_check "Flake metadata" "nix flake metadata"

# Format checking (optional)
echo -e "${BLUE}=== Code Quality Checks ===${NC}"
if command -v alejandra &> /dev/null; then
    run_check "Alejandra formatting" "alejandra --check ."
elif command -v nixpkgs-fmt &> /dev/null; then
    run_check "nixpkgs-fmt formatting" "nixpkgs-fmt --check ."
else
    echo -e "${YELLOW}⚠ No formatter found (alejandra/nixpkgs-fmt), skipping format check${NC}"
    echo ""
fi

# Statix linting
if nix run nixpkgs#statix -- --version &> /dev/null; then
    run_check "Statix linting" "nix run nixpkgs#statix -- check ."
else
    echo -e "${YELLOW}⚠ Statix not available, skipping lint check${NC}"
    echo ""
fi

# Dead code detection
if nix run nixpkgs#deadnix -- --version &> /dev/null; then
    run_check "Dead code check" "nix run nixpkgs#deadnix -- --fail ."
else
    echo -e "${YELLOW}⚠ Deadnix not available, skipping dead code check${NC}"
    echo ""
fi

# Flake validation
echo -e "${BLUE}=== Flake Validation ===${NC}"
run_check "Flake check" "nix flake check --all-systems"
run_check "Flake evaluation" "nix eval .#nixosConfigurations --apply builtins.attrNames"

# NixOS configurations
echo -e "${BLUE}=== Building NixOS Configurations ===${NC}"
run_check "ZVIJER build" "nix build .#nixosConfigurations.ZVIJER.config.system.build.toplevel --dry-run"
run_check "T14 build" "nix build .#nixosConfigurations.stefan-t14.config.system.build.toplevel --dry-run"
run_check "StarLabs build" "nix build .#nixosConfigurations.starlabs.config.system.build.toplevel --dry-run"
run_check "Z420 build" "nix build .#nixosConfigurations.z420.config.system.build.toplevel --dry-run"

# Home Manager configurations
echo -e "${BLUE}=== Building Home Manager Configurations ===${NC}"
run_check "stefanmatic@ZVIJER" "nix build .#homeConfigurations.\"stefanmatic@ZVIJER\".activationPackage --dry-run"
run_check "stefanmatic@t14" "nix build .#homeConfigurations.\"stefanmatic@t14\".activationPackage --dry-run"
run_check "stefanmatic@starlabs" "nix build .#homeConfigurations.\"stefanmatic@starlabs\".activationPackage --dry-run"
run_check "stefanmatic" "nix build .#homeConfigurations.stefanmatic.activationPackage --dry-run"

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Validation Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${GREEN}Passed: ${#PASSED_CHECKS[@]}${NC}"
echo -e "${RED}Failed: ${#FAILED_CHECKS[@]}${NC}"
echo ""

if [ ${#FAILED_CHECKS[@]} -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed! Safe to push.${NC}"
    exit 0
else
    echo -e "${RED}✗ The following checks failed:${NC}"
    for check in "${FAILED_CHECKS[@]}"; do
        echo -e "${RED}  - $check${NC}"
    done
    exit 1
fi
