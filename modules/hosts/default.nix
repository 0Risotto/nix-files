{ self, inputs, ... }: {

  flake.nixosConfigurations.legion = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.legionConfiguration
      self.nixosModules.niri
      self.nixosModules.systemApps
      self.nixosModules.userApps
    ];
  };

}
