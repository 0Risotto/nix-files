{ self, inputs, ... }:
{
  flake.nixosModules.flatpak = { config, pkgs, ... }:
  {
    services.flatpak.enable = true;
    
    environment.systemPackages = with pkgs; [
      flatpak
    ];
  };
}
