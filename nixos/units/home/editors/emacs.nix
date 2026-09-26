{ pkgs, ... }:
{
  home.packages = with pkgs; [
    emacs-pgtk
    ripgrep
    fd
  ];
}
