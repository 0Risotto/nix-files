{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote.url = "github:nix-community/lanzaboote";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    zen-browser.url = "github:youwen5/zen-browser-flake";

    ryoku = {
      url = "github:aethctl/Ryoku-on-NixOS";
      # Keep Ryoku's own tested nixpkgs revision instead of resolving
      # nixos-unstable fresh, which lags into EOL-Electron territory
      # (RyoMotion pins electron_41 and recent nixpkgs refuses to evaluate it).
      inputs.nixpkgs.url = "github:NixOS/nixpkgs/56c02bc00adcf003215cc4bd996d6efaf4cff188";
    };

    nix-wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    let
      importTree =
        dir:
        let
          entries = builtins.readDir dir;
          names = builtins.attrNames entries;
          files = builtins.filter (n: entries.${n} == "regular") names;
          dirs = builtins.filter (n: entries.${n} == "directory") names;
        in
        map (n: dir + "/${n}") files ++ builtins.concatMap (n: importTree (dir + "/${n}")) dirs;
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      imports =
        importTree ./flake-modules
        ++ importTree ./devshells
        ++ [
          inputs.treefmt-nix.flakeModule
        ];

      perSystem = { pkgs, ... }: {
        treefmt.config = {
          projectRootFile = "flake.nix";

          programs.nixfmt = {
            enable = true;
            package = pkgs.nixfmt;
          };

          programs.deadnix = {
            enable = true;
          };
        };
      };

    };
}
