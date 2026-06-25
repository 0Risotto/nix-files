# ❄️ dotties/nixos

A NixOS flake configuration for my **Lenovo Legion** laptop — system settings, home-manager environment, and ephemeral development shells, all in one place.

---

## 📦 Overview

| What | Where |
|------|-------|
| **Entry point** | [`flake.nix`](./flake.nix) |
| **Host configuration** | `modules/hosts/legion/` |
| **System features** | `modules/features/` |
| **Home-manager** | `modules/home/` |
| **Dev shells** | `modules/devshells/` |
| **Settings API** | `modules/settings.nix` |
| **Formatter** | `modules/formatter.nix` |

---

## 🚀 Quick Start

### Build & switch to this configuration

```bash
# Build the system (dry-run)
sudo nixos-rebuild build --flake .

# Switch to the new generation
sudo nixos-rebuild switch --flake .

# Update the flake lock (pin latest inputs)
nix flake update
```

### Enter a development shell

```bash
# Default shell (general CLI tools + fish)
nix develop

# Or use the helper alias (defined in the home-manager fish config):
dev            # same as `nix develop`
dev list       # list available shells
dev web        # single shell
dev web rust   # combine multiple shells
dev all        # everything at once
dev fullstack  # web + rust + go + java + backend
dev data       # python + go
dev cloud      # devops + go
```

---

## 🏗️ Project Structure

```
nixos/
├── flake.nix                        # Top-level flake — pins inputs, imports all modules
├── flake.lock                       # Locked input revisions
├── modules/
│   ├── parts.nix                    # flake-parts system target (x86_64-linux)
│   ├── settings.nix                 # Shared settings option (hostname, secureBoot, users)
│   ├── formatter.nix                # treefmt config (nixfmt + deadnix)
│   ├── hosts/
│   │   ├── default.nix              # Exposes the "legion" NixOS configuration
│   │   └── legion/
│   │       ├── configuration.nix    # Host-level NixOS config (kernel, networking, services)
│   │       ├── hardware.nix         # Hardware detection, filesystems, boot loader
│   │       ├── efi.nix              # Boot: systemd-boot or Lanzaboote (Secure Boot)
│   │       └── nvidia.nix           # NVIDIA Optimus (Prime sync) configuration
│   ├── features/
│   │   ├── display_manager.nix      # SDDM + SilentSDDM theme
│   │   ├── system_apps.nix          # Firefox, Zen Browser, fish, nushell
│   │   ├── appearance_defaults.nix  # Locale, timezone, fonts, GTK themes, cursors
│   │   ├── audio.nix                # PipeWire + ALSA + PulseAudio + JACK
│   │   ├── niri/
│   │   │   └── niri.nix             # Niri compositor + xwayland-satellite
│   │   ├── noctalia.nix             # Noctalia theming system (Cachix substituter)
│   │   └── flatpak.nix              # Flatpak support
│   └── home/
│       ├── default.nix              # Home-manager integration module
│       ├── legion.nix               # Entry point for the "legion" user's home config
│       ├── packages.nix             # User packages (editors, gaming, media, AI tools)
│       ├── shell.nix                # Fish shell config, Starship prompt, `dev` helper
│       ├── terminal.nix             # Kitty terminal emulator config
│       ├── compositor.nix           # Niri compositor files + Noctalia package
│       └── config/
│           └── niri/
│               ├── config.kdl       # Niri main config (includes all sub-files)
│               └── noctalia.kdl     # Noctalia theme overrides for Niri
│   └── devshells/
│       ├── default.nix              # Combines all shells + combo shells (all, fullstack, data, cloud)
│       ├── web.nix                  # TypeScript, Prisma, language servers
│       ├── rust.nix                 # Rustc, Cargo, Clippy, Tauri
│       ├── go.nix                   # Go, gopls, golangci-lint
│       ├── python.nix               # Python, Poetry, Ruff, basedpyright
│       ├── java.nix                 # JDK, Maven, Gradle, Spring Boot
│       ├── devops.nix               # Docker Compose, kubectl, k9s, Ansible, Hetzner CLI
│       └── backend.nix              # Full backend stack (JVM + Go + Rust + Python + DB tools)
```

---

## ⚙️ Configuration Guide

### Settings API (`settings.nix`)

A shared options module exposes a `settings` namespace consumed across the flake:

```nix
settings = {
  hostname    = "legion";          # Hostname of the machine
  secureBoot  = true;              # Toggle Secure Boot / Lanzaboote
  users = {
    <username> = {
      isAdmin    = true;           # Adds wheel + networkmanager groups
      homeModule = ./path/to/home.nix;  # Per-user home-manager module
    };
  };
};
```

### 🔐 Secure Boot

The **EFI** module (`modules/hosts/legion/efi.nix`) handles both boot paths:

