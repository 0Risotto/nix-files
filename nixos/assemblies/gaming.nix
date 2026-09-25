# assemblies/gaming.nix — gaming stack.
{
  nixos = { };

  home = {
    imports = [ ../units/home/gaming.nix ];
  };
}
