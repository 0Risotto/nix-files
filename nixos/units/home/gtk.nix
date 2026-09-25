{
  config,
  my,
  pkgs,
  ...
}:
let
  theme = my.constants.theme;
in
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
      name = theme.gtk.theme;
    };

    iconTheme = {
      name = theme.icons.name;
      package = pkgs.flat-remix-icon-theme;
    };

    cursorTheme = {
      name = theme.cursor.name;
      package = pkgs.bibata-cursors;
      size = theme.cursor.size;
    };

    font.name = theme.fonts.gtk;
  };
}
