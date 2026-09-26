# units/home/apps/dev-packages.nix — development applications
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    typst
    tinymist
    obsidian
    pi-coding-agent
    opencode
  ];
}
