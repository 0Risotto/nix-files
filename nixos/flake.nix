{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    silent-sddm.url = "github:uiriansan/SilentSDDM";
    lanzaboote.url = "github:nix-community/lanzaboote";

    zen-browser.url = "github:youwen5/zen-browser-flake";
    noctalia.url = "github:noctalia-dev/noctalia";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./modules/parts.nix
        ./modules/settings.nix
        ./modules/hosts/default.nix
        ./modules/hosts/legion/configuration.nix
        ./modules/hosts/legion/efi.nix
        ./modules/hosts/legion/hardware.nix
        ./modules/hosts/legion/nvidia.nix
        ./modules/features/display_manager.nix
        ./modules/features/system_apps.nix
        ./modules/features/appearance_defaults.nix
        ./modules/features/audio.nix
        ./modules/features/niri/niri.nix
        ./modules/features/noctalia.nix
        ./modules/features/flatpak.nix
        ./modules/home/default.nix
      ];
    };
}
