# units/home/neovim.nix — LazyVim configuration.
# Config files are symlinked from the store; lazy.nvim installs plugins at
# runtime under ~/.local/share/nvim and keeps writing lazy-lock.json into
# ~/.config/nvim, which stays a real writable directory.
{ pkgs, ... }:
let
  cfg = ./nvim;
  files = [
    "init.lua"
    "lua/config/autocmds.lua"
    "lua/config/keymaps.lua"
    "lua/config/lazy.lua"
    "lua/config/options.lua"
  ];
in
{
  home.packages = [ pkgs.neovim ];

  xdg.configFile = builtins.listToAttrs (
    map (path: {
      name = "nvim/${path}";
      value.source = cfg + "/${path}";
    }) files
  );
}
