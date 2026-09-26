{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [ inputs.umbriel.nixosModules.default ];

  config = lib.mkIf (builtins.elem "umbriel" config.my.desktop.compositors) {
    programs.umbriel.enable = true;

    environment.systemPackages = with pkgs; [
      xwayland-satellite
      polkit
    ];
  };
}
