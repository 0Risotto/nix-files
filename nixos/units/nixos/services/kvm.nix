# units/services/kvm.nix — libvirt/KVM virtualization
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.hardware.kvm;
  allUsers = lib.unique ([ config.my.host.username ] ++ builtins.attrNames config.my.host.users);
in
{
  virtualisation.libvirtd = lib.mkIf cfg {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      swtpm.enable = true;
    };
  };

  services.spice-vdagentd.enable = lib.mkIf cfg true;

  programs.virt-manager = lib.mkIf cfg {
    enable = true;
  };

  users.users = lib.genAttrs allUsers (_: {
    extraGroups = lib.mkIf cfg [ "libvirtd" ];
  });
}
