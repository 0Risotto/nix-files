{ self, inputs, ... }: {

  flake.nixosConfigurations.legion = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.settings
      self.nixosModules.legionConfiguration
      self.nixosModules.systemApps
      self.nixosModules.displayManager
      self.nixosModules.appearanceDefaults
      self.nixosModules.audio
      self.nixosModules.niri
      self.nixosModules.noctalia
      self.nixosModules.flatpak
      self.nixosModules.home
    ];
  };
}
