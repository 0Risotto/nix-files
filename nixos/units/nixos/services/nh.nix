# units/services/nh.nix — nh Nix CLI helper
{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf config.my.services.nh {
  environment.systemPackages = [ pkgs.nh ];

  environment.sessionVariables = lib.genAttrs [ "NH_FLAKE" "NH_OS_FLAKE" "NH_HOME_FLAKE" ] (
    _: config.my.system.flakeDir
  );
}
