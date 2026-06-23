{ self, inputs, ... }:
{
  flake.nixosModules.systemApps = { config, pkgs, ... }:
  {
    programs.firefox.enable = true;

    nixpkgs.config.allowUnfree = true;
    
    environment.systemPackages = with pkgs; [
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
      #editors
      vscode
      zed-editor
      vesktop
      #terminal stuff
      git
      gh

      starship
      eza
      bat
      # I hated adding this
      fastfetch
      fish
      nushell

      #themes and icons
      flat-remix-gtk
      flat-remix-icon-theme
      nwg-look

      #editors
      neovim
    ];
  };
}
