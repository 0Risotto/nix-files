# assemblies/vpn.nix — Cloudflare WARP tunnel client.
{
  nixos = {
    imports = [
      ../units/nixos/services/warp.nix
    ];
    my.services.warp = true;
  };
}
