# units/system/base.nix — core system: users, locale, networking, nix settings
{ config, lib, ... }:
let
  host = config.my.host;
  constants = config.my.constants;
  system = config.my.system;
  primaryUser = host.username;
  extraUsers = lib.filterAttrs (name: _: name != primaryUser) host.users;
in
{
  users.users = {
    ${primaryUser} = {
      isNormalUser = true;
      description = primaryUser;
      extraGroups = [ "wheel" ] ++ lib.optionals system.networking [ "networkmanager" ];
    };
  }
  // lib.mapAttrs (name: cfg: {
    isNormalUser = true;
    description = name;
    extraGroups = lib.optionals cfg.isAdmin (
      [ "wheel" ] ++ lib.optionals system.networking [ "networkmanager" ]
    );
  }) extraUsers;

  networking = {
    hostName = host.hostname;
    networkmanager.enable = system.networking;
  };

  security.sudo.wheelNeedsPassword = system.sudo.wheelNeedsPassword;

  services = {
    udisks2.enable = true;
    gvfs.enable = true;
    power-profiles-daemon.enable = true;
    upower.enable = true;
    printing.enable = system.printing;
    xserver.xkb = constants.keyboard.xkb;
  };

  hardware.graphics.enable = true;
  hardware.bluetooth.enable = system.bluetooth;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  system.stateVersion = host.stateVersion;

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
}
