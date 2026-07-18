{ inputs, ... }:
{
  flake.nixosModules.system-apps = { pkgs, ... }: {
    programs.firefox.enable = true;
    nixpkgs.config.allowUnfree = true;

    environment.systemPackages = with pkgs; [
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
      nushell
      stow
    ];
  };
}
