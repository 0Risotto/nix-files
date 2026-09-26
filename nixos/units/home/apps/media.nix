# units/home/media.nix — media and entertainment
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    spotify
    stremio-linux-shell
    vlc
    qbittorrent
    gthumb
    obs-studio
  ];
}
