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
  };

  session = {
    path = [
      "$HOME/.local/bin"
      "$HOME/.npm-global/bin"
    ];
    variables = {
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
      opacity = 1.0;
      backgroundBlur = 0;
      windowMargin = 11;
    };
  };
}
