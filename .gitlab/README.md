# GitLab CI Documentation

This directory contains documentation and examples for the NixOS flake CI/CD pipeline.

## 📚 Documentation Index

### Start Here
- **[QUICK-START.md](QUICK-START.md)** - Quick reference guide (START HERE!)
  - Pipeline modes overview
  - Common actions (run full builds, schedules, etc.)
  - Best practices cheatsheet

### Detailed Guides
- **[ci-examples.md](ci-examples.md)** - Comprehensive examples
  - Step-by-step instructions for all use cases
  - Cost optimization strategies
  - Workflow recommendations

- **[CHANGES.md](CHANGES.md)** - What changed in this version
  - Before/after comparison
  - Migration guide
  - Benefits and savings

- **[../docs/ci-pipeline-guide.md](../docs/ci-pipeline-guide.md)** - Complete reference
  - Technical deep dive
  - Pipeline architecture
  - Troubleshooting

## 🚀 Quick Actions

### Run Full Build (One-time)
```
GitLab → CI/CD → Pipelines → Run Pipeline
Add: RUN_FULL_BUILDS = true
```

### Schedule Weekly Full Builds
```
GitLab → CI/CD → Schedules → New Schedule
Cron: 0 2 * * 0
Variable: RUN_FULL_BUILDS = true
```

### Local Validation
```bash
cd ~/.dotfiles
./scripts/validate-config.sh
```

## 📊 Pipeline Overview

```
┌─────────────────────────────────────────────────┐
│           Every Commit (Default)                │
│  ✓ Syntax checks (1-2 min, no downloads)       │
│  ✓ Linting and validation                      │
│  ✓ Configuration evaluation                    │
└─────────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────┐
│     When RUN_FULL_BUILDS=true (Optional)       │
│  ✓ Everything above, plus:                     │
│  ✓ Build all NixOS configs (10-30 min)         │
│  ✓ Build all Home Manager configs              │
│  ✓ Download all packages                       │
└─────────────────────────────────────────────────┘
```

## 🎯 Recommended Setup

**For most projects:**
- Default: Fast validation on all commits
- Schedule: Weekly full builds (Sunday 2 AM)
- Manual: Full build before releases

**Cost savings:**
- Time: ~90% faster (1-2 min vs 10-30 min)
- Bandwidth: ~95% less (50 MB vs 5-10 GB)
- CI minutes: ~85% savings

## 📁 File Structure

```
.gitlab/
├── README.md           # This file
├── QUICK-START.md      # Quick reference (start here!)
├── ci-examples.md      # Detailed examples
└── CHANGES.md          # What changed in this version

../.gitlab-ci.yml       # Main CI configuration
../docs/
└── ci-pipeline-guide.md # Complete technical guide

../scripts/
└── validate-config.sh  # Local validation script
```

## 🆘 Need Help?

1. **Quick answer**: Check [QUICK-START.md](QUICK-START.md)
2. **Examples**: See [ci-examples.md](ci-examples.md)
3. **Technical details**: Read [../docs/ci-pipeline-guide.md](../docs/ci-pipeline-guide.md)
4. **What changed**: Review [CHANGES.md](CHANGES.md)

## 🔗 Related Documentation

- [../CLAUDE.md](../CLAUDE.md) - Main project documentation
- [../docs/home-manager-guide.md](../docs/home-manager-guide.md) - Home Manager operations
- [../docs/nixos-vs-home-manager-guide.md](../docs/nixos-vs-home-manager-guide.md) - Package placement philosophy
