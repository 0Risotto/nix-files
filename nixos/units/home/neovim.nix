# units/home/neovim.nix — AstroNvim (lazy.nvim) configuration.
# Config files are symlinked from the store; lazy.nvim installs plugins at
# runtime under ~/.local/share/nvim and keeps writing lazy-lock.json into
# ~/.config/nvim, which stays a real writable directory.
{ pkgs, ... }:
let
  cfg = ./nvim;
  files = [
    ".luarc.json"
    "init.lua"
    "lua/community.lua"
    "lua/lazy_setup.lua"
    "lua/polish.lua"
    "lua/plugins/astrocore.lua"
    "lua/plugins/astrolsp.lua"
    "lua/plugins/astroui.lua"
    "lua/plugins/mason.lua"
    "lua/plugins/none-ls.lua"
    "lua/plugins/treesitter.lua"
    "lua/plugins/user.lua"
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
