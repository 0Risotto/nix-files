# modules/hosts.nix — auto-discovers hosts/*.nix and generates nixosConfigurations
{ self, inputs, ... }:
let
  hostsDir = ../../hosts;
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
      # All feature modules except settings/default/home/hosts and host names
      allNames = builtins.attrNames self.nixosModules;
      featureNames = builtins.filter (
        n:
        n != "settings" && n != "default" && n != "home" && n != "hosts"
        && !builtins.elem n hostNames
      ) allNames;
    in
    {
      inherit name;
      value = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs self; };
        modules =
          [
            self.nixosModules.settings
            self.nixosModules.default
            self.nixosModules.${name}
            self.nixosModules.home
          ]
          ++ map (n: self.nixosModules.${n}) featureNames;
      };
    };
  mkHomeConfig =
    name:
    {
      inherit name;
      value = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = import inputs.nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        modules = [
          {
            home.username = name;
            home.homeDirectory = "/home/${name}";
            home.stateVersion = "26.05";
          }
          ../../home.nix
        ];
        extraSpecialArgs = { inherit inputs; };
      };
    };
in
{
  flake = {
    nixosConfigurations = builtins.listToAttrs (map mkHost hostNames);
    homeConfigurations = builtins.listToAttrs (map mkHomeConfig hostNames);
  };
}
