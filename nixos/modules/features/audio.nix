_: {
  flake.nixosModules.audio =
    { pkgs, ... }:
    {
      security.rtkit.enable = true;

      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };

      environment.systemPackages = with pkgs; [
        pavucontrol
        pulsemixer
        alsa-utils
        alsa-tools
        pamixer
        playerctl
      ];
    };
}
