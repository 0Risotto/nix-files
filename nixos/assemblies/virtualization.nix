# assemblies/virtualization.nix — libvirt/KVM and VM management.
{
  nixos = {
    imports = [
      ../units/services/kvm.nix
      ../units/services/waydroid.nix
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
