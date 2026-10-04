# units/home/packages.nix — core user CLI tools
{ pkgs, ... }:
let
  # Opt-in rounded corners for herdr 0.9.1 (ui.border_style = "rounded").
  # Drop this override once upstream support lands:
  # https://github.com/herdrdev/herdr/discussions/2097
  herdr = pkgs.herdr.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./herdr/rounded-borders.patch ];
  });
in
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
  ];
}
