# assemblies/media.nix — media and entertainment.
{
  nixos = { };

  home = {
    imports = [ ../units/home/media.nix ];
  };
}
