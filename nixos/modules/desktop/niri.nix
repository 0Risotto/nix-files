_: {
  flake.nixosModules.niri =
    { config, pkgs, lib, inputs, ... }:
    let
      wrap = inputs.nix-wrapper-modules.wrappers.niri.wrap;
    in
    lib.mkIf config.settings.niri {
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
            "spawn-at-startup" = [ [ "vicinae" "server" ] ];

            # ── cursor.kdl ──
            cursor = {
              "xcursor-theme" = "Bibata-Modern-Classic";
              "xcursor-size" = 24;
            };

            # ── display.kdl ──
            outputs."HDMI-A-1" = {
              position = _: {
                props = {
                  x = 0;
                  y = 0;
                };
              };
              mode = "1920x1080@200";
            };
            outputs."eDP-1" = {
              position = _: {
                props = {
                  x = 1920;
                  y = 0;
                };
              };
            };

            # ── input.kdl ──
            input = {
              "keyboard"."xkb" = {
                layout = "us,ara";
                options = "grp:alts_toggle";
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
              gaps = 5;
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
                "geometry-corner-radius" = 0;
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
              map (n: {
                name = toString n;
                value = { "open-on-output" = "HDMI-A-1"; };
              }) (lib.range 1 9)
              ++ [
                {
                  name = "10";
                  value = { "open-on-output" = "eDP-1"; };
                }
              ]
            );

            # ── keybinds.kdl ──
            binds = {
              # ===== Simple binds (no props on bind node) =====
              "Mod+Shift+ESCAPE"."show-hotkey-overlay" = _: { };
              "Mod+Shift+E"."spawn-sh" = "hyprpicker -a";
              "Mod+C"."spawn" = [ "code" ];
              "Mod+I"."spawn-sh" = "noctalia msg settings-toggle";
              "Mod+N"."spawn-sh" = "noctalia msg panel-toggle control-center";
              "Mod+J"."spawn-sh" = "noctalia msg bar-toggle";
              "Mod+Shift+M"."spawn-sh" = "noctalia msg mic-mute";
              "Mod+Shift+R"."spawn-sh" = "noctalia msg config-reload";
              "Mod+Ctrl+T"."spawn-sh" = "noctalia msg panel-toggle wallpaper";

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
              "Mod+1"."focus-workspace" = 1;
              "Mod+2"."focus-workspace" = 2;
              "Mod+3"."focus-workspace" = 3;
              "Mod+4"."focus-workspace" = 4;
              "Mod+5"."focus-workspace" = 5;
              "Mod+6"."focus-workspace" = 6;
              "Mod+7"."focus-workspace" = 7;
              "Mod+8"."focus-workspace" = 8;
              "Mod+9"."focus-workspace" = 9;
              "Mod+0"."focus-workspace" = "10";
              "Mod+Shift+1"."move-column-to-workspace" = 1;
              "Mod+Shift+2"."move-column-to-workspace" = 2;
              "Mod+Shift+3"."move-column-to-workspace" = 3;
              "Mod+Shift+4"."move-column-to-workspace" = 4;
              "Mod+Shift+5"."move-column-to-workspace" = 5;
              "Mod+Shift+6"."move-column-to-workspace" = 6;
              "Mod+Shift+7"."move-column-to-workspace" = 7;
              "Mod+Shift+8"."move-column-to-workspace" = 8;
              "Mod+Shift+9"."move-column-to-workspace" = 9;
              "Mod+Shift+0"."move-column-to-workspace" = "10";
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
              "Mod+Shift+S"."spawn-sh" = "noctalia msg screenshot-region";
              "Mod+Shift+Q"."spawn-sh" = ''
                grim -g "$(slurp)" /tmp/qr.png \
                && zbarimg --quiet --raw /tmp/qr.png \
                | xargs xdg-open; rm -f /tmp/qr.png
              '';

              # ===== Binds WITH props on the bind node =====
              # ── hotkey-overlay-title ──
              "Mod+X" = _: {
                props."hotkey-overlay-title" = "Open emacs";
                content."spawn" = [ "emacs" ];
              };
              "Mod+T" = _: {
                props."hotkey-overlay-title" = "Open Terminal: Kitty";
                content."spawn" = [ "kitty" ];
              };
              "Mod+A" = _: {
                props."hotkey-overlay-title" = "Open App Launcher";
                content."spawn-sh" = "vicinae open";
              };
              "Mod+F" = _: {
                props."hotkey-overlay-title" = "Open Browser: Firefox";
                content."spawn" = [ "firefox" ];
              };
              "Mod+L" = _: {
                props."hotkey-overlay-title" = "Lock Screen: noctalia lock";
                content."spawn-sh" = "noctalia msg session lock";
              };
              "Mod+Shift+L" = _: {
                props."hotkey-overlay-title" = "Session Menu: noctalia sessionMenu";
                content."spawn-sh" = "noctalia msg panel-toggle session";
              };
              "Mod+E" = _: {
                props."hotkey-overlay-title" = "File Manager: Nautilus";
                content."spawn" = [ "nautilus" ];
              };

              # ── allow-when-locked ──
              "XF86AudioRaiseVolume" = _: {
                props."allow-when-locked" = true;
                content."spawn-sh" = "noctalia msg volume-up";
              };
              "XF86AudioLowerVolume" = _: {
                props."allow-when-locked" = true;
                content."spawn-sh" = "noctalia msg volume-down";
              };
              "XF86AudioMute" = _: {
                props."allow-when-locked" = true;
                content."spawn-sh" = "noctalia msg volume-mute";
              };
              "XF86AudioMicMute" = _: {
                props."allow-when-locked" = true;
                content."spawn-sh" = "noctalia msg mic-mute";
              };
              "XF86AudioNext" = _: {
                props."allow-when-locked" = true;
                content."spawn-sh" = "noctalia msg media next";
              };
              "XF86AudioPrev" = _: {
                props."allow-when-locked" = true;
                content."spawn-sh" = "noctalia msg media previous";
              };
              "XF86AudioPlay" = _: {
                props."allow-when-locked" = true;
                content."spawn-sh" = "noctalia msg media toggle";
              };
              "XF86AudioPause" = _: {
                props."allow-when-locked" = true;
                content."spawn-sh" = "noctalia msg media toggle";
              };
              "XF86MonBrightnessUp" = _: {
                props."allow-when-locked" = true;
                content."spawn-sh" = "noctalia msg brightness-up";
              };
              "XF86MonBrightnessDown" = _: {
                props."allow-when-locked" = true;
                content."spawn-sh" = "noctalia msg brightness-down";
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
                "${config.settings.homeDirectory}/.config/niri/noctalia.kdl"
              ];
            }
          ];
        };
      };

      environment.systemPackages = with pkgs; [
        xwayland-satellite
        polkit
      ];
    };
}
