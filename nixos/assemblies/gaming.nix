# assemblies/gaming.nix — gaming stack.
{
  nixos = {
    programs.steam.enable = true;
    programs.gamemode.enable = true;
    hardware.steam-hardware.enable = true;
  };

  home = {
    imports = [ ../units/home/gaming.nix ];
  };
}
