_: {
  flake.nixosModules.niri =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    lib.mkIf config.settings.niri {
      programs.niri.enable = true;

      environment.systemPackages = with pkgs; [
        xwayland-satellite
        polkit
      ];

    };
}
