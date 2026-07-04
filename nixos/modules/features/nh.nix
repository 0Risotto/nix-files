_: {
  flake.nixosModules.nh = { config, lib, pkgs, ... }: lib.mkIf config.settings.nh {
    environment.systemPackages = [ pkgs.nh ];

    environment.sessionVariables = {
      NH_FLAKE = "/home/legion/git/dotties/nixos";
      NH_OS_FLAKE = "/home/legion/git/dotties/nixos";
      NH_HOME_FLAKE = "/home/legion/git/dotties/nixos";
    };
  };
}
