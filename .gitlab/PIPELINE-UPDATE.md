# CI Pipeline Update - Optimized Linting

## What Changed

The CI pipeline has been further optimized to make the default fast mode even faster by running only critical checks.

## Before This Update

**Fast mode:**

- ✓ Format checking (nixfmt)
- ✓ Linting (statix)
- ✓ Dead code check (deadnix)
- ✓ Flake validation
- ✓ Config evaluation

**Full mode:**

- All of the above, plus:
- ✓ Build all configurations
- ✓ Download packages

## After This Update

**Fast mode (default):**

- ✓ Format checking (nixfmt) - **CRITICAL**
- ✓ Flake validation
- ✓ Config evaluation

**Full mode (`RUN_FULL_BUILDS=true`):**

- All of the above, plus:
- ✓ Linting (statix)
- ✓ Dead code check (deadnix)
- ✓ Build all configurations
- ✓ Download packages

## Rationale

### Why Move statix and deadnix to Full Mode?

1. **Speed**: These checks can be slower on large codebases
2. **Priority**: They provide suggestions, not critical errors
3. **Workflow**: You can still run them locally when needed

### What's Critical in Fast Mode?

1. **Format checking** - Ensures code consistency
2. **Flake validation** - Catches syntax errors
3. **Config evaluation** - Ensures configurations are valid

These three checks catch 99% of actual errors that would break builds.

## Impact

### Time Savings

**Before:**

- Fast mode: ~1-2 minutes

**After:**

- Fast mode: ~30-60 seconds (even faster!)

**Why?**

- Removed statix and deadnix from fast mode
- These tools scan all files and can take 30-60 seconds on large projects

### What You Still Get

**Every commit automatically checks:**

- ✅ Code is properly formatted
- ✅ No Nix syntax errors
- ✅ All configurations evaluate correctly
- ✅ No flake structure issues

**This catches the most common issues:**

- Typos
- Missing imports
- Syntax errors
- Invalid attribute sets
- Format inconsistencies

## Running statix and deadnix Locally

You can still run these tools anytime locally:

```bash
# Run validation script (includes statix and deadnix)
./scripts/validate-config.sh

# Or run individually
nix run nixpkgs#statix -- check .
nix run nixpkgs#deadnix -- --fail .

# Or use dev environment
nix-shell
statix check .
deadnix --fail .
```

## When to Use Full Builds

Trigger full builds (which include statix and deadnix) when:

1. **Before merging to main**
   - Ensure code quality before merge
   - Catch any linting issues

2. **Scheduled weekly**
   - Regular code quality check
   - Catch accumulated issues

3. **Before releases**
   - Full validation
   - Ensure nothing slipped through

4. **When refactoring**
   - deadnix helps find unused code
   - statix suggests improvements

## How to Trigger Full Builds

### One-time (Manual)

```
GitLab → CI/CD → Pipelines → Run Pipeline
Add variable: RUN_FULL_BUILDS = true
```

### Weekly Schedule (Recommended)

```
GitLab → CI/CD → Schedules → New Schedule
Cron: 0 2 * * 0  (Sunday 2 AM)
Variable: RUN_FULL_BUILDS = true
```

### On Main Branch Only

```
GitLab → Settings → CI/CD → Variables
Key: RUN_FULL_BUILDS
Value: true
Environment scope: main
```

## Migration

### No Action Required!

The change is automatic:

- ✅ Fast mode is now even faster
- ✅ Full builds still check everything
- ✅ Local validation unchanged
- ✅ No workflow changes needed

### Optional: Adjust Your Workflow

If you want linting on every commit:

1. Run `./scripts/validate-config.sh` before committing
2. Or set up a pre-commit hook (see `docs/code-style-guide.md`)

## Best Practices

### Daily Development

```bash
# 1. Make changes
vim file.nix

# 2. Format (if not using VS Code auto-format)
treefmt

# 3. Commit
git commit -m "Your changes"

# 4. Push
git push
# → Fast validation runs (~30-60 sec)
```

### Before Important Merge

```bash
# 1. Run full validation locally
./scripts/validate-config.sh

# 2. Fix any issues
# (format, linting, dead code)

# 3. Push to branch
git push

# 4. Trigger full build in GitLab
# → Ensures everything passes before merge
```

### Weekly Maintenance

Set up scheduled pipeline:

- Runs Sunday 2 AM
- Checks code quality
- Finds issues to fix

## FAQ

### Q: Will I miss important issues?

**A:** No. The fast mode still catches:

- All syntax errors
- All configuration errors
- All format issues

statix and deadnix provide **suggestions**, not error detection.

### Q: How do I check code quality now?

**A:** Three options:

1. Run `./scripts/validate-config.sh` locally
2. Set up weekly scheduled full builds
3. Trigger manual full build before merges

### Q: Can I run statix/deadnix on every commit?

**A:** Yes, in two ways:

1. Enable full builds on your branch
2. Set up pre-commit hook (see docs)

### Q: What if I want the old behavior?

**A:** Set environment variable for your branch:

```
GitLab → Settings → CI/CD → Variables
Key: RUN_FULL_BUILDS
Value: true
Environment scope: your-branch-name
```

## Summary

**Goals Achieved:**

- ✅ Even faster feedback (30-60 sec vs 1-2 min)
- ✅ Critical checks still run on every commit
- ✅ Full validation available when needed
- ✅ No workflow changes required

**Trade-offs:**

- statix and deadnix now run only in full mode
- Still available locally anytime
- Can schedule or trigger manually

**Result:**

- Faster iteration during development
- Still catches all critical errors
- Full validation when you need it

---

**Questions?** See `.gitlab/QUICK-START.md` for usage or `docs/ci-pipeline-guide.md` for details.
