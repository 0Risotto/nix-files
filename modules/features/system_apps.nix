{ self, inputs, ... }:
{
  flake.nixosModules.systemApps = { config, pkgs, ... }:
  {
    programs.firefox.enable = true;

    nixpkgs.config.allowUnfree = true;

    environment.systemPackages = with pkgs; [
      zed-editor
      git
      gh
      flat-remix-gtk
      flat-remix-icon-theme
      nwg-look
      adwaita-icon-theme
      neovim
      fish
      starship
      eza
      vscode
      bibata-cursors
      thunderbird
    ];
  };
}