# macOS Setup (nix-darwin)

The `macbook` host is an Apple Silicon MacBook Pro managed by
[nix-darwin](https://github.com/nix-darwin/nix-darwin) instead of NixOS. It
shares the shell, editor, terminal, language and CLI tooling with the NixOS
hosts and replaces the linux-only desktop stack with macOS equivalents.

## Bootstrap

Nix is not installed by default on macOS. These steps run once.

```bash
# 1. Install nix (upstream multi-user installer)
sh <(curl -L https://nixos.org/nix/install)

# Open a new shell so /nix/var/nix/profiles/default/bin is on PATH
exec zsh -l

# 2. Homebrew must already exist - nix-darwin drives it but does not install it
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew update   # required: a stale brew can't parse current cask definitions

# 3. Clone the flake
git clone git@gitlab.com:stefan-matic/nixos-config.git ~/.dotfiles

# 4. First build. nix-darwin is not installed yet, so run it from the flake.
nix run nix-darwin -- switch --flake ~/.dotfiles#macbook
```

After the first switch, `darwin-rebuild` is on PATH:

```bash
darwin-rebuild switch --flake ~/.dotfiles#macbook
```

> **Determinate Systems installer**: if you install nix with `determinate-nixd`
> instead of the upstream installer, set `nix.enable = false;` in
> `hosts/_common/darwin.nix` — nix-darwin refuses to manage a nix install it
> doesn't own.

## Manual steps nix cannot do

macOS gates several things behind a human clicking in System Settings. None of
these can be declared in nix.

| What                       | Where                                                       |
| -------------------------- | ----------------------------------------------------------- |
| Paneru window control      | Privacy & Security → Accessibility → enable `paneru`          |
| Shottr screenshots         | Privacy & Security → Screen Recording                         |
| Espanso text expansion     | Privacy & Security → Accessibility + Input Monitoring         |
| Karabiner key remapping    | Privacy & Security → Input Monitoring                         |
| Raycast hotkey             | Raycast settings → set the launcher hotkey to `alt+space`     |

Paneru also needs **Displays have separate spaces** left enabled; that is what
`system.defaults.spaces.spans-displays = false` in `hosts/_common/darwin.nix`
enforces.

Paneru is a per-user launchd agent (it has to live in the Aqua session to hold
Accessibility permission). Restart it after granting the permission:

```bash
# Find the label - home-manager agents are org.nix-community.home.<name>,
# paneru's own darwin module uses com.github.karinushka.paneru
launchctl list | grep -i paneru

launchctl kickstart -k "gui/$(id -u)/<label>"
```

Default browser is a Launch Services mapping, not an env var. Set it once:

```bash
duti -s com.google.Chrome public.html  all
duti -s com.google.Chrome public.url   all
```

## Architecture

The flake is multi-platform as of the macbook host. `systems` stays linux-only
because `./pkgs` contains niri/wayland/steam helpers that have no darwin build;
darwin is reached exclusively through `darwinConfigurations`.

```
flake.nix
├── nixosConfigurations.*          # ZVIJER, stefan-t14, starlabs, z420, ...
└── darwinConfigurations.macbook   # this host

hosts/
├── _common/
│   ├── default.nix                # all NixOS hosts
│   ├── client.nix                 # NixOS desktops
│   └── darwin.nix                 # all darwin hosts  <-- new
└── macbook/
    ├── configuration.nix
    ├── env.nix
    ├── packages.nix               # system packages (tiny on darwin)
    └── homebrew.nix               # GUI apps as casks

home/
├── _core.nix                      # cross-platform base  <-- new
├── _common.nix                    # _core + linux-only modules
├── stefanmatic.nix                # NixOS user config
└── darwin.nix                     # _core + darwin modules  <-- new

user/wm/
├── niri/                          # linux compositor
└── paneru/                        # macOS window manager  <-- new
    ├── common.nix                 # shared keymap + look
    └── macbook.nix                # host config
```

`hosts/_common/darwin.nix` is the darwin analogue of `default.nix` +
`client.nix`. It cannot import either — both pull in NixOS-only modules
(udev, networkmanager, systemd, niri, plasma). What it does reproduce is the
policy rather than the platform: the four-channel overlay stack, nix settings,
GC, fonts and home-manager wiring.

## What ported, what was replaced

### Shared unchanged

zsh + oh-my-zsh + powerlevel10k and every alias/function (`ws`, `wr`, `awsp`,
`cd -N`, `phone`), git, neovim + all LSPs, direnv, yazi, taskwarrior, the
go/node/python/rust setups, the modern CLI suite, and most of
`user/packages/development.nix` — kubectl, helm, k9s, argocd, terraform,
terragrunt, ansible, awscli2, azure-cli, gcloud, gh, glab, vault, infisical,
gitleaks, claude-code, codex, opencode.

The `stable` / `unstable` / `fast-track` / `bleeding-edge` overlays work
verbatim on `aarch64-darwin`.

### Ported with a darwin variant

| Module                            | Change                                                              |
| --------------------------------- | ------------------------------------------------------------------- |
| `user/app/terminal/tmux.nix`       | Status scripts reimplemented against `sysctl`/`vm_stat`/`pmset`/`networksetup` — macOS has no procfs. No CPU temp: Apple Silicon only exposes it via `powermetrics`, which needs root. Clipboard yank uses `pbcopy`. |
| `user/app/terminal/ghostty.nix`    | `package = null` on darwin; the app is the `ghostty` cask, home-manager still writes the config. |
| `user/app/terminal/yazi.nix`       | `xdg-open` → `open`; f3d 3D previews are linux-only.                 |
| `user/app/neovim/default.nix`      | `clang` instead of `gcc` for treesitter grammars.                    |
| `user/shells/sh.nix`               | `ueberzugpp` dropped — Ghostty speaks the kitty graphics protocol natively on macOS. |
| `user/packages/development.nix`    | Linux-only entries split behind `lib.optionals`.                     |
| fast-track / bleeding-edge updates | `systemd.user.services` → `launchd.agents` (`user/app/flake-update-darwin.nix`). |
| YubiKey touch-to-sudo              | → Touch ID (`security.pam.services.sudo_local.touchIdAuth`).         |
| gpg pinentry                       | `pinentry-gnome3` → `pinentry_mac`, configured by file since home-manager's `services.gpg-agent` is systemd-only. |

### Replaced

| Linux                       | macOS                                             |
| --------------------------- | -------------------------------------------------- |
| niri                        | paneru (`user/wm/paneru/`)                          |
| DMS spotlight (Mod+Space)   | Raycast                                             |
| DMS status widgets          | Stats (menu bar)                                    |
| grim + slurp + swappy       | macOS `screencapture` + Shottr                      |
| input-remapper              | Karabiner-Elements                                  |
| `xdg.mimeApps`/select-browser | Launch Services via `duti`                        |
| espanso-wayland             | espanso cask                                        |
| GUI apps from nixpkgs       | Homebrew casks (`hosts/macbook/homebrew.nix`)       |

### Dropped

NVIDIA, OpenRazer, OpenRGB, Steam/gamescope/gamemode, udev rules, greetd/SDDM,
Plasma 6, xdg-desktop-portal, k3s, NixOS firewall, printers, and all of
`user/packages/gaming.nix` and `creative.nix`.

## Paneru

Paneru puts windows on an infinite horizontal strip and never resizes existing
windows when a new one opens — the same model as niri. `user/wm/paneru/common.nix`
carries the shared keymap, gaps and decorations; `macbook.nix` adds only the
per-host window rules, the same split as `user/wm/niri/`.

`alt` (Option) stands in for niri's Mod. `cmd` is unusable: `cmd+q/h/w/t` and
`cmd+1..5` are load-bearing macOS and browser shortcuts.

| niri                            | paneru                          | key               |
| ------------------------------- | ------------------------------- | ----------------- |
| `focus-column-left/right`       | `window_focus_west/east`        | `alt - h` / `l`   |
| `focus-window-down/up`          | `window_focus_south/north`      | `alt - j` / `k`   |
| `move-column-left/right`        | `window_swap_west/east`         | `alt+shift - h/l` |
| `switch-preset-column-width`    | `window_resize`                 | `alt+shift - r`   |
| `maximize-column`               | `window_fullwidth`              | `alt - f`         |
| `consume-or-expel-window-left`  | `window_stack`                  | `alt - [`         |
| `consume-or-expel-window-right` | `window_unstack`                | `alt - ]`         |
| `toggle-window-floating`        | `window_manage`                 | `alt+shift - space` |
| `focus-workspace 1..5`          | `window_virtualnum_1..5`        | `alt - 1..5`      |
| `move-column-to-workspace 1..5` | `window_virtualmovenum_1..5`    | `alt+shift - 1..5` |
| `quit`                          | `quit`                          | `ctrl+alt - q`    |

**Not translatable**: paneru's TOML bindings drive window commands only — they
cannot spawn applications, so niri's `Mod+Return` → ghostty and `Mod+E` →
dolphin have no equivalent. Raycast covers launching. Paneru does support Lua
scripting (`services.paneru.config`) if binding a shell command becomes
necessary.

Window rules match on a required `title` regex plus an optional `bundle_id`.
Find an app's bundle id with:

```bash
osascript -e 'id of app "Slack"'
```

## Validation

```bash
# On the mac
./scripts/validate-config.sh          # skips the NixOS hosts automatically
nix build .#darwinConfigurations.macbook.system --dry-run

# Format before committing - CI gates on nixfmt
treefmt
```

GitLab CI runs on linux runners and cannot evaluate `darwinConfigurations`;
the darwin host is only checked locally.
