{ ... }:
{
  programs.nh = {
    enable = true;
    flake = "/home/legion/git/dotties/nixos";
    clean = {
      enable = true;
      extraArgs = "--keep 3 --keep-since 7d";
    };
  };
}
