{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Editors
    zed-editor
    typst
    tinymist

    # Communication
    signal-desktop
    (discord.override {
      withVencord = true;
    })
    # Terminal tools
    git
    nodejs
    pnpm
    gh
    eza
    bat
    fastfetch
    herdr
    lazygit

    # Entertainment
    spotify
    stremio-linux-shell

    # Media
    vlc
    qbittorrent
    gthumb

    # Gaming
    steam
    gamescope
    gamemode
    heroic
    lutris
    pcsx2

    # Productivity
    obsidian

    # VPN
    cloudflare-warp

    # AI
    pi-coding-agent
    opencode

    #Virtual Machine
    gnome-boxes
  ];
}
