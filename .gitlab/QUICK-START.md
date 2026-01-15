# GitLab CI Quick Start

## TL;DR

**Every commit:** Fast validation only (~1-2 min, no downloads)
**Full builds:** Set `RUN_FULL_BUILDS=true` when needed

## Pipeline Modes

| Mode                | When It Runs                | Duration  | What It Does                       |
| ------------------- | --------------------------- | --------- | ---------------------------------- |
| **Fast** (default)  | Every commit                | 1-2 min   | Syntax, linting, evaluation checks |
| **Full** (optional) | When `RUN_FULL_BUILDS=true` | 10-30 min | Downloads & builds all packages    |

## Quick Actions

### Run Full Build Once

```
GitLab → CI/CD → Pipelines → Run Pipeline
Add variable: RUN_FULL_BUILDS = true
```

### Schedule Weekly Full Builds (Recommended)

```
GitLab → CI/CD → Schedules → New Schedule
Cron: 0 2 * * 0  (Sunday 2 AM)
Variable: RUN_FULL_BUILDS = true
```

### Full Builds on Main Branch Only

```
GitLab → Settings → CI/CD → Variables → Add Variable
Key: RUN_FULL_BUILDS
Value: true
Environment scope: main
```

## What Gets Checked

### ✓ Always (Fast Mode)

- Syntax errors
- Code formatting (alejandra)
- Anti-patterns (statix)
- Dead code (deadnix)
- Flake structure
- Config evaluation

### ✓ When Full Builds Enabled

- All of the above, plus:
- Build ZVIJER config
- Build T14 config
- Build StarLabs config
- Build Z420 config
- Build all Home Manager configs
- Download all packages

## Best Practices

**Development workflow:**

1. Make changes locally
2. Run `./scripts/validate-config.sh` before committing
3. Push to feature branch → Fast validation runs automatically
4. Before merging to main: Trigger one full build to verify

**Production workflow:**

- Feature branches: Fast validation only
- Main branch: Fast validation on commit + scheduled weekly full builds
- Releases: Manual full build before tagging

## Troubleshooting

**Pipeline fails in fast mode?**
→ Fix syntax/evaluation errors, these are critical

**Pipeline passes fast mode but fails in full build?**
→ Package download/build issues, may be upstream problems

**Want faster CI?**
→ Default mode is already optimized, no action needed

**Need to test package changes?**
→ Trigger manual full build with RUN_FULL_BUILDS=true
