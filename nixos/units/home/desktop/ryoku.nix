# units/home/desktop/ryoku.nix — declarative Ryoku compositor overrides for legion.
#
# niri: includes ~/.config/niri/user.kdl last, and niri replaces conflicting
# binds from earlier includes with later ones, so every chord wins over Ryoku's
# generated rebinds.kdl.
# Hyprland: loads ~/.config/hypr/user.lua last, so unbind + bind there wins
# over the shipped catalogue.
# All files are Ryoku "seeds": the materializer only creates them when absent
# and never clobbers them, so home-manager owns them from here on.
#
# Note: the Hub's keybind page and the Super+K cheatsheet still describe
# Ryoku's shipped chords, not these overrides.
{
  my,
  ...
}:
{
  xdg.configFile = {
    "niri/user.kdl".text = ''
      // Host keybinds. Mirrors the pre-Ryoku niri setup as closely as Ryoku's
      // action vocabulary allows. See config_binds.go upstream for the shipped
      // catalogue this file overrides.

      binds {
          // ── Ryoku shell ──
          Super+Shift+Escape hotkey-overlay-title="Hotkey overlay" { show-hotkey-overlay; }
          Super+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }
          Super+I { spawn "ryoku-shell" "hub" "open"; }
          Super+N { spawn "ryoku-shell" "quicksettings"; }
          Super+Shift+L { spawn "ryoku-shell" "quicksettings"; }
          Super+J { spawn "ryoku-shell" "bar-toggle"; }
          Super+Shift+R { spawn "ryoku-shell" "reload"; }
          Super+Ctrl+T { spawn "ryogami" "wallpaper" "ui"; }

          // ── Apps ──
          Super+A { spawn "ryoku-shell" "launcher"; }
          Super+T { spawn "kitty"; }
          Super+C { spawn "zeditor"; }
          Super+X { spawn "emacs"; }
          Super+F { spawn "firefox"; }
          Super+E { spawn "nautilus"; }
          Super+G { spawn "gamescope" "-W" "1920" "-H" "1080" "--" "steam"; }

          // ── Windows / overview / monitors / workspaces ──
          Super+W { fullscreen-window; }
          Super+O repeat=false { toggle-overview; }
          Super+Tab { focus-workspace-previous; }
          Super+Ctrl+Left { focus-monitor-left; }
          Super+Ctrl+Right { focus-monitor-right; }
          Super+Ctrl+Up { focus-workspace-up; }
          Super+Ctrl+Down { focus-workspace-down; }
          Super+Shift+Ctrl+Left { move-column-to-monitor-left; }
          Super+Shift+Ctrl+Right { move-column-to-monitor-right; }
          Super+Shift+Ctrl+Up { move-column-to-monitor-up; }
          Super+Shift+Ctrl+Down { move-column-to-monitor-down; }
          Super+Ctrl+Home { move-column-to-first; }
          Super+Ctrl+End { move-column-to-last; }
          Super+Ctrl+C { center-visible-columns; }
          Super+Minus { set-column-width "-10%"; }
          Super+Equal { set-column-width "+10%"; }
          Super+Shift+Minus { set-window-height "-10%"; }
          Super+Shift+Equal { set-column-width "+10%"; }
          Super+Shift+1 { move-column-to-workspace 1; }
          Super+Shift+2 { move-column-to-workspace 2; }
          Super+Shift+3 { move-column-to-workspace 3; }
          Super+Shift+4 { move-column-to-workspace 4; }
          Super+Shift+5 { move-column-to-workspace 5; }
          Super+Shift+6 { move-column-to-workspace 6; }
          Super+Shift+7 { move-column-to-workspace 7; }
          Super+Shift+8 { move-column-to-workspace 8; }
          Super+Shift+9 { move-column-to-workspace 9; }
          Super+Shift+0 { move-column-to-workspace 10; }

          // ── Mouse wheel ──
          Super+WheelScrollLeft { focus-column-left; }
          Super+WheelScrollRight { focus-column-right; }
          Super+Shift+WheelScrollUp { focus-column-left; }
          Super+Shift+WheelScrollDown { focus-column-right; }
          Super+Ctrl+WheelScrollLeft { move-column-left; }
          Super+Ctrl+WheelScrollRight { move-column-right; }
          Super+Ctrl+Shift+WheelScrollUp { move-column-left; }
          Super+Ctrl+Shift+WheelScrollDown { move-column-right; }
          Super+Ctrl+WheelScrollUp cooldown-ms=150 { move-column-to-workspace-up; }
          Super+Ctrl+WheelScrollDown cooldown-ms=150 { move-column-to-workspace-down; }

          // ── Tools ──
          Super+Shift+E { spawn-sh "hyprpicker -a"; }
          Super+Shift+A { spawn-sh "image-search"; }
          Super+Shift+K { spawn-sh "niri msg pick-window | grep PID: | awk '{print $2}' | xargs kill"; }
          Super+Shift+Q { spawn-sh "grim -g \"$(slurp)\" /tmp/qr.png && zbarimg --quiet --raw /tmp/qr.png | xargs xdg-open; rm -f /tmp/qr.png"; }

          // ── Screenshots: Ryoku's spawn exports only the user QML dir, which drops
          // the system Qt modules (Qt5Compat.GraphicalEffects) that ryoshot needs.
          // Export the system QML path too, as Ryoku's own autostart does.
          Super+Shift+S {
              spawn-sh "env QML_IMPORT_PATH=\"$HOME/.local/lib/qt6/qml:/run/current-system/sw/lib/qt-6/qml\" QML2_IMPORT_PATH=\"$HOME/.local/lib/qt6/qml:/run/current-system/sw/lib/qt-6/qml\" flock -n -o /tmp/ryoshot.lock qs -c ryoshot";
          }
          Print {
              spawn-sh "env QML_IMPORT_PATH=\"$HOME/.local/lib/qt6/qml:/run/current-system/sw/lib/qt-6/qml\" QML2_IMPORT_PATH=\"$HOME/.local/lib/qt6/qml:/run/current-system/sw/lib/qt-6/qml\" flock -n -o /tmp/ryoshot.lock qs -c ryoshot";
          }
          Shift+Print {
              spawn-sh "env QML_IMPORT_PATH=\"$HOME/.local/lib/qt6/qml:/run/current-system/sw/lib/qt-6/qml\" QML2_IMPORT_PATH=\"$HOME/.local/lib/qt6/qml:/run/current-system/sw/lib/qt-6/qml\" flock -n -o /tmp/ryoshot.lock env RYOSHOT_MODE=monitor qs -c ryoshot";
          }

          // ── Session / hardware ──
          Super+Shift+P { power-off-monitors; }
          Ctrl+Alt+Delete { quit; }
          Super+Shift+M { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"; }
          XF86AudioMicMute allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"; }
      }

      // ── Cursor ──
      cursor {
          xcursor-theme "${my.constants.theme.cursor.name}"
          xcursor-size ${toString my.constants.theme.cursor.size}
      }

      // ── Animations (mirrors the pre-Ryoku springs/curves) ──
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

      // ── Layout ──
      layout {
          gaps 5
          center-focused-column "never"
          always-center-single-column false
          background-color "transparent"
          preset-column-widths {
              proportion 0.33333
              proportion 0.5
              proportion 0.66667
          }
          border {
              width 2
          }
          struts
      }

      // ── Input: keyboard layout + pointer behaviour ──
      input {
          keyboard {
              xkb {
                  layout "us,ara"
                  options "grp:alts_toggle"
              }
          }
          touchpad {
              tap
              natural-scroll
          }
          focus-follows-mouse
          workspace-auto-back-and-forth
          warp-mouse-to-focus mode="center-xy-always"
      }

      // ── Misc ──
      prefer-no-csd
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
      hotkey-overlay {
          skip-at-startup
      }

      // ── Window rules (from the pre-Ryoku config); border/radius stay Ryoku's ──
      window-rule {
          match app-id="^kitty$"
          background-effect {
              blur false
          }
      }
      window-rule {
          match app-id="^cs2$"
          open-floating true
      }
      window-rule {
          match title="Counter-Strike 2"
          open-floating true
      }

      // Workspaces 1-9 on the external monitor, 10 on the laptop panel.
      workspace "1" { open-on-output "HDMI-A-2"; }
      workspace "2" { open-on-output "HDMI-A-2"; }
      workspace "3" { open-on-output "HDMI-A-2"; }
      workspace "4" { open-on-output "HDMI-A-2"; }
      workspace "5" { open-on-output "HDMI-A-2"; }
      workspace "6" { open-on-output "HDMI-A-2"; }
      workspace "7" { open-on-output "HDMI-A-2"; }
      workspace "8" { open-on-output "HDMI-A-2"; }
      workspace "9" { open-on-output "HDMI-A-2"; }
      workspace "10" { open-on-output "eDP-1"; }
    '';

    # Same keybind set for the Hyprland session. It is a Ryoku seed (created only
    # when absent), so the home-manager symlink is never clobbered.
    "hypr/user.lua".text = ''
      -- Host keybinds, ported from the pre-Ryoku niri setup (see the parallel
      -- ~/.config/niri/user.kdl, also home-manager owned). Ryoku's Hyprland
      -- config loads this file last, so an unbind + bind here wins over the
      -- shipped catalogue while the rest of Ryoku's binds remain.

      local ws = (os.getenv("HOME") or "") .. "/.config/hypr/scripts/ryoku-workspace"
      local cheatsheet = "pkill -x -f 'qs -c keys' 2>/dev/null || flock -n -o /tmp/ryoku-keys.lock qs -c keys"

      -- Keyboard layout (was niri input.xkb: us,ara with grp:alts_toggle).
      hl.config({
          input = {
              kb_layout = "us,ara",
              kb_variant = "",
              kb_options = "grp:alts_toggle",
          },
      })

      -- Cursor (was niri cursor.xcursor-theme/size).
      hl.config({
          cursor = {
              theme = "${my.constants.theme.cursor.name}",
              size = ${toString my.constants.theme.cursor.size},
          },
      })

      -- Workspaces 1-9 on the external monitor, 10 on the laptop panel.
      for i = 1, 9 do
          hl.workspace_rule({ workspace = tostring(i), monitor = "HDMI-A-2" })
      end
      hl.workspace_rule({ workspace = "10", monitor = "eDP-1" })

      -- ── Ryoku shell ──
      hl.bind("SUPER + SHIFT + Escape", hl.dsp.exec_cmd(cheatsheet))                 -- keybind list (niri hotkey overlay)
      hl.bind("SUPER + I",              hl.dsp.exec_cmd("ryoku-shell hub open"))     -- settings (was noctalia settings)
      hl.unbind("SUPER + N")                                                         -- shipped: editor
      hl.bind("SUPER + N",              hl.dsp.global("ryoku:quicksettings"))        -- control centre (was noctalia)
      hl.bind("SUPER + SHIFT + L",      hl.dsp.global("ryoku:quicksettings"))        -- session menu (was noctalia)
      hl.unbind("SUPER + J")                                                         -- shipped: ryotunes
      hl.bind("SUPER + J",              hl.dsp.exec_cmd("ryoku-shell bar-toggle"))   -- bar toggle (was noctalia)
      hl.bind("SUPER + SHIFT + M",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")) -- mic mute (was noctalia)
      hl.bind("SUPER + SHIFT + R",      hl.dsp.exec_cmd("ryoku-shell reload"))       -- config reload (was noctalia)
      hl.bind("SUPER + CTRL + T",       hl.dsp.exec_cmd("ryogami wallpaper ui"))     -- wallpaper panel (was noctalia)

      -- ── Apps ──
      hl.unbind("SUPER + A")                                                         -- shipped: float-at-size macro
      hl.bind("SUPER + A", hl.dsp.global("ryoku:launcher"))
      hl.unbind("SUPER + T")                                                         -- shipped: group toggle
      hl.bind("SUPER + T", hl.dsp.exec_cmd("kitty"))
      hl.unbind("SUPER + C")                                                         -- shipped: center window
      hl.bind("SUPER + C", hl.dsp.exec_cmd("zeditor"))
      hl.bind("SUPER + X", hl.dsp.exec_cmd("emacs"))
      hl.unbind("SUPER + F")                                                         -- shipped: fullscreen
      hl.bind("SUPER + F", hl.dsp.exec_cmd("firefox"))
      hl.bind("SUPER + G", hl.dsp.exec_cmd("gamescope -W 1920 -H 1080 -- steam"))
      hl.unbind("SUPER + W")                                                         -- shipped: wallpaper picker
      hl.bind("SUPER + W", hl.dsp.window.fullscreen())
      hl.unbind("SUPER + O")                                                         -- shipped: notes
      hl.bind("SUPER + O", hl.dsp.global("ryoku:overview"), { repeating = false })   -- overview (was niri toggle-overview)
      hl.unbind("SUPER + Tab")                                                       -- shipped: shell overview
      hl.bind("SUPER + Tab", hl.dsp.exec_cmd("hyprctl dispatch workspace previous")) -- previous workspace (was niri)

      -- ── Screenshots: Ryoku's shipped bind exports only the user QML dir, which
      -- drops the system Qt modules (Qt5Compat.GraphicalEffects) ryoshot needs.
      local qs_env = "env QML_IMPORT_PATH=\"$HOME/.local/lib/qt6/qml:/run/current-system/sw/lib/qt-6/qml\" QML2_IMPORT_PATH=\"$HOME/.local/lib/qt6/qml:/run/current-system/sw/lib/qt-6/qml\""
      hl.unbind("SUPER + SHIFT + S")
      hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd(qs_env .. " flock -n -o /tmp/ryoshot.lock qs -c ryoshot"))

      -- ── Screenshots / tools ──
      hl.bind("SUPER + SHIFT + E", hl.dsp.exec_cmd("hyprpicker -a"))                 -- colour picker (keeps Ryoku's SUPER+SHIFT+C too)
      hl.unbind("SUPER + SHIFT + A")                                                 -- shipped: recover audio
      hl.bind("SUPER + SHIFT + A", hl.dsp.exec_cmd("image-search"))
      hl.bind("SUPER + SHIFT + Q", hl.dsp.exec_cmd("grim -g \"$(slurp)\" /tmp/qr.png && zbarimg --quiet --raw /tmp/qr.png | xargs xdg-open; rm -f /tmp/qr.png"))
      hl.bind("SUPER + SHIFT + K", hl.dsp.exec_cmd("hyprctl kill"))                  -- kill a window by click (was niri pick-window)

      -- ── Monitors (was Mod+Ctrl+arrows in niri) ──
      hl.unbind("SUPER + CTRL + Left")
      hl.bind("SUPER + CTRL + Left",  hl.dsp.focus({ monitor = "l" }))
      hl.unbind("SUPER + CTRL + Right")
      hl.bind("SUPER + CTRL + Right", hl.dsp.focus({ monitor = "r" }))
      hl.unbind("SUPER + CTRL + Up")
      hl.bind("SUPER + CTRL + Up",    hl.dsp.focus({ monitor = "u" }))
      hl.unbind("SUPER + CTRL + Down")
      hl.bind("SUPER + CTRL + Down",  hl.dsp.focus({ monitor = "d" }))
      hl.bind("SUPER + SHIFT + CTRL + Left",  hl.dsp.window.move({ monitor = "l" }))
      hl.bind("SUPER + SHIFT + CTRL + Right", hl.dsp.window.move({ monitor = "r" }))
      hl.bind("SUPER + SHIFT + CTRL + Up",    hl.dsp.window.move({ monitor = "u" }))
      hl.bind("SUPER + SHIFT + CTRL + Down",  hl.dsp.window.move({ monitor = "d" }))

      -- ── Window size / center (was niri set-column-width/height) ──
      hl.bind("SUPER + minus", hl.dsp.window.resize({ x = -40, y = 0, relative = true }), { repeating = true })
      hl.bind("SUPER + equal", hl.dsp.window.resize({ x = 40, y = 0, relative = true }), { repeating = true })
      hl.bind("SUPER + SHIFT + minus", hl.dsp.window.resize({ x = 0, y = -40, relative = true }), { repeating = true })
      hl.bind("SUPER + SHIFT + equal", hl.dsp.window.resize({ x = 40, y = 0, relative = true }), { repeating = true }) -- old config quirk kept
      hl.bind("SUPER + CTRL + C", hl.dsp.window.center())

      -- ── Workspaces: Super+Shift+N sends and follows (old niri), not silently ──
      for i = 1, 10 do
          local key = i % 10
          hl.unbind("SUPER + SHIFT + " .. key)                                       -- shipped: movesilent
          hl.bind("SUPER + SHIFT + " .. key, hl.dsp.exec_cmd(ws .. " move " .. i))
      end

      -- ── Mouse wheel (was niri column focus/move) ──
      hl.bind("SUPER + SHIFT + mouse_up",   hl.dsp.focus({ direction = "left" }))
      hl.bind("SUPER + SHIFT + mouse_down", hl.dsp.focus({ direction = "right" }))
      hl.bind("SUPER + CTRL + mouse_up",    hl.dsp.window.move({ workspace = "r-1" }))
      hl.bind("SUPER + CTRL + mouse_down",  hl.dsp.window.move({ workspace = "r+1" }))
      hl.bind("SUPER + CTRL + SHIFT + mouse_up",   hl.dsp.window.move({ direction = "left" }))
      hl.bind("SUPER + CTRL + SHIFT + mouse_down", hl.dsp.window.move({ direction = "right" }))

      -- ── Session / hardware ──
      hl.unbind("SUPER + SHIFT + P")                                                 -- shipped: pin window
      hl.bind("SUPER + SHIFT + P", hl.dsp.exec_cmd("hyprctl dispatch dpms toggle")) -- power off monitors (was niri)
      hl.bind("CTRL + ALT + Delete", hl.dsp.exec_cmd("hyprctl dispatch exit"))       -- quit (was niri quit)
      hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
    '';

    # Ryoku's hand-pin seed for displays, loaded after the generated monitors.kdl.
    "niri/monitors_user.kdl".text = ''
      // Fixed layout for the legion displays.
      output "HDMI-A-2" {
          mode "1920x1080@200"
          position x=0 y=0
      }

      output "eDP-1" {
          position x=1920 y=0
      }
    '';
  };
}
