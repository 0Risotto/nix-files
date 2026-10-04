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
    # Ryoku pins its own nixpkgs for niri, which links it against an older
    # glibc than the host's /run/opengl-driver GPU stack (NVIDIA + host mesa).
    # niri then cannot load the host GBM/DRI drivers and floods
    # "error doing early import: Error::DeviceMissing" on a black screen.
    # Run the host nixpkgs niri so the compositor matches the graphics stack,
    # and make it win the system-path collision with Ryoku's own copy.
    programs.niri.package = lib.mkOverride 49 pkgs.niri;
    environment.systemPackages = lib.mkBefore [ pkgs.niri ];

    programs.ryoku = {
      enable = true;
      defaultCompositor = "niri";
      browser = "firefox";
      shell = "fish";

      # Trimmed to what this host already uses. "prompt" is omitted on purpose:
      # the wrapped starship unit already owns that binary on PATH.
      optionalApps = [
        "fastfetch"
        "yazi"
        "cli-tools"
      ];

      # The Hub's update page advances the ryoku input in this flake.
      updateFlake = config.my.system.flakeDir;
    };

    # Upstream marks ryoku-rashin as WantedBy=default.target, so the SDDM
    # greeter's own systemd user instance starts it too and squats on
    # 127.0.0.1:3600, making the real user's instance restart-loop.
    # Restrict the daemon to the desktop user.
    systemd.user.services.ryoku-rashin.unitConfig.ConditionUser = config.my.host.username;
  };
}
