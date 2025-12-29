# Devbox Development Environments Guide

A comprehensive guide to using Devbox for per-project development environments with automatic activation via direnv.

## Table of Contents
1. [What is Devbox?](#what-is-devbox)
2. [Why Devbox Over Nix Flakes?](#why-devbox-over-nix-flakes)
3. [Basic Setup](#basic-setup)
4. [Creating Project Environments](#creating-project-environments)
5. [Direnv Integration](#direnv-integration)
6. [Common Use Cases](#common-use-cases)
7. [Version Management](#version-management)
8. [Migration from Flakes](#migration-from-flakes)
9. [Advanced Usage](#advanced-usage)
10. [Troubleshooting](#troubleshooting)
11. [Quick Reference](#quick-reference)

---

## What is Devbox?

**Devbox** is a command-line tool that creates isolated, reproducible development environments using Nix packages, but with a much simpler interface than raw Nix.

**Key Features:**
- ✅ **Simple**: No need to write Nix expressions
- ✅ **Per-project**: Different tool versions per directory
- ✅ **Automatic**: Integrates with direnv for auto-activation
- ✅ **Reproducible**: Same environment everywhere
- ✅ **Fast**: Leverages Nix binary cache
- ✅ **Isolated**: Doesn't pollute global environment

**Think of it as:**
- Like `nvm` or `rbenv` but for ALL tools
- Like Docker but without containers
- Like virtual environments but for system packages

---

## Why Devbox Over Nix Flakes?

| Aspect | Nix Flakes | Devbox |
|--------|-----------|--------|
| **Learning Curve** | Steep (Nix language) | Gentle (simple commands) |
| **Configuration** | `flake.nix` (Nix code) | `devbox.json` (simple JSON) |
| **Adding Packages** | Edit Nix code | `devbox add terraform` |
| **Activation** | `nix develop` | `devbox shell` or automatic |
| **Version Pinning** | Manual in flake | `terraform@1.5.0` |
| **Direnv Support** | Manual setup | Built-in |
| **Team Adoption** | Requires Nix knowledge | Easy for anyone |

**Your Current Setup:**
```bash
# Flake-based (manual, complex)
cd ~/Workspace/trustsoft/adcubum
nix develop  # Or nix-shell
```

**With Devbox:**
```bash
# Devbox with direnv (automatic, simple)
cd ~/Workspace/trustsoft/adcubum
# Environment automatically activated!
```

---

## Basic Setup

### Prerequisites

✅ Devbox is already in your home-manager config (`user/packages/development.nix`)
✅ Direnv is already configured (`user/app/direnv/direnv.nix`)

### Verify Installation

```bash
# Check devbox version
devbox version

# Check direnv is working
direnv --version

# Ensure direnv hook is in shell (should be automatic)
echo $DIRENV_DIR
```

### Global Configuration

```bash
# Optional: Configure devbox settings
devbox config set use_nixos_cache true
devbox config set auto_add_envrc true

# View current config
devbox config list
```

---

## Creating Project Environments

### Quick Start: New Project

```bash
# Navigate to your project
cd ~/Workspace/myproject

# Initialize devbox
devbox init

# This creates:
# - devbox.json (package list)
# - devbox.lock (version lock file)

# Add packages
devbox add terraform@1.5.7
devbox add nodejs@20
devbox add python@3.11

# Enter the environment
devbox shell

# Or generate direnv config for auto-activation
devbox generate direnv

# Allow direnv (one-time)
direnv allow
```

### Example: Terraform Project

```bash
cd ~/Workspace/terraform-project

# Initialize with specific terraform version
devbox init
devbox add terraform@1.5.7
devbox add terragrunt@0.50.0
devbox add awscli2

# Generate direnv config
devbox generate direnv
direnv allow

# Now when you cd into this directory:
cd ~/Workspace/terraform-project
# ✅ terraform 1.5.7 is automatically available
terraform --version  # Shows 1.5.7
```

### Example: Node.js Project

```bash
cd ~/Workspace/nextjs-app

devbox init
devbox add nodejs@20.10.0
devbox add yarn@1.22.19

devbox generate direnv
direnv allow

# Automatic activation
cd ~/Workspace/nextjs-app
node --version   # v20.10.0
yarn --version   # 1.22.19
```

---

## Direnv Integration

Direnv automatically loads the devbox environment when you `cd` into a project directory.

### Setup Process

```bash
# 1. Initialize devbox in project
devbox init

# 2. Add packages
devbox add terraform nodejs python

# 3. Generate .envrc file
devbox generate direnv

# This creates .envrc with:
# eval "$(devbox generate direnv --print-envrc)"

# 4. Allow direnv (one-time per project)
direnv allow

# 5. Test it
cd ..
cd back-into-project
# You'll see: "direnv: loading ~/project/.envrc"
```

### Manual .envrc (Alternative)

If you want more control:

```bash
# Create .envrc manually
cat > .envrc << 'EOF'
# Load devbox environment
eval "$(devbox generate direnv --print-envrc)"

# Optional: Additional environment variables
export DATABASE_URL="postgres://localhost/mydb"
export API_KEY="dev-key"

# Optional: Add project bin to PATH
PATH_add ./bin
EOF

# Allow it
direnv allow
```

### Direnv Commands

```bash
# Allow .envrc in current directory
direnv allow

# Reload environment
direnv reload

# Block environment (disable)
direnv deny

# Edit and auto-reload
direnv edit

# Show current status
direnv status
```

---

## Common Use Cases

### Multiple Terraform Versions

**Problem:** Different projects need different Terraform versions.

```bash
# Project A: Terraform 1.5.7
cd ~/Workspace/project-a
devbox init
devbox add terraform@1.5.7
devbox generate direnv && direnv allow

# Project B: Terraform 1.4.0
cd ~/Workspace/project-b
devbox init
devbox add terraform@1.4.0
devbox generate direnv && direnv allow

# Now:
cd ~/Workspace/project-a
terraform --version  # 1.5.7

cd ~/Workspace/project-b
terraform --version  # 1.4.0
```

### Node.js Projects with Different Versions

```bash
# Legacy app: Node 16
cd ~/Workspace/legacy-app
devbox init
devbox add nodejs@16.20.0
devbox add npm@8.19.0
devbox generate direnv && direnv allow

# Modern app: Node 20
cd ~/Workspace/modern-app
devbox init
devbox add nodejs@20.10.0
devbox add pnpm@8.10.0
devbox generate direnv && direnv allow
```

### Python Projects with Virtual Environments

```bash
cd ~/Workspace/python-project
devbox init

# Add Python and tools
devbox add python@3.11
devbox add poetry@1.7.0

# Generate direnv
devbox generate direnv
direnv allow

# Now create venv inside devbox shell
devbox shell
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### Full-Stack Development

```bash
cd ~/Workspace/fullstack-app
devbox init

# Backend
devbox add python@3.11
devbox add poetry@1.7.0
devbox add postgresql@15

# Frontend
devbox add nodejs@20
devbox add pnpm@8

# DevOps
devbox add terraform@1.5.7
devbox add kubectl@1.28

# Database tools
devbox add dbmate
devbox add redis@7

devbox generate direnv && direnv allow
```

---

## Version Management

### Finding Available Versions

```bash
# Search for package versions
devbox search terraform

# More specific search
devbox search "terraform@1.5"

# See all versions of a package
nix search nixpkgs terraform --json | jq -r '.[].version' | sort -V
```

### Pinning Specific Versions

```bash
# Exact version
devbox add terraform@1.5.7

# Latest in major version
devbox add nodejs@20

# Latest version (not recommended)
devbox add python  # Gets latest

# Check what's installed
cat devbox.json
```

### Example devbox.json

```json
{
  "packages": [
    "terraform@1.5.7",
    "nodejs@20.10.0",
    "python@3.11",
    "awscli2@latest"
  ],
  "shell": {
    "init_hook": [
      "echo '🚀 Development environment loaded!'",
      "terraform --version"
    ]
  }
}
```

### Updating Versions

```bash
# Update a package
devbox add terraform@1.6.0  # Replaces old version

# Update all to latest
devbox update

# Check for updates
devbox outdated
```

---

## Migration from Flakes

### Your Current Flake Setup

```nix
# ~/Workspace/trustsoft/adcubum/flake.nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
      buildInputs = with nixpkgs.legacyPackages.x86_64-linux; [
        terraform
        nodejs
        python3
      ];
    };
  };
}
```

### Equivalent Devbox Setup

```bash
cd ~/Workspace/trustsoft/adcubum

# Initialize (creates devbox.json)
devbox init

# Add same packages
devbox add terraform
devbox add nodejs
devbox add python3

# Setup direnv for auto-activation
devbox generate direnv
direnv allow

# Optional: Keep flake.nix for CI/CD, use devbox locally
# Or remove flake.nix entirely
```

### Migration Script

```bash
#!/bin/bash
# migrate-to-devbox.sh

# Backup old flake
mv flake.nix flake.nix.backup
mv flake.lock flake.lock.backup

# Initialize devbox
devbox init

# Add your packages (customize this list)
devbox add terraform@1.5.7
devbox add terragrunt@0.50.0
devbox add nodejs@20
devbox add awscli2

# Setup direnv
devbox generate direnv
direnv allow

echo "✅ Migration complete!"
echo "Old flake backed up to flake.nix.backup"
echo "Test with: devbox shell"
```

### Gradual Migration

Keep both for transition period:

```bash
# Use devbox locally
devbox shell

# Keep flake for CI/CD
nix develop  # Still works

# .envrc can support both
cat > .envrc << 'EOF'
# Try devbox first, fallback to nix develop
if command -v devbox &> /dev/null; then
  eval "$(devbox generate direnv --print-envrc)"
else
  use flake
fi
EOF
```

---

## Advanced Usage

### Custom Shell Initialization

```json
{
  "packages": ["terraform@1.5.7", "nodejs@20"],
  "shell": {
    "init_hook": [
      "echo '🎯 Terraform Project Environment'",
      "echo 'Terraform: $(terraform --version | head -1)'",
      "echo 'Node: $(node --version)'",
      "",
      "# Set project-specific env vars",
      "export TF_VAR_environment=dev",
      "export AWS_PROFILE=dev-account",
      "",
      "# Check for required files",
      "if [ ! -f terraform.tfvars ]; then",
      "  echo '⚠️  Warning: terraform.tfvars not found'",
      "fi"
    ]
  }
}
```

### Services (PostgreSQL, Redis, etc.)

```bash
# Add and run services
devbox add postgresql@15
devbox add redis@7

# Start services
devbox services start postgres
devbox services start redis

# Check status
devbox services status

# Stop services
devbox services stop postgres

# Services auto-start with devbox shell
```

### Scripts in devbox.json

```json
{
  "packages": ["terraform@1.5.7"],
  "shell": {
    "scripts": {
      "plan": "terraform plan -out=tfplan",
      "apply": "terraform apply tfplan",
      "destroy": "terraform destroy",
      "test": "terraform fmt -check && terraform validate"
    }
  }
}
```

```bash
# Run scripts
devbox run plan
devbox run apply
devbox run test
```

### Plugins

```bash
# Add plugins for language-specific features
devbox add go@1.21 --plugin go-modules
devbox add python@3.11 --plugin python-poetry

# Plugins provide additional environment setup
```

---

## Troubleshooting

### Environment Not Loading

```bash
# Check .envrc exists
ls -la .envrc

# Check direnv is allowed
direnv status

# Re-allow direnv
direnv allow

# Reload manually
direnv reload

# Check devbox shell works manually
devbox shell
```

### Package Not Found

```bash
# Search for correct package name
devbox search terraform

# Check available versions
nix search nixpkgs terraform

# Try without version specifier
devbox add terraform  # Gets latest
```

### Conflicting Versions

```bash
# List current packages
cat devbox.json

# Remove old version
devbox rm terraform@1.4.0

# Add new version
devbox add terraform@1.5.7

# Regenerate lock
devbox update
```

### Slow Initialization

```bash
# Enable Nix cache
devbox config set use_nixos_cache true

# Update devbox
nix-env -iA nixpkgs.devbox

# Clear cache if corrupted
rm -rf ~/.cache/devbox
devbox shell  # Rebuilds cache
```

### Direnv Not Working

```bash
# Check direnv hook is in shell config
cat ~/.zshrc | grep direnv

# Should see:
# eval "$(direnv hook zsh)"

# Reload shell
exec $SHELL

# Check direnv version
direnv --version

# Re-allow
direnv allow
```

---

## Best Practices

### 1. Always Pin Versions

```bash
# ✅ Good: Specific version
devbox add terraform@1.5.7

# ⚠️ Risky: Latest version (changes over time)
devbox add terraform
```

### 2. Commit devbox.json and devbox.lock

```bash
# .gitignore
.devbox/
.envrc  # If it contains secrets

# Git add
git add devbox.json devbox.lock
git commit -m "Add devbox configuration"
```

### 3. Document in README

```markdown
## Development Setup

This project uses [Devbox](https://www.jetpack.io/devbox/) for development environment management.

### Prerequisites
- [Nix](https://nixos.org/) (already installed on NixOS)
- [Devbox](https://www.jetpack.io/devbox/docs/installing_devbox/)
- [Direnv](https://direnv.net/)

### Setup
```bash
# Clone repository
git clone ...
cd project

# Allow direnv (one-time)
direnv allow

# Environment automatically loaded!
terraform --version
```
```

### 4. Use Init Hooks for Validation

```json
{
  "packages": ["terraform@1.5.7"],
  "shell": {
    "init_hook": [
      "# Validate terraform configuration",
      "terraform fmt -check || echo '⚠️  Run: terraform fmt'",
      "",
      "# Check for secrets",
      "if git grep -l 'password\\|secret\\|key' *.tf; then",
      "  echo '🚨 Warning: Potential secrets in .tf files'",
      "fi"
    ]
  }
}
```

### 5. Project Templates

Create reusable templates:

```bash
# ~/devbox-templates/terraform/devbox.json
{
  "packages": [
    "terraform@1.5.7",
    "terragrunt@0.50.0",
    "tflint@0.48.0",
    "terraform-docs@0.16.0"
  ],
  "shell": {
    "init_hook": [
      "echo '🏗️  Terraform environment ready'",
      "terraform --version"
    ]
  }
}

# Use template
cp ~/devbox-templates/terraform/devbox.json ~/new-project/
cd ~/new-project
devbox generate direnv && direnv allow
```

---

## Quick Reference

### Essential Commands

```bash
# Initialize project
devbox init

# Add packages
devbox add <package>[@version]

# Remove packages
devbox rm <package>

# Enter shell
devbox shell

# Run command in environment
devbox run <command>

# Update packages
devbox update

# Search packages
devbox search <package>

# List installed packages
devbox list
```

### Direnv Workflow

```bash
# Setup (one-time per project)
devbox generate direnv
direnv allow

# Daily use
cd project  # Environment auto-loads

# Reload after changes
direnv reload
```

### Common Package Versions

```bash
# Terraform
devbox add terraform@1.5.7
devbox add terraform@1.6.0

# Node.js
devbox add nodejs@18.18.0
devbox add nodejs@20.10.0

# Python
devbox add python@3.10
devbox add python@3.11

# Cloud CLIs
devbox add awscli2
devbox add azure-cli
devbox add google-cloud-sdk

# Kubernetes
devbox add kubectl@1.28
devbox add helm@3.13
devbox add k9s
```

### Your Typical Workflow

```bash
# New project
cd ~/Workspace/new-project
devbox init
devbox add terraform@1.5.7 terragrunt@0.50.0 awscli2
devbox generate direnv && direnv allow

# Existing project (first time)
cd ~/Workspace/existing-project
devbox init
# Add packages you need
devbox add terraform@1.4.0  # Match existing version
devbox generate direnv && direnv allow

# Daily work
cd ~/Workspace/project  # Auto-loads environment
terraform plan
```

---

## Real-World Examples

### Example 1: Trustsoft Adcubum Project

```bash
cd ~/Workspace/trustsoft/adcubum

# Replace flake.nix with devbox
devbox init

# Add your tools
devbox add terraform@1.5.7
devbox add terragrunt@0.50.0
devbox add kubectl@1.28
devbox add k9s
devbox add awscli2
devbox add azure-cli

# Setup auto-activation
devbox generate direnv
direnv allow

# Now just cd into directory to get environment
cd ~/Workspace/trustsoft/adcubum
# ✅ All tools available at correct versions
```

### Example 2: Multi-Cloud Infrastructure

```json
{
  "packages": [
    "terraform@1.5.7",
    "terragrunt@0.50.0",
    "awscli2@latest",
    "azure-cli@latest",
    "google-cloud-sdk@latest",
    "kubectl@1.28",
    "helm@3.13",
    "k9s@latest"
  ],
  "shell": {
    "init_hook": [
      "echo '☁️  Multi-Cloud Infrastructure Environment'",
      "echo ''",
      "echo 'Terraform: $(terraform version -json | jq -r .terraform_version)'",
      "echo 'Kubectl: $(kubectl version --client -o json | jq -r .clientVersion.gitVersion)'",
      "echo ''",
      "echo '📋 Available commands:'",
      "echo '  - terraform/terragrunt'",
      "echo '  - aws/az/gcloud CLIs'",
      "echo '  - kubectl/helm/k9s'"
    ]
  }
}
```

### Example 3: Python Data Science

```bash
devbox init
devbox add python@3.11
devbox add poetry@1.7.0
devbox add postgresql@15
devbox add redis@7

# Custom init for Python projects
cat >> devbox.json << 'EOF'
{
  "shell": {
    "init_hook": [
      "# Create venv if it doesn't exist",
      "if [ ! -d .venv ]; then",
      "  echo 'Creating Python virtual environment...'",
      "  python -m venv .venv",
      "  source .venv/bin/activate",
      "  pip install --upgrade pip",
      "  [ -f requirements.txt ] && pip install -r requirements.txt",
      "else",
      "  source .venv/bin/activate",
      "fi"
    ]
  }
}
EOF

devbox generate direnv && direnv allow
```

---

## Integration with Your NixOS Setup

### Current State

In your `user/packages/development.nix`:
```nix
home.packages = with pkgs; [
  devbox        # ✅ Already installed
  direnv        # ✅ Already configured
  nix-direnv    # ✅ Already configured
];
```

### Shell Configuration

Direnv hook is already in your shell config (`user/app/direnv/direnv.nix`):
```nix
programs.direnv = {
  enable = true;
  enableZshIntegration = true;
  nix-direnv.enable = true;
};
```

### Everything is Ready!

You can start using devbox immediately:
```bash
cd ~/Workspace/any-project
devbox init
devbox add terraform@1.5.7
devbox generate direnv && direnv allow
```

---

## Resources

**Official Documentation:**
- https://www.jetpack.io/devbox/docs/
- https://www.jetpack.io/devbox/docs/devbox_examples/

**Search Packages:**
- https://www.nixhub.io/ (Devbox package search)
- https://search.nixos.org/packages

**Community:**
- Devbox Discord: https://discord.gg/agbskTW3
- GitHub: https://github.com/jetpack-io/devbox

**Your Setup:**
- Devbox: `user/packages/development.nix`
- Direnv: `user/app/direnv/direnv.nix`
- This guide: `docs/devbox-guide.md`
