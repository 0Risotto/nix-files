# units/home/packages.nix — core user CLI tools
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    git
    nodejs
    pnpm
    gh
    eza
    bat
    fastfetch
    herdr
    lazygit
    just
    fzf
    zoxide
    atuin
  ];
}
