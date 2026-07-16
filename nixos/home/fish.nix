_: {
  programs.fish = {
    enable = true;

    shellAbbrs = {
      q = "noctalia";
      nhos = "nh os switch";
      nhhm = "nh home switch";
      nhc = "nh clean all";
    };

    shellAliases = {
      clear = "printf '\\033[2J\\033[3J\\033[1;1H'";
      celar = "printf '\\033[2J\\033[3J\\033[1;1H'";
      claer = "printf '\\033[2J\\033[3J\\033[1;1H'";
      ls = "eza --icons";
      ll = "eza -l --icons";
    };

    interactiveShellInit = ''
      set fish_greeting

      if test "$TERM" = xterm-kitty
        alias ssh 'kitten ssh'
      end

      set -g FLAKE "$HOME/git/dotties/nixos"

      if test "$TERM" != dumb
        starship init fish | source
      end

      if set -q KITTY_INSTALLATION_DIR
        set --global KITTY_SHELL_INTEGRATION no-rc
        source "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_conf.d/kitty-shell-integration.fish"
        set --prepend fish_complete_path "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_completions.d"
      end
    '';

    functions = {
      nixup = {
        body = ''
          cd $FLAKE && nix flake update
        '';
      };
      dev = {
        argumentNames = "args";
        body = ''
          if test (count $args) -eq 0
            nix develop "$FLAKE#default"
          else if string match -qr -- '^(--help|-h|list)$' "$args[1]"
            echo "Available devshells:"
            nix eval "$FLAKE#devShells.x86_64-linux" --apply 'builtins.attrNames' 2>/dev/null \
              | string match -ra '\w+' \
              | while read -l shell
                echo "    $shell"
              end
            echo ""
            echo "Usage:"
            echo "  dev <name>           Enter a single devshell"
            echo "  dev <name> <name>    Combine multiple devshells"
            echo "  dev all              Everything"
            echo "  dev fullstack        web + rust + go + java + backend"
            echo "  dev data             python + go"
            echo "  dev cloud            devops + go"
          else if test (count $args) -eq 1
            nix develop "$FLAKE#"$args[1]
          else
            set -l shellList (string join ' ' $args)
            set -l tmpfile (mktemp /tmp/devshell.XXXXXX.nix)
            echo let >$tmpfile
            echo "  flake = builtins.getFlake \"$FLAKE\";" >>$tmpfile
            echo "  pkgs = import flake.inputs.nixpkgs { system = \"x86_64-linux\"; };" >>$tmpfile
            echo "  shells = with flake.devShells.x86_64-linux; [ $shellList ];" >>$tmpfile
            echo "in pkgs.mkShell {" >>$tmpfile
            echo "  inputsFrom = shells;" >>$tmpfile
            echo "  shellHook = \"exec fish\";" >>$tmpfile
            echo "}" >>$tmpfile
            nix develop -f $tmpfile
            rm $tmpfile
          end
        '';
      };
    };
  };
}
