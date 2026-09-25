{
  inputs,
  my,
  lib,
  pkgs,
  ...
}:
let
  inherit (my) constants;
  monitors = my.host.monitors;

  keybindCommand =
    bind: if bind.sh != null then "spawn:${bind.sh}" else "spawn:${lib.concatStringsSep " " bind.argv}";

  spawnBinds = builtins.listToAttrs (
    map (bind: {
      name = bind.key;
      value = keybindCommand bind;
    }) constants.keybinds.spawn
  );

  mediaBinds = builtins.listToAttrs (
    map (bind: {
      name = bind.key;
      value = {
        action = "spawn:${bind.command}";
        allow_when_locked = true;
      };
    }) constants.keybinds.media
  );

  workspaceKey = ws: if ws == "10" then "0" else ws;
  workspaceBinds = builtins.listToAttrs (
    builtins.concatMap (ws: [
      {
        name = "Mod+${workspaceKey ws}";
        value = "workspace-switch:\"${ws}\"";
      }
      {
        name = "Mod+Shift+${workspaceKey ws}";
        value = "column-move-to-workspace:\"${ws}\"";
      }
    ]) (lib.concatLists (lib.mapAttrsToList (_: monitor: monitor.workspaces) monitors))
  );

  forceKill = pkgs.writeShellApplication {
    name = "umbriel-force-kill";
    runtimeInputs = [ pkgs.jq ];
    text = ''
      selection="$(umbriel windows --json \
        | jq -r '.[] | select(.pid > 0) | "\(.pid) \(.app_id) — \(.title)"' \
        | noctalia dmenu -p "Kill window" || true)"
      [ -z "$selection" ] && exit 0
      kill "''${selection%% *}"
    '';
  };

  dpmsToggle = pkgs.writeShellApplication {
    name = "umbriel-dpms-toggle";
    text = ''
      state="''${XDG_RUNTIME_DIR:-/tmp}/umbriel-dpms-off"
      if [ -e "$state" ]; then
        umbriel msg dpms-on
        rm -f "$state"
      else
        umbriel msg dpms-off
        touch "$state"
      fi
    '';
  };

  # niri's window open/close animation: scale around the center while fading.
  # Opening scales 0.5 -> 1.0, closing scales 1.0 -> 0.8.
  windowAnimation = pkgs.writeText "umbriel-niri-window.glsl" ''
    vec4 animation(vec2 uv) {
        float p = umbriel_clamped_progress;
        float opening = clamp(umbriel_direction, 0.0, 1.0);
        float visible = mix(1.0 - p, p, opening);
        float scale = mix(mix(1.0, 0.8, p), mix(0.5, 1.0, p), opening);
        vec2 sample_uv = vec2(0.5) + (uv - vec2(0.5)) / scale;
        return umbriel_sample(sample_uv) * visible;
    }
  '';
