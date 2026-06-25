{ inputs, ... }:

{
  flake.nixosModules.displayManager = { ... }: {

    imports = [ inputs.silent-sddm.nixosModules.default ];

    services.displayManager.sddm.enable = true;

    programs.silentSDDM = {
      enable = true;
      theme = "default";
    };
  };
}
