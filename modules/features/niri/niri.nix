{ self, inputs, ... }:
{
  flake.nixosModules.niri = { config, pkgs, lib, ... }:
  {
    programs.niri = {
      enable = true;
    };

    imports = [
      inputs.noctalia.nixosModules.default
    ];

    environment.systemPackages = with pkgs; [
      kitty
      emacs
      vscode
      firefox
      nautilus
      hyprpicker
      xwayland-satellite
      wl-clipboard
      grim
      slurp
      polkit
    ];

  };
}
