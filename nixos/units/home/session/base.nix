# Home-manager base unit: session, xdg dirs, home-manager itself.
# username / homeDirectory / stateVersion are set by the caller
# (NixOS: units/nixos/core/home-manager.nix; standalone: flake-modules/hosts.nix).
{ lib, my, ... }:
{
  programs.home-manager.enable = true;

  home.sessionPath = my.constants.session.path;

  home.sessionVariables = my.constants.session.variables // {
    EDITOR = lib.mkDefault "nvim";
    VISUAL = lib.mkDefault "nvim";
  };

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      documents = "$HOME/Documents";
      download = "$HOME/Downloads";
      music = "$HOME/Music";
      pictures = "$HOME/Pictures";
      videos = "$HOME/Videos";
      desktop = "$HOME/Desktop";
      publicShare = "$HOME/Public";
      templates = "$HOME/Templates";
    };
    configFile."user-dirs.dirs".force = true;
  };
}
