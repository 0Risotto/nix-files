# assemblies/default.nix — helpers for loading assembly compositions.
# Every assembly file exports { nixos = <module>; home = <module>; }.
let
  # Load assembly files by name (e.g. [ "desktop" "gaming" ]).
  load = names: map (name: import (./. + "/${name}.nix")) names;
in
{
  # Home modules every user gets, regardless of selected assemblies.
  baseHome = [
    ../units/home/base.nix
    ../units/home/packages.nix
  ];

  inherit load;

  nixos = names: map (a: a.nixos) (load names);

  home = names: map (a: a.home or { }) (load names);
}
