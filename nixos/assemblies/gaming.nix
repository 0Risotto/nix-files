# assemblies/gaming.nix — gaming stack.
{
  nixos = {
    imports = [
      ../units/nixos/services/scx.nix
    ];

    my.services.scx = true;

    programs.steam.enable = true;
    programs.gamemode.enable = true;
    hardware.steam-hardware.enable = true;
  };

  home = {
    imports = [
      ../units/home/apps/gaming.nix
    ];
  };
}
