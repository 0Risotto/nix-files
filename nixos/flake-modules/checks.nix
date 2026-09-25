# flake-modules/checks.nix — checks that mirror CI so `nix flake check`
# catches host/HM breakage locally before switching.
{ self, ... }:
{
  perSystem =
    { pkgs, system, ... }:
    let
      hosts = builtins.filter (
        name: self.nixosConfigurations.${name}.config.nixpkgs.hostPlatform.system == system
      ) (builtins.attrNames self.nixosConfigurations);

      hostChecks = builtins.listToAttrs (
        map (name: {
          name = "host-${name}";
          value = self.nixosConfigurations.${name}.config.system.build.toplevel;
        }) hosts
      );

      homeChecks = builtins.listToAttrs (
        builtins.concatMap (
          host:
          let
            cfg = self.nixosConfigurations.${host}.config;
          in
          map (user: {
            name = "home-${host}-${user}";
            value = cfg.home-manager.users.${user}.home.activationPackage;
          }) (builtins.attrNames cfg.home-manager.users)
        ) hosts
      );

      lintCheck = pkgs.runCommand "statix-check" { nativeBuildInputs = [ pkgs.statix ]; } ''
        statix check ${../.}
        touch $out
      '';
    in
    {
      checks = hostChecks // homeChecks // { statix = lintCheck; };
    };
}
