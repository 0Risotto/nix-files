# assemblies/desktop.nix — Wayland desktop: theme, compositors, terminals, bar.
{
  nixos = {
    imports = [
      ../units/nixos/desktop/theme.nix
      ../units/nixos/desktop/display-manager.nix
      ../units/nixos/desktop/niri.nix
      ../units/nixos/desktop/umbriel.nix
      ../units/nixos/desktop/noctalia.nix
      ../units/nixos/shell/fish.nix
      ../units/nixos/shell/kitty.nix
      ../units/nixos/shell/starship.nix
      ../units/nixos/desktop/image-search.nix
      ../units/nixos/services/flatpak.nix
    ];

    my.desktop = {
      displayManager = true;
      noctalia = true;
    };
    my.services.flatpak = true;
  };

  home = {
    imports = [
      ../units/home/desktop/desktop-apps.nix
      ../units/home/desktop/umbriel.nix
      ../units/home/desktop/gtk.nix
    ];
  };
}
