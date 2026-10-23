# assemblies/default.nix — helpers for loading assembly compositions.
# Every assembly file exports { nixos = <module>; home = <module>; }.
let
  # Load assembly files by name (e.g. [ "desktop" "gaming" ]).
  load = names: map (name: import (./. + "/${name}.nix")) names;
in
{
  # System modules every host gets, regardless of selected assemblies.
  baseNixos = [
    ../units/nixos/core/base.nix
    ../units/nixos/core/apps.nix
    ../units/nixos/core/home-manager.nix
    ../units/nixos/hardware/kernel.nix
    ../units/nixos/hardware/filesystems.nix
    ../units/nixos/hardware/memory.nix
    ../units/nixos/hardware/efi.nix
    ../units/nixos/hardware/audio.nix
    ../units/nixos/hardware/nvidia.nix
    ../units/nixos/hardware/intel.nix
    ../units/nixos/hardware/thermal.nix
    ../units/nixos/services/nh.nix
  ];

  # Home modules every user gets, regardless of selected assemblies.
  baseHome = [
    ../units/home/session/base.nix
    ../units/home/shell/cli-packages.nix
    ../units/home/shell/herdr.nix
    ../units/home/shell/starship.nix
  ];

  inherit load;

  nixos = names: map (a: a.nixos) (load names);

  home = names: map (a: a.home or { }) (load names);
}
