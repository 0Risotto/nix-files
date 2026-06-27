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

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./modules/parts.nix
        ./modules/settings.nix
        ./modules/hosts/common.nix
        ./modules/hosts/default.nix
        ./modules/hosts/legion/configuration.nix
        ./modules/hosts/legion/hardware.nix
        ./modules/features/efi.nix
        ./modules/features/nvidia.nix
        ./modules/features/display_manager.nix
        ./modules/features/system_apps.nix
        ./modules/features/appearance_defaults.nix
        ./modules/features/audio.nix
        ./modules/features/niri.nix
        ./modules/features/noctalia.nix
        ./modules/features/flatpak.nix
        ./modules/features/home-manager.nix
        ./modules/devshells/default.nix
        inputs.treefmt-nix.flakeModule
      ];

      perSystem = { pkgs, ... }: {
        treefmt.config = {
          projectRootFile = "flake.nix";

          programs.nixfmt = {
            enable = true;
            package = pkgs.nixfmt-rfc-style;
          };

          programs.deadnix = {
            enable = true;
          };
        };
      };
    };
}
