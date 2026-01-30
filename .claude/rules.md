# Claude Development Rules

## Core Principles

1. **No assumptions** - Ask when unclear about requirements or approach
2. **No over-engineering** - Solve the problem, nothing more
3. **Follow existing patterns** - Match how similar things are already done in this repo
4. **No hacks** - Don't work around problems; fix them properly

## Before Implementing

- [ ] Understand the requirement fully (ask if unclear)
- [ ] Check how similar things are done in this codebase
- [ ] For architectural changes: **ask first**

## After Changes

Always run validation:

```bash
# Check config evaluates
nix flake check

# Format code
treefmt

# Test build (for significant changes)
sudo nixos-rebuild build --flake ~/.dotfiles#HOSTNAME
home-manager build --flake ~/.dotfiles#stefanmatic@HOSTNAME
```

## Code Standards

### NixOS Conventions

- Follow [NixOS Wiki](https://nixos.wiki/) patterns
- Follow [nix.dev](https://nix.dev/) best practices
- Use standard option names and module structure
- No anti-patterns (imperative hacks, hardcoded paths, etc.)

### Formatting

- Use `treefmt` or `nixfmt` before completing work
- 2-space indentation
- See `docs/formatting.md`

### Naming

- Hosts: lowercase with hyphens (`dell-micro-3050`)
- Modules: descriptive, match NixOS conventions
- Files: lowercase, hyphens for multi-word (`home-manager.md`)

### Package Placement

- System packages: hardware, monitoring, multi-user tools
- User packages: personal apps, dev tools
- See `docs/package-philosophy.md`

## When to Ask

**Always ask before:**

- Architectural changes
- Changing module structure
- Deviating from existing patterns
- Unclear requirements

**Can proceed without asking:**

- Small changes following existing patterns
- Creating new files that fit existing structure
- Bug fixes with obvious solutions
- Documentation updates

## Don't

- Add features not requested
- Refactor unrelated code
- Add comments/docs unless asked
- Create abstractions for one-time operations
- Use workarounds when proper solutions exist
- Ignore validation errors
