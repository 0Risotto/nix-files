# flake-modules/hosts.nix — discovers hosts/*.nix and builds flake outputs.
# A host is a plain NixOS module that sets my.host; composition comes from
# my.host.assemblies, loaded here (the composition root) to keep module
# imports independent of config.
{ self, inputs, ... }:
let
  hostsDir = ../hosts;
  hostNames =
    let
      entries = builtins.readDir hostsDir;
      files = builtins.filter (n: entries.${n} == "regular") (builtins.attrNames entries);
      nixFiles = builtins.filter (n: builtins.match ".*\\.nix" n != null) files;
    in
    map (n: builtins.head (builtins.match "(.*)\\.nix" n)) nixFiles;

  assemblies = import ../assemblies;

  # Always-on modules: options, core system, machine hardware, base services.
  baseModules = [
    ../options
    ../units/system/base.nix
    ../units/system/apps.nix
    ../units/system/home-manager.nix
    ../units/hardware/kernel.nix
    ../units/hardware/filesystems.nix
    ../units/hardware/efi.nix
    ../units/hardware/audio.nix
    ../units/hardware/nvidia.nix
    ../units/hardware/intel.nix
    ../units/hardware/thermal.nix
    ../units/services/nh.nix
  ];

  mkHost =
    name:
    let
      facts = import (../constants/hosts + "/${name}.nix");
      selected = assemblies.load (facts.assemblies or [ ]);
    in
    {
      inherit name;
      value = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs self; };
        modules =
          baseModules
          ++ map (a: a.nixos) selected
          ++ [
            {
              # Assembly home halves are shared by every user on the host.
              home-manager.sharedModules = assemblies.baseHome ++ map (a: a.home or { }) selected;
            }
            (hostsDir + "/${name}.nix")
          ];
      };
    };

  mkHomeConfig =
    name:
    let
      facts = import (../constants/hosts + "/${name}.nix");
      shared = import ../constants/shared.nix;
    in
    {
      inherit name;
      value = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = import inputs.nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        modules = [
          { home = { inherit (facts) username homeDirectory stateVersion; }; }
        ]
        ++ assemblies.baseHome
        ++ assemblies.home (facts.assemblies or [ ]);
        extraSpecialArgs = {
          inherit inputs;
          my = {
            constants = shared;
            host = facts;
            system = {
              flakeDir = "${facts.homeDirectory}/${shared.identity.flakeSubpath}";
            };
            desktop = {
              compositors = facts.compositors or [ ];
            };
          };
        };
      };
    };
in
{
  flake = {
    nixosConfigurations = builtins.listToAttrs (map mkHost hostNames);
    homeConfigurations = builtins.listToAttrs (map mkHomeConfig hostNames);
  };
}
