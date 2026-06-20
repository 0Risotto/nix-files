{ self, inputs, ... }:

{
  flake.nixosModules.displayManager = { config, pkgs, lib, ... }: {

    imports = [
      inputs.silent-sddm.nixosModules.default
    ];

    services.displayManager.sddm.enable = true;

    programs.silentSDDM = {
      enable = true;
      theme = "default";
    };
  };
}