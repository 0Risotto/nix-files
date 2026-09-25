{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  wrap = inputs.nix-wrapper-modules.wrappers.niri.wrap;
  constants = config.my.constants;
  monitors = config.my.host.monitors;

  spawnContent =
    bind: if bind.sh != null then { "spawn-sh" = bind.sh; } else { "spawn" = bind.argv; };

  spawnBinds = builtins.listToAttrs (
    map (bind: {
      name = bind.key;
      value =
        if bind.title != null then
          _: {
            props."hotkey-overlay-title" = bind.title;
            content = spawnContent bind;
          }
        else
          spawnContent bind;
    }) constants.keybinds.spawn
  );

  mediaBinds = builtins.listToAttrs (
    map (bind: {
      name = bind.key;
      value = _: {
        props."allow-when-locked" = true;
        content."spawn-sh" = bind.command;
      };
    }) constants.keybinds.media
  );

  workspaceKey = ws: if ws == "10" then "0" else ws;
  workspaceValue = ws: if builtins.stringLength ws == 1 then lib.toInt ws else ws;
  workspaceBinds = builtins.listToAttrs (
    builtins.concatMap (ws: [
      {
        name = "Mod+${workspaceKey ws}";
        value."focus-workspace" = workspaceValue ws;
      }
      {
        name = "Mod+Shift+${workspaceKey ws}";
        value."move-column-to-workspace" = workspaceValue ws;
      }
    ]) (lib.concatLists (lib.mapAttrsToList (_: monitor: monitor.workspaces) monitors))
  );
in
lib.mkIf (builtins.elem "niri" config.my.desktop.compositors) {
  programs.niri = {
    enable = true;
    package = wrap {
      inherit pkgs;

      settings = {
        # ── animation.kdl ──
        animations = {
          "workspace-switch" = {
            spring = _: {
              props = {
                "damping-ratio" = 1.0;
                stiffness = 1000;
                epsilon = 0.0001;
              };
            };
          };
          "window-open" = {
            "duration-ms" = 200;
            curve = "ease-out-quad";
          };
          "window-close" = {
            "duration-ms" = 200;
            curve = "ease-out-cubic";
          };
          "horizontal-view-movement" = {
            spring = _: {
              props = {
                "damping-ratio" = 1.0;
                stiffness = 900;
                epsilon = 0.0001;
              };
            };
          };
          "window-movement" = {
            spring = _: {
              props = {
                "damping-ratio" = 1.0;
                stiffness = 800;
                epsilon = 0.0001;
              };
            };
          };
          "window-resize" = {
            spring = _: {
              props = {
                "damping-ratio" = 1.0;
                stiffness = 1000;
                epsilon = 0.0001;
              };
            };
          };
          "config-notification-open-close" = {
            spring = _: {
              props = {
                "damping-ratio" = 0.6;
                stiffness = 1200;
                epsilon = 0.001;
              };
            };
          };
          "screenshot-ui-open" = {
            "duration-ms" = 300;
            curve = "ease-out-quad";
          };
          "overview-open-close" = {
            spring = _: {
              props = {
                "damping-ratio" = 1.0;
                stiffness = 900;
                epsilon = 0.0001;
              };
            };
          };
        };

        # ── autostart.kdl ──
        "spawn-sh-at-startup" = [
          "/usr/lib/polkit-kde-authentication-agent-1 &"
          "noctalia"
        ];
        "spawn-at-startup" = [
          # [
          #   "vicinae"
          #   "server"
          # ]
        ];

        # ── cursor.kdl ──
        cursor = {
          "xcursor-theme" = constants.theme.cursor.name;
          "xcursor-size" = constants.theme.cursor.size;
        };

        # ── display.kdl ──
        outputs = lib.mapAttrs (
          _: monitor:
          {
            position = _: {
              props = {
                inherit (monitor.position) x y;
              };
            };
          }
          // lib.optionalAttrs (monitor.mode != null) { inherit (monitor) mode; }
        ) monitors;

        # ── input.kdl ──
        input = {
          "keyboard"."xkb" = {
            inherit (constants.keyboard.compositor) layout options;
          };
          touchpad = {
            tap = _: { };
            "natural-scroll" = _: { };
          };
          "focus-follows-mouse" = _: { };
          "workspace-auto-back-and-forth" = _: { };
          "warp-mouse-to-focus" = _: {
            props = {
              mode = "center-xy-always";
            };
          };
        };

        # ── layout.kdl ──
        layout = {
          gaps = constants.theme.compositor.gap;
          "center-focused-column" = "never";
          "background-color" = "transparent";
          "preset-column-widths" = [
            { proportion = 0.33333; }
            { proportion = 0.5; }
            { proportion = 0.66667; }
          ];
          "focus-ring" = {
            width = 0.1;
          };
          struts = _: { };
        };

        # ── misc.kdl ──
        "prefer-no-csd" = _: { };
        "screenshot-path" = null;
        environment = {
          ELECTRON_OZONE_PLATFORM_HINT = "auto";
          QT_QPA_PLATFORM = "wayland";
          QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
          XDG_SESSION_TYPE = "wayland";
          XDG_CURRENT_DESKTOP = "niri";
          QT_QPA_PLATFORMTHEME = "gtk3";
        };
        debug = {
          "honor-xdg-activation-with-invalid-serial" = _: { };
        };
        "hotkey-overlay" = {
          "skip-at-startup" = _: { };
        };

        # ── rules.kdl ──
        "window-rules" = [
          {
            matches = [ { "app-id" = "^kitty$"; } ];
            "background-effect" = {
              blur = true;
              noise = 0.05;
            };
          }
          {
            "geometry-corner-radius" = constants.theme.compositor.niri.cornerRadius;
            "clip-to-geometry" = true;
          }
          {
            matches = [ { "app-id" = "^cs2$"; } ];
            "open-floating" = true;
          }
          {
            matches = [ { title = "Counter-Strike 2"; } ];
            "open-floating" = true;
          }
        ];
        "layer-rules" = [
          {
            matches = [ { namespace = "^noctalia-wallpaper*"; } ];
            "place-within-backdrop" = true;
          }
        ];

        # ── workspaces.kdl ──
        workspaces = builtins.listToAttrs (
          lib.concatLists (
            lib.mapAttrsToList (
              name: monitor:
              map (workspace: {
                name = workspace;
                value = {
                  "open-on-output" = name;
                };
              }) monitor.workspaces
            ) monitors
          )
        );

        # ── keybinds.kdl ──
        binds =
          spawnBinds
          // mediaBinds
          // workspaceBinds
          // {
            # ===== Simple binds (no props on bind node) =====
            "Mod+Shift+ESCAPE"."show-hotkey-overlay" = _: { };

            # ── Window movement/focus ──
            "Mod+Q"."close-window" = _: { };
            "Mod+Shift+K"."spawn" = [
              "sh"
              "-c"
              "niri msg pick-window | grep PID: | awk '{print \$2}' | xargs kill"
            ];
            "Mod+Left"."focus-column-left" = _: { };
            "Mod+Right"."focus-column-right" = _: { };
            "Mod+Up"."focus-window-up" = _: { };
            "Mod+Down"."focus-window-down" = _: { };
            "Mod+Shift+Left"."move-column-left" = _: { };
            "Mod+Shift+Right"."move-column-right" = _: { };
            "Mod+Shift+UP"."move-window-up" = _: { };
            "Mod+Shift+Down"."move-window-down" = _: { };
            "Mod+Home"."focus-column-first" = _: { };
            "Mod+End"."focus-column-last" = _: { };
            "Mod+CTRL+Home"."move-column-to-first" = _: { };
            "Mod+CTRL+End"."move-column-to-last" = _: { };
            "Mod+CTRL+Left"."focus-monitor-left" = _: { };
            "Mod+CTRL+Right"."focus-monitor-right" = _: { };
            "Mod+CTRL+Up"."focus-workspace-up" = _: { };
            "Mod+CTRL+Down"."focus-workspace-down" = _: { };
            "Mod+Shift+CTRL+Left"."move-column-to-monitor-left" = _: { };
            "Mod+Shift+CTRL+Right"."move-column-to-monitor-right" = _: { };
            "Mod+Shift+CTRL+UP"."move-column-to-monitor-up" = _: { };
            "Mod+Shift+CTRL+Down"."move-column-to-monitor-down" = _: { };

            # ── Mouse/wheel ──
            "Mod+WheelScrollRight"."focus-column-right" = _: { };
            "Mod+WheelScrollLeft"."focus-column-left" = _: { };
            "Mod+CTRL+WheelScrollRight"."move-column-right" = _: { };
            "Mod+CTRL+WheelScrollLeft"."move-column-left" = _: { };
            "Mod+Shift+WheelScrollDown"."focus-column-right" = _: { };
            "Mod+Shift+WheelScrollUp"."focus-column-left" = _: { };
            "Mod+CTRL+Shift+WheelScrollDown"."move-column-right" = _: { };
            "Mod+CTRL+Shift+WheelScrollUp"."move-column-left" = _: { };

            # ── Workspace numbers ──
            "Mod+TAB"."focus-workspace-previous" = _: { };

            # ── Layout ──
            "Mod+D"."maximize-column" = _: { };
            "Mod+CTRL+C"."center-visible-columns" = _: { };
            "Mod+Minus"."set-column-width" = "-10%";
            "Mod+Equal"."set-column-width" = "+10%";
            "Mod+Shift+Minus"."set-window-height" = "-10%";
            "Mod+Shift+Equal"."set-column-width" = "+10%";
            "Mod+W"."fullscreen-window" = _: { };

            # ── Screenshots ──
            "Mod+Shift+Q"."spawn-sh" = ''
              grim -g "$(slurp)" /tmp/qr.png \
              && zbarimg --quiet --raw /tmp/qr.png \
              | xargs xdg-open; rm -f /tmp/qr.png
            '';

            # ===== Binds WITH props on the bind node =====
            # ── hotkey-overlay-title ──
            "Mod+A" = _: {
              props."hotkey-overlay-title" = "Open App Launcher";
              content."spawn-sh" = "noctalia msg panel-toggle launcher";
              # content."spawn-sh" = "vicinae open";
            };
            "Mod+F" = _: {
              props."hotkey-overlay-title" = "Open Browser: Firefox";
              content."spawn" = [ "firefox" ];
            };
            # ── cooldown-ms ──
            "Mod+WheelScrollDown" = _: {
              props."cooldown-ms" = 150;
              content."focus-workspace-down" = _: { };
            };
            "Mod+WheelScrollUp" = _: {
              props."cooldown-ms" = 150;
              content."focus-workspace-up" = _: { };
            };
            "Mod+CTRL+WheelScrollDown" = _: {
              props."cooldown-ms" = 150;
              content."move-column-to-workspace-down" = _: { };
            };
            "Mod+CTRL+WheelScrollUp" = _: {
              props."cooldown-ms" = 150;
              content."move-column-to-workspace-up" = _: { };
            };

            # ── repeat / allow-inhibiting ──
            "Mod+O" = _: {
              props.repeat = false;
              content."toggle-overview" = _: { };
            };
            "Mod+ESCAPE" = _: {
              props."allow-inhibiting" = false;
              content."toggle-keyboard-shortcuts-inhibit" = _: { };
            };

            # ── Power ──
            "CTRL+ALT+Delete"."quit" = _: { };
            "Mod+Shift+P"."power-off-monitors" = _: { };
          };
      };

      # noctalia.kdl is auto-generated at runtime — include it optionally
      extraSettings = [
        {
          include = [
            { optional = true; }
            "${config.my.host.homeDirectory}/.config/niri/noctalia.kdl"
          ];
        }
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    xwayland-satellite
    polkit
  ];
}
