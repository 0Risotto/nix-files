{ inputs, ... }: {
  flake.nixosModules.kitty =
    {
      pkgs,
      config,
      ...
    }:
    let
      wrap = inputs.nix-wrapper-modules.wrappers.kitty.wrap;
    in
    {
      environment.systemPackages = [
        (wrap {
          inherit pkgs;

          font = {
            name = "JetBrains Mono Nerd Font";
            size = 11.0;
          };

          settings = {
            confirm_os_window_close = 0;
            cursor_shape = "beam";
            cursor_trail = 1;
            shell = "herdr";
            window_margin_width = 11;
          };

          keybindings = {
            "ctrl+c" = "copy_or_interrupt";
            "ctrl+0" = "change_font_size all 0";
            "ctrl+equal" = "change_font_size all +1";
            "ctrl+minus" = "change_font_size all -1";
            "ctrl+plus" = "change_font_size all +1";
            "ctrl+underscore" = "change_font_size all -1";
            "ctrl+kp_0" = "change_font_size all 0";
            "ctrl+kp_add" = "change_font_size all +1";
            "ctrl+kp_subtract" = "change_font_size all -1";
            "page_up" = "scroll_page_up";
            "page_down" = "scroll_page_down";
          };

          extraConfig = ''
            include ${config.settings.homeDirectory}/.config/kitty/themes/noctalia.conf
          '';
        })
      ];
    };
}
