_: {
  flake.nixosModules.niri =
    { pkgs, ... }:
    {
      programs.niri.enable = true;

      environment.systemPackages = with pkgs; [
        xwayland-satellite
        polkit
      ];

    };
}
