# assemblies/desktop.nix — Wayland desktop: theme, compositors, terminals, bar.
{
  nixos = {
    imports = [
      ../units/desktop/theme.nix
      ../units/desktop/display-manager.nix
      ../units/desktop/niri.nix
      ../units/desktop/umbriel.nix
      ../units/desktop/noctalia.nix
      ../units/desktop/fish.nix
      ../units/desktop/kitty.nix
      ../units/desktop/starship.nix
      ../units/desktop/image-search.nix
      ../units/services/flatpak.nix
    ];

    my.desktop = {
      displayManager = true;
      noctalia = true;
    };
    my.services.flatpak = true;
  };

  home = {
    imports = [
      ../units/home/desktop-apps.nix
      ../units/home/umbriel.nix
      ../units/home/gtk.nix
    ];
  };
}
