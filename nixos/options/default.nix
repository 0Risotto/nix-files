# options/default.nix — the my.* configuration surface.
{
  imports = [
    ./constants.nix
    ./system.nix
    ./hardware.nix
    ./desktop.nix
    ./services.nix
  ];
}
