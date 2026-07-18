# Standalone home-manager entry point.
# username / homeDirectory / stateVersion are set by the caller
# (NixOS: services/home-manager.nix; standalone: flake.nix inline module).
{ ... }:
{
  programs.home-manager.enable = true;

  imports = [
    ./home/packages.nix
    ./home/compositor.nix
    ./home/gtk.nix
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

  # Per-user state version comes from the caller.
  # For NixOS: config.settings.stateVersion.
  # For standalone: inline module in flake.nix.
}
