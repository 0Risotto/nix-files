# constants/shared.nix — host-independent values.
# Pure data: no config, no lib, no pkgs, no host conditionals.
{
  identity = {
    flakeSubpath = "git/dotties/nixos";
  };

  keyboard = {
    xkb = {
      layout = "us";
      variant = "";
    };
    compositor = {
      layout = "us,ara";
      options = "grp:alts_toggle";
    };
  };

  # Shared bind data; compositor units adapt it to niri KDL / umbriel TOML.
  keybinds = {
    spawn = [
      {
        key = "Mod+Shift+E";
        sh = "hyprpicker -a";
      }
      {
        key = "Mod+C";
        argv = [ "codium" ];
      }
      {
        key = "Mod+I";
        sh = "noctalia msg settings-toggle";
      }
      {
        key = "Mod+N";
        sh = "noctalia msg panel-toggle control-center";
      }
      {
        key = "Mod+J";
        sh = "noctalia msg bar-toggle";
      }
      {
        key = "Mod+Shift+M";
        sh = "noctalia msg mic-mute";
      }
      {
        key = "Mod+Shift+R";
        sh = "noctalia msg config-reload";
      }
      {
        key = "Mod+Ctrl+T";
        sh = "noctalia msg panel-toggle wallpaper";
      }
      {
        key = "Mod+X";
        argv = [ "emacs" ];
        title = "Open emacs";
      }
      {
        key = "Mod+T";
        argv = [ "kitty" ];
        title = "Open Terminal: Kitty";
      }
      {
        key = "Mod+F";
        argv = [ "firefox" ];
        title = "Open Browser: Firefox";
      }
      {
        key = "Mod+E";
        argv = [ "nautilus" ];
        title = "File Manager: Nautilus";
      }
      {
        key = "Mod+G";
        argv = [
          "gamescope"
          "-W"
          "1920"
          "-H"
          "1080"
          "--"
          "steam"
        ];
        title = "Open Steam: gamescope";
      }
      {
        key = "Mod+L";
        sh = "noctalia msg session lock";
        title = "Lock Screen: noctalia lock";
      }
      {
        key = "Mod+Shift+L";
        sh = "noctalia msg panel-toggle session";
        title = "Session Menu: noctalia sessionMenu";
      }
      {
        key = "Mod+Shift+S";
        sh = "noctalia msg screenshot-region";
      }
    ];

    media = [
      {
        key = "XF86AudioRaiseVolume";
        command = "noctalia msg volume-up";
      }
      {
        key = "XF86AudioLowerVolume";
        command = "noctalia msg volume-down";
      }
      {
        key = "XF86AudioMute";
        command = "noctalia msg volume-mute";
      }
      {
        key = "XF86AudioMicMute";
        command = "noctalia msg mic-mute";
      }
      {
        key = "XF86AudioNext";
        command = "noctalia msg media next";
      }
      {
        key = "XF86AudioPrev";
        command = "noctalia msg media previous";
      }
      {
        key = "XF86AudioPlay";
        command = "noctalia msg media toggle";
      }
      {
        key = "XF86AudioPause";
        command = "noctalia msg media toggle";
      }
      {
        key = "XF86MonBrightnessUp";
        command = "noctalia msg brightness-up";
      }
      {
        key = "XF86MonBrightnessDown";
        command = "noctalia msg brightness-down";
      }
    ];
  };

  session = {
    path = [
      "$HOME/.local/bin"
      "$HOME/.npm-global/bin"
    ];
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      PAGER = "less";
      NIXPKGS_ALLOW_UNFREE = "1";
    };
  };

  theme = {
    fonts = {
      sansSerif = "Inter";
      monospace = "Roboto Mono";
      serif = "Noto Serif";
      emoji = "Noto Color Emoji";
      terminal = "JetBrains Mono Nerd Font";
      editor = "JetBrains Mono";
      gtk = "Adwaita Sans 11";
    };

    cursor = {
      name = "Bibata-Modern-Classic";
      size = 24;
    };

    icons = {
      name = "Flat-Remix-Blue-Dark";
    };

    gtk = {
      theme = "Adwaita-dark";
    };

    kitty = {
      opacity = 0.95;
      backgroundBlur = 4;
      windowMargin = 11;
    };

    compositor = {
      gap = 5;
      windowOpacity = 0.91;
      niri.cornerRadius = 15;
      umbriel.cornerRadius = 18;
    };
  };
}