in
{
  imports = [ inputs.umbriel.homeModules.default ];

  config = lib.mkIf (builtins.elem "umbriel" my.desktop.compositors) {
    home.packages = [
      forceKill
      dpmsToggle
    ];

    programs.umbriel.enable = true;

    programs.umbriel.settings = {
      include.optional.files = [ "noctalia.toml" ];

      general = {
        autostart = [
          "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1"
          "noctalia"
          "vicinae server"
        ];
        mod_key = "Super";
        xwayland = true;
        show_cheatsheet = false;
      };

      environment = {
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
        QT_QPA_PLATFORM = "wayland";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        QT_QPA_PLATFORMTHEME = "gtk3";
      };

      # ── outputs.kdl ──
      output = lib.mapAttrs (
        _: monitor:
        {
          position = [
            monitor.position.x
            monitor.position.y
          ];
          inherit (monitor) workspaces;
        }
        // lib.optionalAttrs (monitor.mode != null) { inherit (monitor) mode; }
      ) monitors;

      workspaces.back_and_forth = true;

      # ── input.kdl ──
      input = {
        keyboard = {
          inherit (constants.keyboard.compositor) layout options;
        };
        touchpad = {
          tap = true;
          natural_scroll = true;
        };
        cursor = {
          theme = constants.theme.cursor.name;
          size = constants.theme.cursor.size;
          follows_focus = true;
        };
        focus.follows_mouse = true;
      };

      # ── layout.kdl ──
      layout = {
        mode = "scrolling";
        gap = constants.theme.compositor.gap;
        width_presets = [
          0.33333
          0.5
          0.66667
        ];
        scrolling = {
          center_focused = "never";
          center_underfull_strip = false;
          default_width_fraction = 0.5;
        };
      };

      # ── misc.kdl ──
      appearance = {
        prefer_no_csd = true;
        corner_radius = constants.theme.compositor.umbriel.cornerRadius;
        #  blur = {
        #    enabled = true;
        #    optimized = true;
        #    passes = 3;
        #   radius = 3;
        #   noise = 0.05;
        #  };
        shadow = {
          enabled = true;
          softness = 10;
        };
      };

      # ── rules.kdl ──
      window_rule = [
        # transparent, blurred windows; later rules can override parts of it
        {
          opacity = constants.theme.compositor.windowOpacity;
          blur = true;
          blur_popups = true;
          blur_optimized = true;
        }
        {
          match.app_id = "^kitty$";
          blur = true;
        }
        {
          match.app_id = "^cs2$";
          default_floating = true;
        }
        {
          match.title = "Counter-Strike 2";
          default_floating = true;
        }
        {
          match.app_id = "^dev.noctalia.Noctalia$";
          default_floating = true;
          default_size = [
            1020
            900
          ];
        }
        {
          match.app_id = "^dev.noctalia.UmbrielSharePicker$";
          default_floating = true;
          default_size = [
            800
            600
          ];
        }
      ];

      layer_rule = [
        {
          match.namespace = "^noctalia-(bar-[^\"]+|notification|dock|panel|attached-panel|osd|desktop-widget-[^\"]*)$";
          blur = true;
          blur_ignore_alpha = 0.5;
          blur_popups = true;
          blur_optimized = false;
        }
      ];

      # ── animation (mirrors the niri springs/curves) ──
      animation = {
        windows_in = {
          enabled = true;
          duration_ms = 200;
          curve = "easeoutquad"; # niri window-open
          style = "none"; # the shader does niri's centered scale + fade
          shader = "${windowAnimation}";
        };
        windows_out = {
          enabled = true;
          duration_ms = 200;
          curve = "easeoutcubic"; # niri window-close
          style = "fade";
          shader = "${windowAnimation}";
        };
        # niri has separate window-movement (800), window-resize (1000) and
        # horizontal-view-movement (900); umbriel merges them into one event
        windows_move = {
          enabled = true;
          curve = "spring:1,900";
        };
        workspaces = {
          enabled = true;
          curve = "spring:1,1000";
        };
        overview = {
          enabled = true;
          curve = "spring:1,900";
          workspace_curve = "spring:1,1000";
        };
      };

      # ── keybinds.kdl ──
      keybinds =
        spawnBinds
        // mediaBinds
        // workspaceBinds
        // {
          # ── Apps / noctalia ──
          "Mod+Shift+Escape" = "cheatsheet-toggle";
          "Mod+Q" = "window-close";
          "Mod+Shift+K" = "spawn:${forceKill}/bin/umbriel-force-kill";
          #"Mod+A" = "spawn:noctalia msg panel-toggle launcher";
          "Mod+A" = "spawn:vicinae open";

          # ── Window/column focus ──
          "Mod+Left" = "window-focus-left";
          "Mod+Right" = "window-focus-right";
          "Mod+Up" = "window-focus-up";
          "Mod+Down" = "window-focus-down";
          "Mod+Home" = "column-focus-first";
          "Mod+End" = "column-focus-last";

          # ── Window/column movement ──
          "Mod+Shift+Left" = "column-move-left";
          "Mod+Shift+Right" = "column-move-right";
          "Mod+Shift+Up" = "window-move-up";
          "Mod+Shift+Down" = "window-move-down";
          "Mod+Ctrl+Home" = "column-move-to-first";
          "Mod+Ctrl+End" = "column-move-to-last";

          # ── Output focus/movement ──
          "Mod+Ctrl+Left" = "output-focus-left";
          "Mod+Ctrl+Right" = "output-focus-right";
          "Mod+Shift+Ctrl+Left" = "column-move-to-output-left";
          "Mod+Shift+Ctrl+Right" = "column-move-to-output-right";
          "Mod+Shift+Ctrl+Up" = "column-move-to-output-up";
          "Mod+Shift+Ctrl+Down" = "column-move-to-output-down";

          # ── Mouse/wheel ──
          "Mod+WheelUp" = {
            action = "workspace-previous";
            cooldown_ms = 150;
          };
          "Mod+WheelDown" = {
            action = "workspace-next";
            cooldown_ms = 150;
          };
          "Mod+Ctrl+WheelUp" = {
            action = "column-move-to-workspace-previous";
            cooldown_ms = 150;
          };
          "Mod+Ctrl+WheelDown" = {
            action = "column-move-to-workspace-next";
            cooldown_ms = 150;
          };
          "Mod+WheelLeft" = "window-focus-left";
          "Mod+WheelRight" = "window-focus-right";
          "Mod+Shift+WheelUp" = "window-focus-left";
          "Mod+Shift+WheelDown" = "window-focus-right";
          "Mod+Ctrl+WheelLeft" = "column-move-left";
          "Mod+Ctrl+WheelRight" = "column-move-right";
          "Mod+Ctrl+Shift+WheelUp" = "column-move-left";
          "Mod+Ctrl+Shift+WheelDown" = "column-move-right";

          # ── Workspaces (quoted names force name lookup) ──
          "Mod+Ctrl+Up" = "workspace-previous";
          "Mod+Ctrl+Down" = "workspace-next";
          "Mod+Tab" = "workspace-focus-last";

          # ── Layout ──
          "Mod+D" = "window-toggle-maximize";
          "Mod+Ctrl+C" = "column-center";
          "Mod+Minus" = "window-modify-width:-0.1";
          "Mod+Equal" = "window-modify-width:0.1";
          "Mod+Shift+Minus" = "window-modify-height:-0.1";
          "Mod+Shift+Equal" = "window-modify-height:0.1";
          "Mod+W" = "window-toggle-fullscreen";

          # ── Overview ──
          "Mod+O" = {
            action = "overview-toggle";
            repeat = false;
          };

          # ── Screenshots ──
          "Mod+Shift+Q" =
            "spawn:grim -g \"$(slurp)\" /tmp/qr.png && zbarimg --quiet --raw /tmp/qr.png | xargs xdg-open; rm -f /tmp/qr.png";

          # ── Session / monitors ──
          "Ctrl+Alt+Delete" = "session-quit";
          "Mod+Escape" = "submap:reset";
          "Mod+Shift+P" = "spawn:${dpmsToggle}/bin/umbriel-dpms-toggle";
        };
    };
  };
}
