# assemblies/desktop.nix — Wayland desktop: theme, Ryoku shell, terminals, apps.
{
  nixos = {
    imports = [
      ../units/nixos/desktop/theme.nix
      ../units/nixos/desktop/display-manager.nix
      ../units/nixos/desktop/ryoku.nix
      ../units/nixos/desktop/terminal.nix
      ../units/nixos/desktop/image-search.nix
      ../units/nixos/services/flatpak.nix
    ];

    my.desktop = {
      displayManager = true;
      ryoku = true;
    };
    my.services.flatpak = true;
  };

  home = {
    imports = [
      ../units/home/desktop/desktop-apps.nix
      ../units/home/desktop/ryoku
      ../units/home/desktop/gtk.nix
    ];
  };
}
