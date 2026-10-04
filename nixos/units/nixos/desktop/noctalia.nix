{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [ inputs.noctalia.nixosModules.default ];

  config = lib.mkIf config.my.desktop.noctalia {
    programs.noctalia = {
      enable = true;
      recommendedServices.enable = true;
    };

    # evtest powers the bongo-cat widget's typing reactivity (reads input devices)
    environment.systemPackages = [ pkgs.evtest ];

    # Grant the active session scoped access to the keyboard event devices
    # (instead of adding the user to the `input` group). Access is revoked
    # whenever the session is not active.
    #
    # These rules must load before systemd's 71-seat.rules / 73-seat-late.rules,
    # which only add the `seat` tag and queue the `uaccess` ACL builtin when the
    # tag is already set. services.udev.extraRules (99-local.rules) runs too late
    # for that, leaving the devices without an ACL.
    services.udev.packages = [
      (pkgs.writeTextDir "lib/udev/rules.d/70-ak820-uaccess.rules" ''
        KERNEL=="event*", SUBSYSTEM=="input", ATTRS{name}=="Shinetek Technology AK820*", TAG+="uaccess"
        KERNEL=="event*", SUBSYSTEM=="input", ATTRS{name}=="AT Raw Set 2 keyboard", TAG+="uaccess"
      '')
    ];

    nix.settings = {
      extra-substituters = [ "https://noctalia.cachix.org" ];
      extra-trusted-public-keys = [
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      ];
    };
  };
}
