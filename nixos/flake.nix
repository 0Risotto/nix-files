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

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    zen-browser.url = "github:youwen5/zen-browser-flake";
    noctalia.url = "github:noctalia-dev/noctalia/cachix";

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
        importTree ./modules
        ++ importTree ./devshells
        ++ importTree ./hosts
        ++ [
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
