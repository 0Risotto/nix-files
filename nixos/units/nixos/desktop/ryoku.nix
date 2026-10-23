# units/nixos/desktop/ryoku.nix — Ryoku desktop (Ryoku-on-NixOS) with its niri session.
{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [ inputs.ryoku.nixosModules.default ];

  config = lib.mkIf config.my.desktop.ryoku {
    programs.niri.package = lib.mkOverride 49 pkgs.niri;
    environment.systemPackages = lib.mkBefore [
      pkgs.niri
      # nixpkgs wraps Hyprland in a bash script to extend PATH, but NixOS
      # refuses non-ELF security.wrappers. Run the real binary below and put
      # the wrapper's runtime deps on the system PATH instead.
      pkgs.binutils
      pkgs.hyprland-qtutils
      pkgs.pciutils
      pkgs.pkgconf
    ];

    security.wrappers.Hyprland.source = lib.mkForce "${config.programs.hyprland.package}/bin/.Hyprland-wrapped";

    programs.ryoku = {
      enable = true;
      defaultCompositor = "niri";
      browser = "firefox";
      shell = "fish";

      optionalApps = [
        "prompt"
        "fastfetch"
        "yazi"
        "cli-tools"
      ];

      updateFlake = config.my.system.flakeDir;
    };

    systemd.user.services.ryoku-rashin.unitConfig.ConditionUser = config.my.host.username;

    systemd.user.services.ryoku-shell.serviceConfig.KillMode = lib.mkForce "process";
  };
}
