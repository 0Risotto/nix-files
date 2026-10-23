# units/nixos/core/apps.nix — baseline system applications
{ pkgs, ... }:
{
  programs.firefox.enable = true;
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    nushell
    stow
  ];
}
