# units/system/base.nix — core system: users, locale, networking, nix settings
_: {
  flake.nixosModules.base =
    {
      config,
      lib,
      ...
    }:
    let
      host = config.my.host;
      constants = config.my.constants;
      primaryUser = host.username;
      extraUsers = lib.filterAttrs (name: _: name != primaryUser) host.users;
    in
    {
      users.users = {
        ${primaryUser} = {
          isNormalUser = true;
          description = primaryUser;
          extraGroups = [ "wheel" ] ++ lib.optionals config.settings.networking [ "networkmanager" ];
        };
      }
      // lib.mapAttrs (name: cfg: {
        isNormalUser = true;
        description = name;
        extraGroups = lib.optionals cfg.isAdmin (
          [ "wheel" ] ++ lib.optionals config.settings.networking [ "networkmanager" ]
        );
      }) extraUsers;

      networking = {
        hostName = host.hostname;
        networkmanager.enable = config.settings.networking;
      };

      security.sudo.wheelNeedsPassword = config.settings.sudo.wheelNeedsPassword;

      services = {
        udisks2.enable = true;
        gvfs.enable = true;
        power-profiles-daemon.enable = true;
        upower.enable = true;
        printing.enable = config.settings.printing;
        xserver.xkb = constants.keyboard.xkb;
      };

      hardware.graphics.enable = true;
      hardware.bluetooth.enable = config.settings.bluetooth;

      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      system.stateVersion = host.stateVersion;

      settings.flakeDir = lib.mkDefault "${host.homeDirectory}/${constants.identity.flakeSubpath}";

      i18n = {
        defaultLocale = host.locale;
        extraLocaleSettings = builtins.listToAttrs (
          map
            (k: {
              name = k;
              value = host.locale;
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

      time.timeZone = host.timezone;
    };
}
