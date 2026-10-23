# units/services/scx.nix — sched-ext CPU scheduler via scx_loader
{ config, lib, ... }:
lib.mkIf config.my.services.scx {
  services.scx-loader = {
    enable = true;
    config.default_sched = "scx_lavd";
  };
}
