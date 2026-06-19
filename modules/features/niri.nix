{ self, inputs, ... }:

{
  flake.nixosModules.niri =
    { pkgs, lib, ... }:
    {
      programs.niri = {
        enable = true;
        package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
      };
    };

  perSystem =
    { pkgs, lib, self', ... }:
    {
      packages.myNiri =
        inputs.wrapper-modules.wrappers.niri.wrap {
          inherit pkgs;
          settings = {
            extraConfig = ''
              animations {
                workspace-switch {
                 spring damping-ratio=1.0 stiffness=1000 epsilon=0.0001
                }
                window-open {
                  duration-ms 200
                  curve "ease-out-quad"
                }
                window-close {
                  duration-ms 200
                  curve "ease-out-cubic"
                }
                horizontal-view-movement {
                  spring damping-ratio=1.0 stiffness=900 epsilon=0.0001
                }
                window-movement {
                  spring damping-ratio=1.0 stiffness=800 epsilon=0.0001
                }
                window-resize {
                  spring damping-ratio=1.0 stiffness=1000 epsilon=0.0001
                }
                config-notification-open-close {
                  spring damping-ratio=0.6 stiffness=1200 epsilon=0.001
                }
                screenshot-ui-open {
                  duration-ms 300
                  curve "ease-out-quad"
                }
                overview-open-close {
                  spring damping-ratio=1.0 stiffness=900 epsilon=0.0001
                }
              }

              window-rule {
                geometry-corner-radius 18
                clip-to-geometry true
              }

              window-rule {
                match app-id="^cs2$"     
                open-floating true
              }

              window-rule {
                match title="Counter-Strike 2"
                open-floating true
              }

              layer-rule {
                match namespace="^noctalia-wallpaper*"
                place-within-backdrop true
              }

              hotkey-overlay {
                skip-at-startup
              }

              environment {
                ELECTRON_OZONE_PLATFORM_HINT "auto"
                QT_QPA_PLATFORM "wayland"
                QT_WAYLAND_DISABLE_WINDOWDECORATION "1"
                XDG_SESSION_TYPE "wayland"
                XDG_CURRENT_DESKTOP "niri"
                QT_QPA_PLATFORMTHEME "gtk3"
              }

              debug {
                honor-xdg-activation-with-invalid-serial
              }

              prefer-no-csd
              screenshot-path null   
            '';

	 		  
	layout = {
      gaps = 5;
      center-focused-column = "never";
       background-color = "transparent";
      preset-column-widths = [
        { proportion = 0.33333; }
        { proportion = 0.5; }
        { proportion = 0.66667; }
      ];

      focus-ring = {
        active-color = "#a0c9ff";
        inactive-color = "#111317";
        urgent-color = "#ffb4ab";
        width = 0.1;
      };

      border = {
        active-color = "#a0c9ff";
        inactive-color = "#111317";
        urgent-color = "#ffb4ab";
        width = 0.1;
      };

      shadow = {
        color = "#00000070";
      };

      tab-indicator = {
        active-color = "#a0c9ff";
        inactive-color = "#184977";
        urgent-color = "#ffb4ab";
      };

      insert-hint = {
        color = "#a0c9ff80";
      };

      struts = { };
    };

    recent-windows = {
      highlight = {
        active-color = "#a0c9ff";
        urgent-color = "#ffb4ab";
      };
    };

            outputs = {
              "HDMI-A-1" = {
                mode = "1920x1080@200";
                position = _: {
                  props = {
                    x = 0;
                    y = 0;
                  };
                };
              };
              "eDP-1" = {
                position = _: {
                  props = {
                    x = 1920;
                    y = 0;
                  };
                };
              };
            };

            workspaces = {
              "1".open-on-output = "HDMI-A-1";
              "2".open-on-output = "HDMI-A-1";
              "3".open-on-output = "HDMI-A-1";
              "4".open-on-output = "HDMI-A-1";
              "5".open-on-output = "HDMI-A-1";
              "6".open-on-output = "HDMI-A-1";
              "7".open-on-output = "HDMI-A-1";
              "8".open-on-output = "HDMI-A-1";
              "9".open-on-output = "HDMI-A-1";
              "10".open-on-output = "eDP-1";
            };

            spawn-at-startup = [
              "/usr/lib/polkit-kde-authentication-agent-1"
              (lib.getExe self'.packages.myNoctalia)
            ];

            input = {
              keyboard = {
                xkb = {
                  layout = "us,ara";
                  options = "grp:alts_toggle";
                };
              };
              touchpad = {
                tap = {};
                "natural-scroll" = {};
              };
            };

            "xwayland-satellite" = {
              path = lib.getExe pkgs.xwayland-satellite;
            };

            binds = {
              "Mod+Shift+Escape"."show-hotkey-overlay" = {};

              "Mod+Shift+E"."spawn-sh" = "hyprpicker -a";
              "Mod+C".spawn = "code";
              "Mod+X".spawn = lib.getExe pkgs.emacs;
              "Mod+T".spawn = lib.getExe pkgs.kitty;
              "Mod+A"."spawn-sh" = "${lib.getExe self'.packages.myNoctalia} ipc call launcher toggle";
              "Mod+F".spawn = lib.getExe pkgs.firefox;
              "Mod+L"."spawn-sh" = "${lib.getExe self'.packages.myNoctalia} ipc call lockScreen lock";
              "Mod+Shift+L"."spawn-sh" = "${lib.getExe self'.packages.myNoctalia} ipc call sessionMenu toggle";
              "Mod+E".spawn = lib.getExe pkgs.nautilus;
              "Mod+Ctrl+T"."spawn-sh" = "${lib.getExe self'.packages.myNoctalia} ipc call wallpaper toggle";

              "Mod+I"."spawn-sh" = "${lib.getExe self'.packages.myNoctalia} ipc call settings toggle";
              "Mod+N"."spawn-sh" = "${lib.getExe self'.packages.myNoctalia} ipc call controlCenter toggle";
              "Mod+J"."spawn-sh" = "${lib.getExe self'.packages.myNoctalia} ipc call bar toggle";
              "Mod+Shift+M"."spawn-sh" = "${lib.getExe self'.packages.myNoctalia} ipc call volume muteInput";

              "Mod+Q"."close-window" = {};
              "Mod+Left"."focus-column-left" = {};
              "Mod+Right"."focus-column-right" = {};
              "Mod+Up"."focus-window-up" = {};
              "Mod+Down"."focus-window-down" = {};
              "Mod+Shift+Left"."move-column-left" = {};
              "Mod+Shift+Right"."move-column-right" = {};
              "Mod+Shift+Up"."move-window-up" = {};
              "Mod+Shift+Down"."move-window-down" = {};
              "Mod+Home"."focus-column-first" = {};
              "Mod+End"."focus-column-last" = {};
              "Mod+Ctrl+Home"."move-column-to-first" = {};
              "Mod+Ctrl+End"."move-column-to-last" = {};

              "Mod+Ctrl+Left"."focus-monitor-left" = {};
              "Mod+Ctrl+Right"."focus-monitor-right" = {};
              "Mod+Ctrl+Up"."focus-workspace-up" = {};
              "Mod+Ctrl+Down"."focus-workspace-down" = {};
              "Mod+Shift+Ctrl+Left"."move-column-to-monitor-left" = {};
              "Mod+Shift+Ctrl+Right"."move-column-to-monitor-right" = {};
              "Mod+Shift+Ctrl+Up"."move-column-to-monitor-up" = {};
              "Mod+Shift+Ctrl+Down"."move-column-to-monitor-down" = {};

              "Mod+1"."focus-workspace" = 1;
              "Mod+2"."focus-workspace" = 2;
              "Mod+3"."focus-workspace" = 3;
              "Mod+4"."focus-workspace" = 4;
              "Mod+5"."focus-workspace" = 5;
              "Mod+6"."focus-workspace" = 6;
              "Mod+7"."focus-workspace" = 7;
              "Mod+8"."focus-workspace" = 8;
              "Mod+9"."focus-workspace" = 9;
              "Mod+0"."focus-workspace" = 10;
              "Mod+Shift+1"."move-column-to-workspace" = 1;
              "Mod+Shift+2"."move-column-to-workspace" = 2;
              "Mod+Shift+3"."move-column-to-workspace" = 3;
              "Mod+Shift+4"."move-column-to-workspace" = 4;
              "Mod+Shift+5"."move-column-to-workspace" = 5;
              "Mod+Shift+6"."move-column-to-workspace" = 6;
              "Mod+Shift+7"."move-column-to-workspace" = 7;
              "Mod+Shift+8"."move-column-to-workspace" = 8;
              "Mod+Shift+9"."move-column-to-workspace" = 9;
              "Mod+Shift+0"."move-column-to-workspace" = 10;
              "Mod+Tab"."focus-workspace-previous" = {};

                  
              "XF86AudioRaiseVolume"."spawn-sh" =
                "qs -c noctalia-shell ipc call volume increase";

              "XF86AudioLowerVolume"."spawn-sh" =
                "qs -c noctalia-shell ipc call volume decrease";

              "XF86AudioMute"."spawn-sh" =
                "qs -c noctalia-shell ipc call volume muteOutput";

              "XF86AudioMicMute"."spawn-sh" =
                "qs -c noctalia-shell ipc call volume muteInput";

              "XF86AudioNext"."spawn-sh" =
                "qs -c noctalia-shell ipc call media next";

              "XF86AudioPrev"."spawn-sh" =
                "qs -c noctalia-shell ipc call media previous";

              "XF86AudioPlay"."spawn-sh" =
                "qs -c noctalia-shell ipc call media playPause";

              "XF86AudioPause"."spawn-sh" =
                "qs -c noctalia-shell ipc call media playPause";

              "XF86MonBrightnessUp"."spawn-sh" =
                "qs -c noctalia-shell ipc call brightness increase";

              "XF86MonBrightnessDown"."spawn-sh" =
                "qs -c noctalia-shell ipc call brightness decrease";



              "Mod+D"."maximize-column" = {};
              "Mod+Ctrl+C"."center-visible-columns" = {};
              "Mod+Minus"."set-column-width" = "-10%";
              "Mod+Equal"."set-column-width" = "+10%";
              "Mod+W"."fullscreen-window" = {};

              "Mod+O"."toggle-overview" = {};

              "Mod+Shift+S"."screenshot-screen" = {};

              "Ctrl+Alt+Delete".quit = {};
              "Mod+Shift+P"."power-off-monitors" = {};
            };
          };
        };
    };
}
