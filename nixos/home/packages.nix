{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Editors
    vscode
    zed-editor
    neovim

    # Communication
    discord

    # Terminal tools
    git
    nodejs
    pnpm
    gh
    starship
    eza
    bat
    fastfetch

    # Entertainment
    spotify

    # Media
    vlc
    deluge

    # Gaming
    steam
    gamescope
    gamemode
    heroic
    lutris

    # Productivity
    obsidian

    # VPN
    cloudflare-warp

    # AI
    pi-coding-agent

    #Virtual Machine
    gnome-boxes
  ];
}
