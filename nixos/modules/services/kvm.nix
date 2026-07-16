_: {
  flake.nixosModules.kvm =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.settings.kvm;
      allUsers = lib.unique ([ config.settings.username ] ++ builtins.attrNames config.settings.users);
    in
    {
      virtualisation.libvirtd = lib.mkIf cfg {
        enable = true;
        qemu.package = pkgs.qemu_kvm;
      };

      programs.virt-manager = lib.mkIf cfg {
        enable = true;
      };

      users.users = lib.genAttrs allUsers (_: {
        extraGroups = lib.mkIf cfg [ "libvirtd" ];
      });
    };
}
