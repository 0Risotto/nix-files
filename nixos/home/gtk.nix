{
  config,
  pkgs,
  inputs,
  ...
}:
{
  dconf.enable = true;

  xdg.configFile."gtk-3.0/bookmarks".text = ''
    file://${config.home.homeDirectory}/Documents
    file://${config.home.homeDirectory}/Downloads
    file://${config.home.homeDirectory}/Music
    file://${config.home.homeDirectory}/Pictures
    file://${config.home.homeDirectory}/Videos
    file://${config.home.homeDirectory}/Projects
  '';

  gtk = {
    enable = true;

    theme = {
      name = "Adwaita-dark";
    };

    iconTheme = {
      name = "Flat-Remix-Blue-Dark";
      package = pkgs.flat-remix-icon-theme;
    };

    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 24;
    };

    font.name = "Adwaita Sans 11";

    gtk4.extraCss =
      let
        noctaliaTheme = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
      in
      ''
        @import url("${noctaliaTheme}/share/themes/Noctalia/gtk-4.0/gtk.css");
      '';
  };
}
