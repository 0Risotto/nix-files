{ inputs, ... }:
{
  flake.nixosModules.systemApps = { pkgs, ... }: {
    programs.firefox.enable = true;
    nixpkgs.config.allowUnfree = true;

    environment.systemPackages = with pkgs; [
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
      fish
      nushell
    ];
  };
}
