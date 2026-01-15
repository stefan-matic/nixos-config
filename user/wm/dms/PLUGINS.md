# DMS Plugin Management

DankMaterialShell supports plugins, but the current Nix module doesn't have built-in plugin management. Here's how to add plugins manually.

## Plugin Installation Approach

Plugins need to be installed in the DMS configuration directory. You have two options:

### Option 1: Using home.file (Recommended for Nix)

Add plugins via home-manager by fetching from GitHub and placing them in the DMS config:

```nix
{ config, pkgs, lib, inputs, ... }:

{
  home.file = {
    # Example: Docker Manager Plugin
    ".config/dms/plugins/DockerManager".source = pkgs.fetchFromGitHub {
      owner = "LuckShiba";
      repo = "DmsDockerManager";
      rev = "v1.2.0";
      sha256 = "sha256-VoJCaygWnKpv0s0pqTOmzZnPM922qPDMHk4EPcgVnaU=";
    };

    # Example: Another Plugin
    ".config/dms/plugins/AnotherPlugin".source = pkgs.fetchFromGitHub {
      owner = "plugin-author";
      repo = "plugin-repo";
      rev = "v1.0.0";
      sha256 = "sha256-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
    };
  };
}
```

### Option 2: Manual Installation

Clone plugins directly into your DMS config directory:

```bash
cd ~/.config/dms/plugins
git clone https://github.com/LuckShiba/DmsDockerManager DockerManager
```

## Finding Plugins

Check the official DMS plugin repository or community resources:

- [DMS GitHub Discussions](https://github.com/AvengeMedia/DankMaterialShell/discussions)
- [DankLinux Documentation](https://danklinux.com/docs)

## Plugin Configuration

After installing plugins, enable them in DMS settings or configuration files. The exact method depends on how DMS handles plugin loading.

## Future: Declarative Plugin Management

A future enhancement could add a `plugins` option to the dms.nix file:

```nix
programs.dankMaterialShell = {
  enable = true;

  # Hypothetical future syntax (not currently supported)
  plugins = {
    DockerManager = {
      enable = true;
      src = pkgs.fetchFromGitHub { ... };
    };
  };
};
```

This would require extending the DMS Nix module or creating a custom wrapper module.
