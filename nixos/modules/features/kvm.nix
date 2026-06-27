{ ... }:
{
  flake.nixosModules.kvm =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.settings.kvm;
    in
    {
      virtualisation.libvirtd = lib.mkIf cfg {
        enable = true;
        qemu.package = pkgs.qemu_kvm;
      };

      programs.virt-manager = lib.mkIf cfg {
        enable = true;
      };

      users.users = lib.mapAttrs (name: _: {
        extraGroups = lib.mkIf cfg [ "libvirtd" ];
      }) config.settings.users;
    };
}
