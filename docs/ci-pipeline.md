# CI Pipeline Guide

GitLab CI for validating NixOS configurations.

## Two Modes

### Default (Fast) - Every Commit

- Syntax checking
- Flake validation
- Configuration evaluation
- ~1-2 minutes, no downloads

### Full Build - On Demand

- Everything above + actual builds
- Downloads all packages
- 10-30+ minutes
- Trigger: Set `RUN_FULL_BUILDS=true`

## Local Validation

```bash
# Run validation script
./scripts/validate-config.sh

# Or manually
nix flake check
nix build .#nixosConfigurations.ZVIJER.config.system.build.toplevel --dry-run
```

## Trigger Full Builds

### One-time (GitLab UI)

1. CI/CD → Pipelines → Run Pipeline
2. Add variable: `RUN_FULL_BUILDS` = `true`

### Scheduled (Recommended)

1. CI/CD → Schedules → New Schedule
2. Set weekly schedule
3. Add variable: `RUN_FULL_BUILDS` = `true`

## Adding New Hosts

Add to `.gitlab-ci.yml`:

```yaml
build-newhost:
  stage: build-system
  script:
    - nix build .#nixosConfigurations.newhost.config.system.build.toplevel --show-trace
```

## Troubleshooting

```bash
# "Flake check fails locally but works in CI"
nix flake metadata  # Check versions match

# "Build times too long"
# Use --dry-run for validation only
# Set up binary cache (Cachix)
```
