# nixos/ — layered NixOS + home-manager configuration

Dependencies point downward only: `hosts → assemblies → units → options → constants`.
Never import upward.

## Layers

| Layer | Path | Contract |
|---|---|---|
| constants | `constants/shared.nix`, `constants/hosts/<host>.nix` | Pure data. No `config`/`lib`/`pkgs`, no conditionals, no host logic. |
| options | `options/*.nix` | `my.*` option declarations only. One domain per file. No effects. |
| units | `units/{system,hardware,desktop,services,home}/*.nix` | One capability per file. Plain NixOS or HM module. Reads `config.my.*` / `my.*`; never references a host name or imports a sibling unit. |
| assemblies | `assemblies/<name>.nix` | Exports `{ nixos = <module>; home = <module>; }`. Imports units and binds `my.*` flags. Add a file to add a composition. |
| hosts | `hosts/<host>.nix` | Sets `my.host = import ../constants/hosts/<host>.nix` plus machine-only modules. No feature flags. |

- Composition root: `flake-modules/hosts.nix` reads `my.host.assemblies`, loads the matching
  `assemblies/<name>.nix`, and wires the `home` halves into `home-manager.sharedModules`
  (NixOS) / `homeConfiguration` (standalone). Do not reference `config` from a module's
  `imports` — that causes infinite recursion; register modules in the composition root instead.
- Home-manager modules receive `my` via `extraSpecialArgs`.
- Host facts drive defaults: `my.hardware.nvidia` defaults to `my.host.gpu ? nvidiaBusId`,
  `my.desktop.compositors` defaults to `my.host.compositors`.

## Adding things

- **Unit**: create `units/<area>/<name>.nix` as a plain module with a `my.*` gate if optional.
- **Assembly**: create `assemblies/<name>.nix` with `nixos`/`home` attrs, import its units,
  set its flags. Then add the name to `assemblies` in the host's `constants/hosts/<host>.nix`.
- **Host**: run `./bootstrap.sh`; it writes `constants/hosts/<host>.nix` + `hosts/<host>.nix`.

## Commands

```sh
cd nixos
nix fmt                         # treefmt: nixfmt-rfc-style + deadnix
nix run nixpkgs#statix -- check .   # lint (from repo root: -- check ./nixos)
nix flake check                 # eval + formatting check
nix build .#nixosConfigurations.<host>.config.system.build.toplevel --no-link
nix build .#nixosConfigurations.<host>.config.home-manager.users.<user>.home.activationPackage --no-link
sudo nixos-rebuild switch --flake .#<host>   # or: nh os switch
```

Note: Nix flakes only see files tracked by git — `git add` new files before evaluating.

CI (`.github/workflows/ci.yml`): flake check, formatting, statix, host discovery, per-host
toplevel + HM builds, default devshell.