- **`settings.secureBoot = false`** → uses plain `systemd-boot`
- **`settings.secureBoot = true`** → enables [Lanzaboote](https://github.com/nix-community/lanzaboote) with `sbctl` for Secure Boot

To enroll Secure Boot keys:

```bash
# Generate keys (once)
sbctl create-keys

# Enroll them into the firmware
sbctl enroll-keys --microsoft

# After switching, verify signed binaries
sudo bootctl status
```

### 🎮 NVIDIA Optimus

The system uses **Prime Sync** (not offload) — the NVIDIA GPU is always on:

- **nvidiaBusId**: `PCI:1:0:0`
- **intelBusId**: `PCI:0:0:0`
- **Render offload** env vars set globally for DRI_PRIME-aware apps

### 🎨 Theming (Noctalia)

[Noctalia](https://github.com/noctalia-dev/noctalia) provides system-wide theming:

1. The **Noctalia flake** is added as an input and its NixOS module is imported
2. A **Cachix binary cache** is configured automatically for pre-built themes
3. The **Noctalia package** is installed via home-manager (`compositor.nix`)
4. Niri's KDL config includes `noctalia.kdl` which overrides colors for focus rings, borders, shadows, tabs, and recent-window highlights
5. Kitty's `extraConfig` includes the Noctalia theme file

### 🖥️ Display Manager

[SDDM](https://github.com/sddm/sddm) is the display manager, themed with [SilentSDDM](https://github.com/uiriansan/SilentSDDM) — a minimal, clean SDDM theme.

### 🎵 Audio

**PipeWire** handles all audio with full compatibility:

- ALSA (with 32-bit support)
- PulseAudio protocol
- JACK
- `rtkit` for real-time priority

### 🐟 Shell & Prompt (fish + starship)

- **Fish** is the default shell with a custom greeting, handy aliases (`dev`, `clear` variants, `ls` → `eza`)
- **Starship** provides a minimal prompt showing: command duration → directory → git branch
- The `dev` function lists, enters, or combines any of the available devshells

### ⌨️ Terminal (Kitty)

Kitty is configured with:

- **JetBrains Mono Nerd Font** at 11pt
- Beam cursor with a trail
- 11px margin, 95% opacity with blur
- Noctalia theme integrated
- `ctrl+f` / `kitty_mod+f` opens a h-split search pane

---

## 💻 Development Shells

All shells drop you into a **Fish** shell automatically.

| Shell | Packages |
|-------|----------|
| `default` | ripgrep, fd, jq, yq, just, nom, nix-tree, delta |
| `web` | TypeScript, tsserver, tailwindcss-language-server, prettierd, eslint_d, Prisma |
| `rust` | rustc, cargo, clippy, rust-analyzer, cargo-tauri, trunk |
| `go` | go, gopls, golangci-lint, gotools |
| `python` | python3, pip, virtualenv, poetry, ruff, basedpyright |
| `java` | jdk, maven, gradle, spring-boot-cli, jdt-language-server |
| `devops` | docker-compose, kubectl, k9s, ansible, hcloud, ssm-session-manager-plugin |
| `backend` | JDK + Maven + Go + Rust + Python + Docker Compose + kubectl + DB tools |

### Combo shells

| Combo | Included |
|-------|----------|
| `all` | Every individual shell |
| `fullstack` | web + rust + go + java + backend |
| `data` | python + go |
| `cloud` | devops + go |

---

## 📦 Notable User Packages

Installed via `modules/home/packages.nix`:

- **Editors**: VS Code, Zed, Neovim
- **Communication**: Discord
- **Gaming**: Steam, gamescope, gamemode, Heroic Games Launcher, Lutris
- **Media**: VLC, Deluge
- **Productivity**: Obsidian
- **VPN**: Cloudflare WARP
- **AI**: [pi-coding-agent](https://github.com/nicdaly/pi)
- **Browsers**: Zen Browser (from flake input), Firefox
- **Theming tools**: nwg-look (GTK settings GUI)

---

## 🔧 Formatting & Linting

### Format with `nix fmt`

```bash
# Format all Nix files in the repo
nix fmt

# Check formatting without writing changes
nix fmt -- --fail-on-change
```

Uses [treefmt-nix](https://github.com/numtide/treefmt-nix) with:

| Tool | What it does |
|------|-------------|
| **nixfmt** | Formats all `.nix` files to RFC 166 style |
| **deadnix** | Removes unused variable bindings and dead code |

### Lint with statix

```bash
# Check for anti-patterns
nix run nixpkgs#statix check .

# Auto-fix where possible
nix run nixpkgs#statix fix .
```

> Both formatting and linting are enforced in CI.

---

## 📥 Updating

```bash
# Update all inputs to latest
nix flake update

# Update a single input
nix flake update nixpkgs

# Apply the new lock
sudo nixos-rebuild switch --flake .
```

---

## 🧹 Useful Commands

```bash
# Garbage collect old generations
sudo nix-collect-garbage -d

# List all generations
sudo nix-env --list-generations -p /nix/var/nix/profiles/system

# Delete generations older than N days
sudo nix-collect-garbage --delete-older-than 30d

# See what changed between generations
nix-diff $(nix eval --raw .#nixosConfigurations.legion.system.build.toplevel) /run/current-system

# Rebuild in case of boot failure (from the booted generation)
sudo nixos-rebuild switch --flake .#legion
```

---

## 🗺️ Roadmap / Ideas

- [ ] Add more host configurations (desktop, server)
- [ ] Secrets management (sops-nix / agenix)
- [ ] CI flake check
- [ ] Declarative Flatpak packages

---

## 📝 License

MIT — do what you want with it.
