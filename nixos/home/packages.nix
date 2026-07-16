{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Editors
    vscode
    zed-editor
    neovim

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
    starship
    eza
    bat
    fastfetch
    herdr

    # Entertainment
    spotify

    # Media
    vlc
    qbittorrent

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
