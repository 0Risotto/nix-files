_: {
  flake.nixosModules.nh =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    lib.mkIf config.settings.nh {
      environment.systemPackages = [ pkgs.nh ];

      environment.sessionVariables = lib.genAttrs [ "NH_FLAKE" "NH_OS_FLAKE" "NH_HOME_FLAKE" ] (
        _: config.settings.flakeDir
      );
    };
}
