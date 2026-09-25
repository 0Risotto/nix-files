# flake-modules/hosts.nix — auto-discovers hosts/*.nix and generates nixosConfigurations
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

  mkHost =
    name:
    let
      # All feature modules except settings/base/home/hosts and host names
      allNames = builtins.attrNames self.nixosModules;
      featureNames = builtins.filter (
        n: n != "settings" && n != "base" && n != "home" && n != "hosts" && !builtins.elem n hostNames
      ) allNames;
    in
    {
      inherit name;
      value = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs self; };
        modules = [
          self.nixosModules.settings
          self.nixosModules.base
          self.nixosModules.${name}
          self.nixosModules.home
        ]
        ++ map (n: self.nixosModules.${n}) featureNames;
      };
    };
  mkHomeConfig =
    name:
    let
      facts = import (../constants/hosts + "/${name}.nix");
      settings = self.hostSettings.${name} or { };
    in
    {
      inherit name;
      value = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = import inputs.nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        modules = [
          {
            home = {
              inherit (facts) username homeDirectory stateVersion;
            };
          }
          ../units/home/base.nix
        ];
        extraSpecialArgs = {
          inherit inputs settings;
          my = {
            constants = import ../constants/shared.nix;
            host = facts;
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
