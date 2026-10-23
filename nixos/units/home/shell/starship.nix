# units/home/shell/starship.nix — prompt theme. The wrapper pins its own
# STARSHIP_CONFIG in the store, so Ryoku's materializer cannot overwrite it.
{ inputs, pkgs, ... }:
let
  wrap = inputs.nix-wrapper-modules.wrappers.starship.wrap;
in
{
  home.packages = [
    (wrap {
      inherit pkgs;
      settings = builtins.fromTOML (builtins.readFile ./starship.toml);
    })
  ];
}
