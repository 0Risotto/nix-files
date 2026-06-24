{ config, pkgs, inputs, ...}:

{
  home.packages = [
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
  ] ++ (with pkgs; [
      kitty
      nautilus
      hyprpicker
      wl-clipboard
      grim
      slurp
  ]);

  xdg.configFile."niri" = {
    source = ./config/niri;
    recursive = true;
  };
}
