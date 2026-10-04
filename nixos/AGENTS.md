# nixos/ — layered NixOS + home-manager configuration

Dependencies point downward only: `hosts → assemblies → units → options → constants`.
Never import upward.

## Layers

| Layer | Path | Contract |
|---|---|---|
| constants | `constants/shared.nix`, `constants/hosts/<host>.nix` | Pure data. No `config`/`lib`/`pkgs`, no conditionals, no host logic. |
| options | `options/*.nix` | `my.*` option declarations only. One domain per file. No effects. |
| units | `units/nixos/{core,hardware,desktop,shell,services}/*.nix`, `units/home/{session,shell,desktop,editors,apps}/*.nix` | One capability per file. Plain NixOS or HM module; `nixos/` is system, `home/` is home-manager. Reads `config.my.*` / `my.*`; never references a host name or imports a sibling unit. |
| assemblies | `assemblies/<name>.nix` | Exports `{ nixos = <module>; home = <module>; }`. Imports units and binds `my.*` flags. Add a file to add a composition. |
| hosts | `hosts/<host>.nix` | Sets `my.host = import ../constants/hosts/<host>.nix` plus machine-only modules. No feature flags. |

- Composition root: `flake-modules/hosts.nix` reads `my.host.assemblies`, loads the matching
  `assemblies/<name>.nix`, and wires the `home` halves into `home-manager.sharedModules`
  (NixOS) / `homeConfiguration` (standalone). Do not reference `config` from a module's
  `imports` — that causes infinite recursion; register modules in the composition root instead.
- Home-manager modules receive `my` via `extraSpecialArgs`.
- Host facts drive defaults: `my.hardware.nvidia` defaults to `my.host.gpu ? nvidiaBusId`.
- The desktop assembly composes **Ryoku on niri** (`units/nixos/desktop/ryoku.nix`, gated by
  `my.desktop.ryoku`). Host niri overrides live in `units/home/desktop/ryoku.nix`, which
  home-manager writes to `~/.config/niri/user.kdl` (binds, input) and
  `~/.config/niri/monitors_user.kdl` (outputs); Ryoku's materializer seeds those files only
  when absent, and `user.kdl` is included last so its binds win.

## Adding things

- **Unit**: create `units/nixos/<area>/<name>.nix` (system) or `units/home/<area>/<name>.nix` (home-manager) as a plain module with a `my.*` gate if optional.
- **Assembly**: create `assemblies/<name>.nix` with `nixos`/`home` attrs, import its units,
  set its flags. Then add the name to `assemblies` in the host's `constants/hosts/<host>.nix`.
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
