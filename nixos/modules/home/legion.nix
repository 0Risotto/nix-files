{ config, pkgs, inputs, settings, lib, ... }:
{
  imports = [
    ./packages.nix
    ./shell.nix
    ./terminal.nix
    ./compositor.nix
  ];
}
