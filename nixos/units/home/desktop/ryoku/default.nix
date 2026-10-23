# units/home/desktop/ryoku/default.nix — declarative Ryoku compositor overrides.
#
# Every file written here is a Ryoku "seed": the materializer only creates it
# when absent and never clobbers it, so home-manager owns it from here on.
# Static text lives in the sibling .kdl/.lua/.fish files; only host facts
# (cursor, keyboard layout, displays, flake path) are substituted into them.
#
# niri loads user.kdl last and replaces conflicting binds from earlier includes,
# so user.kdl pulls in niri-binds.kdl. Hyprland loads user.lua last and dofile's
# hypr-binds.lua. Both bind files are rendered from lib/keybinds.nix, which is
# the single source of truth for chords and actions on either compositor.
#
# Note: the Hub's keybind page and the Super+K cheatsheet still describe
# Ryoku's shipped chords, not these overrides.
{
  lib,
  my,
  pkgs,
  ...
}:
let
  inherit (my) constants host;
  inherit (constants) keyboard;
  inherit (host) displays;

  keys = import ../../../../lib/keybinds.nix;

  niriBinds = pkgs.writeText "niri-binds.kdl" keys.niri;
  hyprBinds = pkgs.writeText "hypr-binds.lua" keys.hypr;

  # Workspaces 1-9 on the external monitor, 10 on the panel.
  workspaceRules = lib.concatLines (
    map (n: ''workspace "${toString n}" { open-on-output "${displays.primary}"; }'') (lib.range 1 9)
    ++ lib.optional (
      displays.secondary != null
    ) ''workspace "10" { open-on-output "${displays.secondary}"; }''
  );

  secondaryOutput = lib.optionalString (displays.secondary != null) ''
    output "${displays.secondary}" {
        position x=1920 y=0
    }
  '';

  secondaryRule = lib.optionalString (
    displays.secondary != null
  ) ''hl.workspace_rule({ workspace = "10", monitor = "${displays.secondary}" })'';

  subst = pkgs.replaceVars;
in
{
  xdg.configFile = {
    "niri/user.kdl".source = subst ./niri-user.kdl {
      cursorTheme = constants.theme.cursor.name;
      cursorSize = toString constants.theme.cursor.size;
      xkbLayout = keyboard.xkb.layout;
      xkbOptions = keyboard.xkb.options;
      inherit workspaceRules;
    };

    "niri/niri-binds.kdl".source = niriBinds;

    "niri/monitors_user.kdl".source = subst ./niri-monitors.kdl {
      primaryOutput = displays.primary;
      inherit secondaryOutput;
    };

    "hypr/user.lua".source = subst ./hypr-user.lua {
      cursorTheme = constants.theme.cursor.name;
      cursorSize = toString constants.theme.cursor.size;
      xkbLayout = keyboard.xkb.layout;
      xkbOptions = keyboard.xkb.options;
      primaryOutput = displays.primary;
      inherit secondaryRule;
      hyprBinds = toString hyprBinds;
    };

    "fish/user.fish".source = subst ./fish-user.fish {
      flakeDir = my.system.flakeDir;
    };
  };
}
