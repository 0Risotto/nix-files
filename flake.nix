{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    silent-sddm.url = "github:uiriansan/SilentSDDM";
    lanzaboote.url = "github:nix-community/lanzaboote";

    zen-browser.url = "github:youwen5/zen-browser-flake";
    noctalia.url = "github:noctalia-dev/noctalia";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./modules);
}
