{ self, ... }:

{
  flake.nixosModules.legionConfiguration =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      imports = [
        self.nixosModules.legionHardware
        self.nixosModules.nvidia
        self.nixosModules.efi
      ];

      settings = {
        hostname = "legion";
        secureBoot = true;
        users = {
          legion = {
            isAdmin = true;
            homeModule = ../../home/legion.nix;
          };
        };
      };

      #Generates nixos users from settings.users
      users.users = lib.mapAttrs (name: cfg: {
        isNormalUser = true;
        description = name;
        extraGroups = lib.optionals cfg.isAdmin [
          "networkmanager"
          "wheel"
        ];
      }) config.settings.users;

      boot.kernelPackages = pkgs.linuxPackages_latest;

      networking = {
        hostName = config.settings.hostname;
        networkmanager.enable = true;
      };

      security.sudo.wheelNeedsPassword = false;

      services = {
        udisks2.enable = true;
        power-profiles-daemon.enable = true;
        upower.enable = true;
        printing.enable = true;
        xserver.xkb = {
          layout = "us";
          variant = "";
        };
      };

      hardware.bluetooth.enable = true;

      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      system.stateVersion = "26.05";
    };
}
