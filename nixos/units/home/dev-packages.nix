# units/home/dev-packages.nix — development applications
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    zed-editor
    typst
    tinymist
    obsidian
    pi-coding-agent
    opencode
  ];
}
