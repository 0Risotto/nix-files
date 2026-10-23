# units/hardware/memory.nix — zram swap as first tier, VM tuning for compressed swap
{ config, lib, ... }:
let
  swap = config.my.host.swap;
in
lib.mkIf (swap != null && swap.zramPercent > 0) {
  zramSwap = {
    enable = true;
    memoryPercent = swap.zramPercent;
    algorithm = "zstd";
  };

  boot.kernel.sysctl = {
    # Prefer the compressed device; random access has no seek cost to amortize.
    "vm.swappiness" = 150;
    "vm.page-cluster" = 0;
  };
}
