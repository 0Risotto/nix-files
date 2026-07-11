# modules/default.nix — core system: kernel, users, locale, networking, nix settings
_: {
  flake.nixosModules.default =
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

      i18n = {
        defaultLocale = config.settings.locale;
        extraLocaleSettings = builtins.listToAttrs (
          map
            (k: {
              name = k;
              value = config.settings.locale;
            })
            [
              "LC_ADDRESS"
              "LC_IDENTIFICATION"
              "LC_MEASUREMENT"
              "LC_MONETARY"
              "LC_NAME"
              "LC_NUMERIC"
              "LC_PAPER"
              "LC_TELEPHONE"
              "LC_TIME"
            ]
        );
      };

      time.timeZone = config.settings.timezone;
    };
}
