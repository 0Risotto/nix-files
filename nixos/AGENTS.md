# nixos/ — layered NixOS + home-manager configuration

Dependencies point downward only: `hosts → assemblies → units → (lib, options) → constants`.
Never import upward.

## Layers

| Layer | Path | Contract |
|---|---|---|
| constants | `constants/shared.nix`, `constants/hosts/<host>.nix` | Pure data. No `config`/`lib`/`pkgs`, no conditionals, no host logic. |
| lib | `lib/keybinds.nix` | Pure data + render functions, no `config`/`pkgs`. Imported directly by units (`import ../../../../lib/…`). |
| options | `options/*.nix` | `my.*` option declarations only. One domain per file. No effects. |
| units | `units/nixos/{core,hardware,desktop,shell,services}/*.nix`, `units/home/{session,shell,desktop,editors,apps}/*.nix` | One capability per file. Plain NixOS or HM module; `nixos/` is system, `home/` is home-manager. Reads `config.my.*` / `my.*`; never references a host name or imports a sibling unit. A unit may be a directory with a `default.nix` plus its own data files (`units/home/desktop/ryoku/`). |
| assemblies | `assemblies/<name>.nix` | Exports `{ nixos = <module>; home = <module>; }`. Imports units and binds `my.*` flags. Add a file to add a composition. `assemblies/default.nix` holds `baseNixos`/`baseHome`, the always-on units. |
| hosts | `hosts/<host>.nix` | Sets `my.host = import ../constants/hosts/<host>.nix` plus machine-only modules. No feature flags. |

- Composition root: `flake-modules/hosts.nix` reads `my.host.assemblies`, loads the matching
  `assemblies/<name>.nix`, and wires the `home` halves into `home-manager.sharedModules`
  (NixOS) / `homeConfiguration` (standalone). Do not reference `config` from a module's
  `imports` — that causes infinite recursion; register modules in the composition root instead.
- Home-manager modules receive `my` via `extraSpecialArgs`.
- Host facts drive defaults: `my.hardware.nvidia` defaults to `my.host.gpu ? nvidiaBusId`.
- Display names are host facts (`my.host.displays.primary`/`.secondary`), not literals inside
  unit config.
- The desktop assembly composes **Ryoku on niri** (`units/nixos/desktop/ryoku.nix`, gated by
  `my.desktop.ryoku`). Host overrides live in `units/home/desktop/ryoku/`: static KDL/Lua/fish
  files next to `default.nix`, which substitutes the few host facts (`replaceVars`) and writes
  them to `~/.config/niri/user.kdl`, `~/.config/niri/monitors_user.kdl`,
  `~/.config/hypr/user.lua` and `~/.config/fish/user.fish`. Ryoku's materializer seeds those
  files only when absent; `user.kdl`/`user.lua` are loaded last so their values win.
- **Keybinds live in `lib/keybinds.nix`**, one row per chord with both the niri action and the
  Hyprland expression. `units/home/desktop/ryoku/default.nix` renders that table to
  `niri-binds.kdl` (included by `user.kdl`) and `hypr-binds.lua` (`dofile`'d by `user.lua`).
  Never hand-write binds in the `.kdl`/`.lua` files.

## Adding things

- **Unit**: create `units/nixos/<area>/<name>.nix` (system) or `units/home/<area>/<name>.nix` (home-manager) as a plain module with a `my.*` gate if optional.
- **Assembly**: create `assemblies/<name>.nix` with `nixos`/`home` attrs, import its units,
  set its flags. Then add the name to `assemblies` in the host's `constants/hosts/<host>.nix`.
- **Base unit** (needed by every host): add it to `baseNixos`/`baseHome` in `assemblies/default.nix`.
- **Keybind**: add one row to `lib/keybinds.nix`; set `niriChord`/`niriAction` and/or
  `hyprChord`/`hyprAction` (`hyprAction = null` unbinds a shipped chord). No other file changes.
- **Host fact**: add the field to both the `my.host` schema in `options/constants.nix` and
  `constants/hosts/<host>.nix` (same for `my.constants`), then read it via `my.host.*`.
- **Host**: run `./bootstrap.sh`; it writes `constants/hosts/<host>.nix` + `hosts/<host>.nix`.

## Commands

```sh
cd nixos
nix fmt                         # treefmt: nixfmt + deadnix
nix run nixpkgs#statix -- check .   # lint (from repo root: -- check ./nixos)
nix flake check                 # eval + formatting check
nix build .#nixosConfigurations.<host>.config.system.build.toplevel --no-link
nix build .#nixosConfigurations.<host>.config.home-manager.users.<user>.home.activationPackage --no-link
sudo nixos-rebuild switch --flake .#<host>   # or: nh os switch
```

Note: Nix flakes only see files tracked by git — `git add` new files before evaluating.

CI (`.github/workflows/ci.yml`): flake check, formatting, statix, host discovery, per-host
toplevel + HM builds, default devshell.
