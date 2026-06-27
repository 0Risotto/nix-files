{ self, ... }:

{
  flake.nixosModules.legionConfiguration =
    { ... }:
    {
      imports = [
        self.nixosModules.legionHardware
        self.nixosModules.nvidia
        self.nixosModules.efi
      ];

      settings = {
        hostname = "legion";
        timezone = "Asia/Amman";
        stateVersion = "26.05";
        nvidia = true;
        displayManager = true;
        niri = true;
        noctalia = true;
        flatpak = true;
        efi.secureBoot = true;
        users = {
          legion = {
            isAdmin = true;
            homeModule = ../../../home/legion.nix;
          };
        };
      };
    };
}
