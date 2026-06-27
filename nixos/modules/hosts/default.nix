{ self, inputs, ... }:
let
  # Auto-discover hosts: any directory under hosts/ with a configuration.nix
  hostsDir = ./.;
  hostNames =
    let
      entries = builtins.readDir hostsDir;
      dirs = builtins.filter (n: entries.${n} == "directory") (builtins.attrNames entries);
    in
    builtins.filter (n: builtins.pathExists (hostsDir + "/${n}/configuration.nix")) dirs;

  mkHost = name: {
    inherit name;
    value = inputs.nixpkgs.lib.nixosSystem {
      modules = [
        self.nixosModules.settings
        self.nixosModules.common
        self.nixosModules."${name}Configuration"
        self.nixosModules.systemApps
        self.nixosModules.displayManager
        self.nixosModules.appearanceDefaults
        self.nixosModules.audio
        self.nixosModules.niri
        self.nixosModules.noctalia
        self.nixosModules.flatpak
        self.nixosModules.kvm
        self.nixosModules.home
      ];
    };
  };
in
{
  flake.nixosConfigurations = builtins.listToAttrs (map mkHost hostNames);
}
