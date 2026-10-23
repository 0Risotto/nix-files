# lib/keybinds.nix — the single source of truth for host keybinds.
#
# One row per chord, with the niri action and the Hyprland expression written
# out explicitly, because the two vocabularies are not translations of each
# other: niri's move-column-to-workspace/action vocabulary has no mechanical
# Hyprland equivalent (workspace move, hl.dsp.window.move({ monitor = "l" }), …),
# and a "clever" mapping had to special-case half the table anyway. Spelling the
# two sides out keeps the file readable and makes drift impossible — one row,
# both desktops.
#
# Fields:
#   niriChord   chord as niri writes it ("Super+Shift+Escape"), or absent when
#               the chord only exists on Hyprland
#   niriAction  niri action body, e.g. ''spawn "kitty"''
#   niriAttrs   KDL node attributes with their real types, e.g. { repeat = false; }
#   hyprChord   chord as Hyprland writes it ("SUPER + SHIFT + Escape"), or
#               absent when the chord only exists on niri
#   hyprAction  Hyprland expression, e.g. ''hl.dsp.exec_cmd("kitty")''.
#               null means "unbind this chord" (how shipped Ryoku binds are
#               disabled); a missing hyprChord means "not touched on Hyprland"
#   hyprOpts    Lua table tail for hl.bind, e.g. ", { repeating = false }"
let
  inherit (builtins)
    attrNames
    concatStringsSep
    filter
    genList
    map
    ;

  kdlValue =
    v:
    if builtins.isBool v then
      (if v then "true" else "false")
    else if builtins.isInt v then
      toString v
    else
      "\"${v}\"";

  # niri parses attributes with their real types: booleans and integers bare,
  # strings quoted.
  kdlAttrs = a: concatStringsSep "" (map (k: " ${k}=" + kdlValue a.${k}) (attrNames a));

  niriStmt = r: "    " + "${r.niriChord}${kdlAttrs (r.niriAttrs or { })} { ${r.niriAction}; }";

  hyprStmt =
    r:
    "    "
    + (
      if (r.hyprAction or null) == null then
        "hl.unbind(\"${r.hyprChord}\")"
      else
        "hl.bind(\"${r.hyprChord}\", ${r.hyprAction}${r.hyprOpts or ""})"
    );

  # Ryoshot needs the system QML modules: Ryoku's own spawn exports only the
  # user QML dir, which drops Qt5Compat.GraphicalEffects.
  qmlPath = "$HOME/.local/lib/qt6/qml:/run/current-system/sw/lib/qt-6/qml";
  qsEnv = ''env QML_IMPORT_PATH=\"${qmlPath}\" QML2_IMPORT_PATH=\"${qmlPath}\"'';
  ryoshot = "${qsEnv} flock -n -o /tmp/ryoshot.lock qs -c ryoshot";

  cheatsheet = "pkill -x -f 'qs -c keys' 2>/dev/null || flock -n -o /tmp/ryoku-keys.lock qs -c keys";

  # Toggle the Ryoku shell off/on: first press stops the service, the next
  # starts it again. A niri bind, so it keeps working while the shell is down.
  shellToggle = "if systemctl --user is-active --quiet ryoku-shell.service; then systemctl --user stop ryoku-shell.service; else systemctl --user start ryoku-shell.service; fi";

  hyprWorkspace = ''os.getenv("HOME") .. "/.config/hypr/scripts/ryoku-workspace"'';

  # Super+Shift+N moves the focused column to workspace N on niri and moves +
  # follows on Hyprland (the old config's behaviour, kept). Workspace 10 is the
  # 0 key.
  workspaceRows = genList (
    i:
    let
      n = i + 1;
      ws = toString n;
      key = if n == 10 then "0" else ws;
    in
    {
      niriChord = "Super+Shift+${key}";
      niriAction = "move-column-to-workspace ${ws}";
      hyprChord = "SUPER + SHIFT + ${key}";
      hyprAction = ''hl.dsp.exec_cmd(${hyprWorkspace} .. " move ${ws}")'';
    }
  ) 10;

  rows = [
    # ── Ryoku shell ──
    {
      niriChord = "Super+Shift+Escape";
      niriAttrs = {
        hotkey-overlay-title = "Hotkey overlay";
      };
      niriAction = "show-hotkey-overlay";
      hyprChord = "SUPER + SHIFT + Escape";
      hyprAction = ''hl.dsp.exec_cmd("${cheatsheet}")'';
    }
    {
      # niri has a shortcuts inhibitor to toggle; Hyprland has no equivalent,
      # so its shipped bind for this chord stays as it is.
      niriChord = "Super+Escape";
      niriAttrs = {
        allow-inhibiting = false;
      };
      niriAction = "toggle-keyboard-shortcuts-inhibit";
    }
    {
      niriChord = "Super+I";
      niriAction = ''spawn "ryoku-shell" "hub" "open"'';
      hyprChord = "SUPER + I";
      hyprAction = ''hl.dsp.exec_cmd("ryoku-shell hub open")'';
    }
    {
      niriChord = "Super+N";
      niriAction = ''spawn "ryoku-shell" "quicksettings"'';
      hyprChord = "SUPER + N";
      hyprAction = ''hl.dsp.global("ryoku:quicksettings")'';
    }
    {
      niriChord = "Super+Shift+L";
      niriAction = ''spawn "ryoku-shell" "quicksettings"'';
      hyprChord = "SUPER + SHIFT + L";
      hyprAction = ''hl.dsp.global("ryoku:quicksettings")'';
    }
    {
      niriChord = "Super+J";
      niriAction = ''spawn "ryoku-shell" "bar-toggle"'';
      hyprChord = "SUPER + J";
      hyprAction = ''hl.dsp.exec_cmd("ryoku-shell bar-toggle")'';
    }
    {
      niriChord = "Super+Shift+R";
      niriAction = ''spawn "ryoku-shell" "reload"'';
      hyprChord = "SUPER + SHIFT + R";
      hyprAction = ''hl.dsp.exec_cmd("ryoku-shell reload")'';
    }
    {
      niriChord = "Super+Ctrl+T";
      niriAction = ''spawn "ryogami" "wallpaper" "ui"'';
      hyprChord = "SUPER + CTRL + T";
      hyprAction = ''hl.dsp.exec_cmd("ryogami wallpaper ui")'';
    }

    # ── Apps ──
    {
      niriChord = "Super+A";
      niriAction = ''spawn "ryoku-shell" "launcher"'';
      hyprChord = "SUPER + A";
      hyprAction = ''hl.dsp.global("ryoku:launcher")'';
    }
    {
      niriChord = "Super+T";
      niriAction = ''spawn "kitty"'';
      hyprChord = "SUPER + T";
      hyprAction = ''hl.dsp.exec_cmd("kitty")'';
    }
    {
      niriChord = "Super+C";
      niriAction = ''spawn "zeditor"'';
      hyprChord = "SUPER + C";
      hyprAction = ''hl.dsp.exec_cmd("zeditor")'';
    }
    {
      niriChord = "Super+X";
      niriAction = ''spawn "emacs"'';
      hyprChord = "SUPER + X";
      hyprAction = ''hl.dsp.exec_cmd("emacs")'';
    }
    {
      niriChord = "Super+F";
      niriAction = ''spawn "firefox"'';
      hyprChord = "SUPER + F";
      hyprAction = ''hl.dsp.exec_cmd("firefox")'';
    }
    {
      niriChord = "Super+E";
      niriAction = ''spawn "nautilus"'';
      hyprChord = "SUPER + E";
      hyprAction = ''hl.dsp.exec_cmd("nautilus")'';
    }
    {
      niriChord = "Super+G";
      niriAction = ''spawn "gamescope" "-W" "1920" "-H" "1080" "--" "steam"'';
      hyprChord = "SUPER + G";
      hyprAction = ''hl.dsp.exec_cmd("gamescope -W 1920 -H 1080 -- steam")'';
    }

    # ── Windows / overview / workspaces ──
    {
      niriChord = "Super+W";
      niriAction = "fullscreen-window";
      hyprChord = "SUPER + W";
      hyprAction = "hl.dsp.window.fullscreen()";
    }
    {
      # Shadows Ryoku's shipped Super+Shift+C (hyprpicker); the colour picker
      # stays on Super+Shift+E.
      niriChord = "Super+Shift+C";
      niriAction = "center-column";
      hyprChord = "SUPER + SHIFT + C";
      hyprAction = "hl.dsp.window.center()";
    }
    {
      niriChord = "Super+O";
      niriAttrs = {
        repeat = false;
      };
      niriAction = "toggle-overview";
      hyprChord = "SUPER + O";
      hyprAction = ''hl.dsp.global("ryoku:overview")'';
      hyprOpts = ", { repeating = false }";
    }
    {
      niriChord = "Super+Tab";
      niriAction = "focus-workspace-previous";
      hyprChord = "SUPER + Tab";
      hyprAction = ''hl.dsp.exec_cmd("hyprctl dispatch workspace previous")'';
    }

    # ── Monitors ──
    {
      niriChord = "Super+Ctrl+Left";
      niriAction = "focus-monitor-left";
      hyprChord = "SUPER + CTRL + Left";
      hyprAction = ''hl.dsp.focus({ monitor = "l" })'';
    }
    {
      niriChord = "Super+Ctrl+Right";
      niriAction = "focus-monitor-right";
      hyprChord = "SUPER + CTRL + Right";
      hyprAction = ''hl.dsp.focus({ monitor = "r" })'';
    }
    {
      niriChord = "Super+Ctrl+Up";
      niriAction = "focus-workspace-up";
      hyprChord = "SUPER + CTRL + Up";
      hyprAction = ''hl.dsp.focus({ monitor = "u" })'';
    }
    {
      niriChord = "Super+Ctrl+Down";
      niriAction = "focus-workspace-down";
      hyprChord = "SUPER + CTRL + Down";
      hyprAction = ''hl.dsp.focus({ monitor = "d" })'';
    }
    {
      niriChord = "Super+Shift+Ctrl+Left";
      niriAction = "move-column-to-monitor-left";
      hyprChord = "SUPER + SHIFT + CTRL + Left";
      hyprAction = ''hl.dsp.window.move({ monitor = "l" })'';
    }
    {
      niriChord = "Super+Shift+Ctrl+Right";
      niriAction = "move-column-to-monitor-right";
      hyprChord = "SUPER + SHIFT + CTRL + Right";
      hyprAction = ''hl.dsp.window.move({ monitor = "r" })'';
    }
    {
      niriChord = "Super+Shift+Ctrl+Up";
      niriAction = "move-column-to-monitor-up";
      hyprChord = "SUPER + SHIFT + CTRL + Up";
      hyprAction = ''hl.dsp.window.move({ monitor = "u" })'';
    }
    {
      niriChord = "Super+Shift+Ctrl+Down";
      niriAction = "move-column-to-monitor-down";
      hyprChord = "SUPER + SHIFT + CTRL + Down";
      hyprAction = ''hl.dsp.window.move({ monitor = "d" })'';
    }
    {
      niriChord = "Super+Ctrl+Home";
      niriAction = "move-column-to-first";
    }
    {
      niriChord = "Super+Ctrl+End";
      niriAction = "move-column-to-last";
    }
    {
      niriChord = "Super+Ctrl+C";
      niriAction = "center-visible-columns";
      hyprChord = "SUPER + CTRL + C";
      hyprAction = "hl.dsp.window.center()";
    }

    # ── Size ──
    {
      niriChord = "Super+Minus";
      niriAction = ''set-column-width "-10%"'';
      hyprChord = "SUPER + minus";
      hyprAction = "hl.dsp.window.resize({ x = -40, y = 0, relative = true })";
      hyprOpts = ", { repeating = true }";
    }
    {
      niriChord = "Super+Equal";
      niriAction = ''set-column-width "+10%"'';
      hyprChord = "SUPER + equal";
      hyprAction = "hl.dsp.window.resize({ x = 40, y = 0, relative = true })";
      hyprOpts = ", { repeating = true }";
    }
    {
      niriChord = "Super+Shift+Minus";
      niriAction = ''set-window-height "-10%"'';
      hyprChord = "SUPER + SHIFT + minus";
      hyprAction = "hl.dsp.window.resize({ x = 0, y = -40, relative = true })";
      hyprOpts = ", { repeating = true }";
    }
    {
      # Old-config quirk kept: shift+equal grows the width on both desktops.
      niriChord = "Super+Shift+Equal";
      niriAction = ''set-column-width "+10%"'';
      hyprChord = "SUPER + SHIFT + equal";
      hyprAction = "hl.dsp.window.resize({ x = 40, y = 0, relative = true })";
      hyprOpts = ", { repeating = true }";
    }

    # ── Workspaces: move the focused column to workspace N ──
  ]
  ++ workspaceRows
  ++ [
    # ── Mouse wheel: niri scrolls columns, Hyprland moves between them ──
    {
      niriChord = "Super+WheelScrollLeft";
      niriAction = "focus-column-left";
    }
    {
      niriChord = "Super+WheelScrollRight";
      niriAction = "focus-column-right";
    }
    {
      niriChord = "Super+Shift+WheelScrollUp";
      niriAction = "focus-column-left";
      hyprChord = "SUPER + SHIFT + mouse_up";
      hyprAction = ''hl.dsp.focus({ direction = "left" })'';
    }
    {
      niriChord = "Super+Shift+WheelScrollDown";
      niriAction = "focus-column-right";
      hyprChord = "SUPER + SHIFT + mouse_down";
      hyprAction = ''hl.dsp.focus({ direction = "right" })'';
    }
    {
      niriChord = "Super+Ctrl+WheelScrollLeft";
      niriAction = "move-column-left";
    }
    {
      niriChord = "Super+Ctrl+WheelScrollRight";
      niriAction = "move-column-right";
    }
    {
      niriChord = "Super+Ctrl+Shift+WheelScrollUp";
      niriAction = "move-column-left";
      hyprChord = "SUPER + CTRL + SHIFT + mouse_up";
      hyprAction = ''hl.dsp.window.move({ direction = "left" })'';
    }
    {
      niriChord = "Super+Ctrl+Shift+WheelScrollDown";
      niriAction = "move-column-right";
      hyprChord = "SUPER + CTRL + SHIFT + mouse_down";
      hyprAction = ''hl.dsp.window.move({ direction = "right" })'';
    }
    {
      niriChord = "Super+Ctrl+WheelScrollUp";
      niriAttrs = {
        cooldown-ms = 150;
      };
      niriAction = "move-column-to-workspace-up";
      hyprChord = "SUPER + CTRL + mouse_up";
      hyprAction = ''hl.dsp.window.move({ workspace = "r-1" })'';
    }
    {
      niriChord = "Super+Ctrl+WheelScrollDown";
      niriAttrs = {
        cooldown-ms = 150;
      };
      niriAction = "move-column-to-workspace-down";
      hyprChord = "SUPER + CTRL + mouse_down";
      hyprAction = ''hl.dsp.window.move({ workspace = "r+1" })'';
    }

    # ── Tools ──
    {
      niriChord = "Super+Shift+E";
      niriAction = ''spawn-sh "hyprpicker -a"'';
      hyprChord = "SUPER + SHIFT + E";
      hyprAction = ''hl.dsp.exec_cmd("hyprpicker -a")'';
    }
    {
      niriChord = "Super+Shift+A";
      niriAction = ''spawn-sh "image-search"'';
      hyprChord = "SUPER + SHIFT + A";
      hyprAction = ''hl.dsp.exec_cmd("image-search")'';
    }
    {
      niriChord = "Super+Shift+K";
      niriAction = ''spawn-sh "niri msg pick-window | grep PID: | awk '{print $2}' | xargs kill"'';
      hyprChord = "SUPER + SHIFT + K";
      hyprAction = ''hl.dsp.exec_cmd("hyprctl kill")'';
    }
    {
      niriChord = "Super+Shift+Q";
      niriAction = ''spawn-sh "grim -g \"$(slurp)\" /tmp/qr.png && zbarimg --quiet --raw /tmp/qr.png | xargs xdg-open; rm -f /tmp/qr.png"'';
      hyprChord = "SUPER + SHIFT + Q";
      hyprAction = ''hl.dsp.exec_cmd("grim -g \"$(slurp)\" /tmp/qr.png && zbarimg --quiet --raw /tmp/qr.png | xargs xdg-open; rm -f /tmp/qr.png")'';
    }
    {
      niriChord = "Super+Shift+S";
      niriAction = ''spawn-sh "${ryoshot}"'';
      hyprChord = "SUPER + SHIFT + S";
      hyprAction = ''hl.dsp.exec_cmd("${ryoshot}")'';
    }
    {
      niriChord = "Print";
      niriAction = ''spawn-sh "${ryoshot}"'';
    }
    {
      niriChord = "Shift+Print";
      niriAction = ''spawn-sh "${qsEnv} RYOSHOT_MODE=monitor flock -n -o /tmp/ryoshot.lock qs -c ryoshot"'';
    }

    # ── Session / hardware ──
    {
      # Super+P is Ryoku's "cycle display arrangement". niri has no unbind, so
      # the chord is shadowed with an empty command; Hyprland unregisters it.
      niriChord = "Super+P";
      niriAction = ''spawn-sh ""'';
      hyprChord = "SUPER + P";
      hyprAction = null;
    }
    {
      niriChord = "Super+Shift+P";
      niriAction = ''spawn-sh "${shellToggle}"'';
      hyprChord = "SUPER + SHIFT + P";
      hyprAction = ''hl.dsp.exec_cmd("${shellToggle}")'';
    }
    {
      niriChord = "Ctrl+Alt+Delete";
      niriAction = "quit";
      hyprChord = "CTRL + ALT + Delete";
      hyprAction = ''hl.dsp.exec_cmd("hyprctl dispatch exit")'';
    }
    {
      niriChord = "Super+Shift+M";
      niriAction = ''spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"'';
      hyprChord = "SUPER + SHIFT + M";
      hyprAction = ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")'';
    }
    {
      niriChord = "XF86AudioMicMute";
      niriAttrs = {
        allow-when-locked = true;
      };
      niriAction = ''spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"'';
      hyprChord = "XF86AudioMicMute";
      hyprAction = ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")'';
      hyprOpts = ", { locked = true }";
    }
  ];

  niriRows = filter (r: (r.niriChord or null) != null) rows;
  hyprRows = filter (r: (r.hyprChord or null) != null) rows;
in
{
  inherit rows;

  # niri: included from user.kdl, which Ryoku loads last.
  niri = ''
    // Generated by lib/keybinds.nix — edit the table there, not this file.
    // niri replaces conflicting binds from earlier includes, so these win over
    // Ryoku's generated rebinds.kdl.
    binds {
    ${concatStringsSep "\n" (map niriStmt niriRows)}
    }
  '';

  # Hyprland: dofile'd from user.lua, which Ryoku loads last.
  hypr = ''
    -- Generated by lib/keybinds.nix — edit the table there, not this file.
    -- Loaded after Ryoku's shipped catalogue, so these binds win.
    ${concatStringsSep "\n" (map hyprStmt hyprRows)}
  '';
}
