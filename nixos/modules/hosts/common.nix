_: {
  flake.nixosModules.common =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      users.users = lib.mapAttrs (name: cfg: {
        isNormalUser = true;
        description = name;
        extraGroups = lib.optionals cfg.isAdmin (
          [ "wheel" ] ++ lib.optionals config.settings.networking [ "networkmanager" ]
        );
      }) config.settings.users;

      boot.kernelPackages = pkgs.linuxPackages_latest;

      networking = {
        hostName = config.settings.hostname;
        networkmanager.enable = config.settings.networking;
      };

      security.sudo.wheelNeedsPassword = config.settings.sudo.wheelNeedsPassword;

      services = {
        udisks2.enable = true;
        power-profiles-daemon.enable = true;
        upower.enable = true;
        printing.enable = config.settings.printing;
        xserver.xkb = {
          layout = "us";
          variant = "";
        };
      };

      hardware.graphics.enable = true;
      hardware.bluetooth.enable = config.settings.bluetooth;

      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      system.stateVersion = config.settings.stateVersion;
    };
}
