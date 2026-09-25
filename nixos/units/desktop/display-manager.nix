{
  config,
  inputs,
  lib,
  ...
}:
{
  imports = [ inputs.silent-sddm.nixosModules.default ];

  config = lib.mkIf config.my.desktop.displayManager {
    services.displayManager.sddm.enable = true;

    programs.silentSDDM = {
      enable = true;
      theme = "default";
    };
  };
}
