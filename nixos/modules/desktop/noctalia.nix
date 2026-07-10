{ inputs, ... }:
{
  flake.nixosModules.noctalia =
    { config, lib, ... }:
    {
      imports = [ inputs.noctalia.nixosModules.default ];

      config = lib.mkIf config.settings.noctalia {
        nix.settings = {
          extra-substituters = [ "https://noctalia.cachix.org" ];
          extra-trusted-public-keys = [
            "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
          ];
        };
      };
    };
}
