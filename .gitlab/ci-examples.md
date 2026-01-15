# GitLab CI Examples

## Running Full Builds

### Quick Start: One-time Full Build

To run a full build (with package downloads) for a single pipeline:

1. Go to your GitLab project
2. Navigate to **CI/CD → Pipelines**
3. Click **Run Pipeline**
4. Select your branch
5. Add variable:
   ```
   Key: RUN_FULL_BUILDS
   Value: true
   ```
6. Click **Run Pipeline**

### Recommended Setup: Weekly Full Builds

Set up a scheduled pipeline to run full builds weekly:

```bash
# In GitLab UI:
# 1. Go to CI/CD → Schedules
# 2. Click "New Schedule"
# 3. Fill in:
#    - Description: "Weekly full build validation"
#    - Interval Pattern: Custom (0 2 * * 0)  # Every Sunday at 2 AM
#    - Target Branch: main
#    - Variables:
#      * RUN_FULL_BUILDS = true
```

This ensures:

- Daily commits: Fast validation only (~1-2 min)
- Weekly: Full package builds to catch any upstream issues

### Branch-Specific Full Builds

To always run full builds on `main` branch only:

1. Go to **Settings → CI/CD → Variables**
2. Click **Add Variable**
3. Configure:
   ```
   Key: RUN_FULL_BUILDS
   Value: true
   Environment scope: main
   ```

Now:

- Commits to `main`: Full builds
- Commits to other branches: Fast validation only

## What Gets Validated

### Default Mode (Fast)

- ✓ Nix syntax checking (nixfmt)
- ✓ Flake structure validation
- ✓ Configuration evaluation (all hosts and home-manager configs)

### Full Build Mode

- ✓ Everything from default mode
- ✓ Anti-pattern detection (statix)
- ✓ Dead code detection (deadnix)
- ✓ Build all NixOS configurations (ZVIJER, T14, StarLabs, Z420)
- ✓ Build all Home Manager configurations
- ✓ Download and compile all packages
- ✓ Verify all dependencies are available

## Pipeline Behavior

### Normal Commit to Feature Branch

```bash
git commit -m "Update package"
git push
# Pipeline runs: ~1-2 minutes (fast validation only)
```

### Release to Main Branch (with scheduled full builds)

```bash
git checkout main
git merge feature-branch
git push
# Pipeline runs: ~1-2 minutes (fast validation)
# Weekly schedule also runs: ~10-30 minutes (full build)
```

### Manual Full Build Verification

```bash
# Before merging important changes
# 1. Push your branch
# 2. Go to GitLab → CI/CD → Pipelines
# 3. Click "Run Pipeline"
# 4. Add RUN_FULL_BUILDS=true
# 5. Verify it passes before merging
```

## Cost Optimization

### CI Minutes Usage

**Fast validation** (default):

- ~1-2 minutes per run
- Minimal compute usage
- Can run on every commit

**Full builds** (optional):

- ~10-30 minutes per run
- Significant compute usage
- Run weekly or before releases

### Recommendations

**For public/hobby projects (limited CI minutes):**

- Default: Fast validation on all commits
- Schedule: Weekly full builds on Sunday
- Total: ~7-14 min/day + 30 min/week = ~80-130 min/week

**For professional projects (unlimited CI minutes):**

- Default: Fast validation on feature branches
- Main branch: Full builds on every commit
- Schedule: Nightly full builds

**For large teams:**

- MRs: Fast validation only
- Main: Full builds after merge
- Schedule: Full builds 2x per week
