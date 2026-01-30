# Devbox Guide

Per-project development environments with automatic activation.

## Quick Start

```bash
cd ~/Workspace/myproject

# Initialize
devbox init

# Add packages
devbox add terraform@1.5.7 nodejs@20 awscli2

# Setup auto-activation
devbox generate direnv
direnv allow

# Now just cd into directory - environment loads automatically
```

## Common Commands

```bash
devbox init              # Initialize project
devbox add <pkg>         # Add package
devbox add <pkg>@1.5.0   # Add specific version
devbox rm <pkg>          # Remove package
devbox shell             # Enter environment manually
devbox search <pkg>      # Find packages
devbox update            # Update packages
```

## Example: Terraform Project

```bash
cd ~/Workspace/terraform-project
devbox init
devbox add terraform@1.5.7 terragrunt@0.50.0 awscli2
devbox generate direnv && direnv allow
```

## Example devbox.json

```json
{
  "packages": ["terraform@1.5.7", "nodejs@20", "awscli2@latest"],
  "shell": {
    "init_hook": ["echo 'Environment loaded!'", "terraform --version"]
  }
}
```

## Multiple Versions

```bash
# Project A: Terraform 1.5
cd ~/Workspace/project-a
devbox add terraform@1.5.7

# Project B: Terraform 1.4
cd ~/Workspace/project-b
devbox add terraform@1.4.0

# Each directory has its own version
```

## Direnv Commands

```bash
direnv allow     # Enable for directory
direnv reload    # Reload after changes
direnv deny      # Disable
```

## Troubleshooting

```bash
# Environment not loading
direnv allow
direnv reload

# Package not found
devbox search terraform

# Slow initialization
devbox config set use_nixos_cache true
```

## Git

Commit these files:

- `devbox.json`
- `devbox.lock`

Ignore:

- `.devbox/`
