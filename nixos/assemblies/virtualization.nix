# assemblies/virtualization.nix — libvirt/KVM and VM management.
{
  nixos = {
    imports = [
      ../units/nixos/services/kvm.nix
      ../units/nixos/services/waydroid.nix
    ];
    my.hardware.kvm = true;
    my.services.waydroid = true;
  };

  home =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.gnome-boxes ];
    };
}
