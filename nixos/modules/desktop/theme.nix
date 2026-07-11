# modules/theme.nix — fonts, icons, cursors, GTK theme
_: {
  flake.nixosModules.theme = { pkgs, ... }: {
    fonts = {
      packages = with pkgs; [
        inter
        roboto
        roboto-mono
        noto-fonts
        noto-fonts-color-emoji
        liberation_ttf
        nerd-fonts.jetbrains-mono
      ];

      fontconfig.defaultFonts = {
        sansSerif = [ "Inter" ];
        monospace = [ "Roboto Mono" ];
        serif = [ "Noto Serif" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };

    environment.systemPackages = with pkgs; [
      flat-remix-icon-theme
      bibata-cursors
    ];
  };
}
