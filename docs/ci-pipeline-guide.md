# GitLab CI Pipeline Guide

This document describes the GitLab CI/CD pipeline for validating the NixOS flake configuration.

## Overview

The pipeline validates all NixOS and Home Manager configurations without deploying them. It ensures that:
- All code follows Nix best practices
- No syntax errors exist
- All host configurations can be built
- All Home Manager configurations can be built
- The flake structure is valid

## Pipeline Structure

### Stage 1: Linting (Parallel)
Fast feedback on code quality issues:

- **nix-fmt-check**: Validates Nix code formatting using alejandra or nixpkgs-fmt
- **statix-lint**: Detects Nix anti-patterns and suggests improvements
- **deadnix-check**: Identifies unused/dead Nix code

*Note: All linting jobs allow failure to not block the pipeline on style issues.*

### Stage 2: Validation (Sequential)
Validates flake structure and evaluation:

- **flake-check**: Runs `nix flake check` to validate the entire flake
- **flake-eval**: Ensures all configuration outputs can be evaluated

### Stage 3: Build System Configurations (Parallel)
Builds all NixOS host configurations:

- **build-zvijer**: Gaming/Workstation desktop
- **build-t14**: Lenovo ThinkPad laptop
- **build-starlabs**: StarLabs laptop
- **build-z420**: HP Workstation server
- **build-liveboot**: Live boot configuration (optional)
- **build-liveboot-iso**: ISO image build (optional, can be slow)

### Stage 4: Build Home Manager Configurations (Parallel)
Builds all Home Manager user configurations:

- **build-home-stefanmatic-zvijer**: Host-specific config for ZVIJER
- **build-home-stefanmatic-t14**: Host-specific config for T14
- **build-home-stefanmatic-starlabs**: Host-specific config for StarLabs
- **build-home-stefanmatic**: Generic user config (no host)
- **build-home-fallen**: Secondary user config (optional)

### Stage 5: Summary (.post)
- **validation-summary**: Prints summary of successful validation

## Local Validation

Before pushing to GitLab, run local validation to catch issues early:

```bash
# Run the validation script
./scripts/validate-config.sh

# Or run individual checks manually:
nix flake check
nix build .#nixosConfigurations.ZVIJER.config.system.build.toplevel --dry-run
nix build .#homeConfigurations."stefanmatic@ZVIJER".activationPackage --dry-run
```

The `validate-config.sh` script:
- Mirrors the GitLab CI checks
- Uses `--dry-run` for faster validation
- Provides colored output for easy reading
- Returns exit code 0 on success, 1 on failure

## GitLab Setup

### Prerequisites

1. **GitLab Runner Configuration**:
   - Ensure your GitLab project has runners enabled
   - The pipeline uses the `nixos/nix:latest` Docker image
   - Runners need sufficient disk space (~10GB per build)

2. **CI/CD Variables** (optional):
   - `NIX_BUILD_CORES`: Number of CPU cores for builds (default: 4)

### Enabling the Pipeline

1. Push `.gitlab-ci.yml` to your repository:
```bash
git add .gitlab-ci.yml
git commit -m "Add GitLab CI pipeline for NixOS validation"
git push
```

2. The pipeline will run automatically on:
   - Pushes to `main` branch
   - Merge requests

3. View pipeline status in GitLab:
   - Navigate to CI/CD → Pipelines
   - Click on a pipeline to see job details

## Customization

### Adding New Hosts

When adding a new host configuration, add a corresponding build job:

```yaml
build-newhost:
  stage: build-system
  script:
    - echo "Building NixOS configuration for newhost..."
    - nix build .#nixosConfigurations.newhost.config.system.build.toplevel --show-trace
  only:
    - merge_requests
    - main
```

### Adding New Home Manager Configs

Similarly, add new home-manager configurations:

```yaml
build-home-user-host:
  stage: build-home
  script:
    - echo "Building Home Manager configuration for user@host..."
    - nix build .#homeConfigurations."user@host".activationPackage --show-trace
  only:
    - merge_requests
    - main
```

### Optimizing Build Times

To speed up builds:

1. **Use GitLab CI Cache**: Already configured to cache Nix store
2. **Increase NIX_BUILD_CORES**: Add as CI/CD variable in GitLab settings
3. **Use Binary Cache**: Configure a Nix binary cache (Cachix, Attic, etc.)

Example binary cache setup in `.gitlab-ci.yml`:

```yaml
before_script:
  - nix --version
  - echo "trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= your-cache-key" >> /etc/nix/nix.conf
  - echo "substituters = https://cache.nixos.org https://your-cache.cachix.org" >> /etc/nix/nix.conf
  - nix flake metadata
```

### Strict Mode (Block on Linting)

To fail the pipeline on linting issues, remove `allow_failure: true` from linting jobs:

```yaml
nix-fmt-check:
  stage: lint
  script:
    - nix run nixpkgs#alejandra -- --check .
  # allow_failure: true  # Remove this line
```

## Troubleshooting

### "No space left on device"

- Increase runner disk space
- Add garbage collection to pipeline:
```yaml
after_script:
  - nix-collect-garbage -d
```

### "Flake check fails but local build works"

- Ensure your local and CI Nix versions match
- Check for differences in experimental features
- Review `nix flake metadata` output in CI logs

### "Build times too long"

- Use `--dry-run` for faster validation (doesn't build, just checks)
- Set up a binary cache to avoid rebuilding unchanged packages
- Reduce `NIX_BUILD_CORES` if hitting memory limits

### "Evaluating attribute fails"

- Check for missing inputs in `flake.nix`
- Verify all imported files exist
- Review flake lock file status with `nix flake metadata`

## Best Practices

1. **Run local validation** before pushing to save CI time
2. **Keep flake inputs updated** regularly with `nix flake update`
3. **Review linting suggestions** even if they don't block the pipeline
4. **Test on clean checkout** occasionally to catch missing file references
5. **Document custom packages** in `pkgs/` directory

## References

- [Nix Flakes Manual](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html)
- [GitLab CI/CD Documentation](https://docs.gitlab.com/ee/ci/)
- [NixOS CI/CD Examples](https://github.com/nix-community/infra)
