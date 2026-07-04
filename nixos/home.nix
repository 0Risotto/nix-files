{ config, pkgs, inputs, ... }:
let
  username = "legion";
  homeDirectory = "/home/${username}";
in
{
  home = {
    inherit username homeDirectory;
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;

  # ── Import shared modules from the home/ directory ────────────
  imports = [
    ./home/packages.nix
    ./home/compositor.nix
  ];

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.npm-global/bin"
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER = "less";
    NIXPKGS_ALLOW_UNFREE = "1";
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
