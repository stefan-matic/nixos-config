# CI Pipeline

GitLab CI for validating NixOS configurations.

## Two Modes

| Mode | Trigger | Duration | What It Does |
|------|---------|----------|--------------|
| Fast (default) | Every commit | ~1 min | Syntax, format, evaluation |
| Full | `RUN_FULL_BUILDS=true` | 10-30 min | + linting, builds, downloads |

## Local Validation

```bash
./scripts/validate-config.sh

# Or manually
nix flake check
treefmt
```

## Trigger Full Builds

### One-time
```
GitLab → CI/CD → Pipelines → Run Pipeline
Add variable: RUN_FULL_BUILDS = true
```

### Scheduled (Recommended)
```
GitLab → CI/CD → Schedules → New Schedule
Cron: 0 2 * * 0  (Sunday 2 AM)
Variable: RUN_FULL_BUILDS = true
```

### Main Branch Only
```
GitLab → Settings → CI/CD → Variables
Key: RUN_FULL_BUILDS
Value: true
Environment scope: main
```

## What Gets Checked

**Fast mode:**
- Format (nixfmt)
- Flake validation
- Config evaluation

**Full mode adds:**
- Linting (statix, deadnix)
- Build all NixOS configs
- Build all Home Manager configs
- Download packages

## Adding New Hosts

Add to `.gitlab-ci.yml`:

```yaml
build-newhost:
  stage: build-system
  script:
    - nix build .#nixosConfigurations.newhost.config.system.build.toplevel
```
