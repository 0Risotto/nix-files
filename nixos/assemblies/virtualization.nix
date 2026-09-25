# assemblies/virtualization.nix — libvirt/KVM and VM management.
{
  nixos = {
    imports = [ ../units/services/kvm.nix ];
    my.hardware.kvm = true;
  };

  home =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.gnome-boxes ];
    };
}
