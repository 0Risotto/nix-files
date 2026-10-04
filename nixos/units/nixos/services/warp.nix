# units/services/warp.nix — Cloudflare WARP client daemon
{
  config,
  lib,
  ...
}:
lib.mkIf config.my.services.warp {
  services.cloudflare-warp.enable = true;
}
