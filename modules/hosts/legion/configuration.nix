{ self, inputs, ... }:

{
  flake.nixosModules.legionConfiguration = { config, pkgs, ... }:
  {
    imports = [
      self.nixosModules.legionHardware
    ];

    users.users.legion = {
      isNormalUser = true;
      description = "legion";
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
    };

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.kernelPackages = pkgs.linuxPackages_latest;

    networking.hostName = "legion";

    networking.networkmanager.enable = true;

    security.sudo.wheelNeedsPassword = false;

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];


    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    services.printing.enable = true;

    services.pulseaudio.enable = false;

    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    system.stateVersion = "26.05";
  };
}