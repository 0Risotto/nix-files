_: {
  flake.nixosModules.fish =
    {
      config,
      pkgs,
      inputs,
      ...
    }:
    let
      wrap = inputs.nix-wrapper-modules.wrappers.fish.wrap;
      wrappedFish = wrap {
        inherit pkgs;

        shellAliases = {
          clear = "printf '\\033[2J\\033[3J\\033[1;1H'";
          celar = "printf '\\033[2J\\033[3J\\033[1;1H'";
          claer = "printf '\\033[2J\\033[3J\\033[1;1H'";
          ls = "eza --icons";
          ll = "eza -l --icons";
        };

        abbreviations = {
          q = {
            position = "command";
            expansion = "noctalia";
          };
          nhos = {
            position = "command";
            expansion = "nh os switch";
          };
          nhhm = {
            position = "command";
            expansion = "nh home switch";
          };
          nhc = {
            position = "command";
            expansion = "nh clean all";
          };
          ga = {
            position = "command";
            expansion = "git add";
          };
          gaa = {
            position = "command";
            expansion = "git add --all";
          };
          gc = {
            position = "command";
            expansion = "git commit";
          };
          gca = {
            position = "command";
            expansion = "git commit --amend";
          };
          gco = {
            position = "command";
            expansion = "git checkout";
          };
          gcb = {
            position = "command";
            expansion = "git checkout -b";
          };
          gd = {
            position = "command";
            expansion = "git diff";
          };
          gds = {
            position = "command";
            expansion = "git diff --staged";
          };
          gf = {
            position = "command";
            expansion = "git fetch";
          };
          gl = {
            position = "command";
            expansion = "git log --oneline";
          };
          gp = {
            position = "command";
            expansion = "git push";
          };
          gpl = {
            position = "command";
            expansion = "git pull";
          };
          gr = {
            position = "command";
            expansion = "git restore";
          };
          grb = {
            position = "command";
            expansion = "git rebase";
          };
          grem = {
            position = "command";
            expansion = "git remote";
          };
          grh = {
            position = "command";
            expansion = "git reset --hard";
          };
          grs = {
            position = "command";
            expansion = "git restore --staged";
          };
          gst = {
            position = "command";
            expansion = "git status";
          };
          gs = {
            position = "command";
            expansion = "git stash";
          };
          gsp = {
            position = "command";
            expansion = "git stash pop";
          };
          gsl = {
            position = "command";
            expansion = "git stash list";
          };
          gm = {
            position = "command";
            expansion = "git merge";
          };
          gh = {
            position = "command";
            expansion = "gh";
          };
        };

        configFile.content = ''
          set fish_greeting
          set -g fish_color_autosuggestion brblack
          set -g FLAKE "${config.settings.flakeDir}"

          if test "$TERM" = xterm-kitty
            alias ssh 'kitten ssh'
          end

          if test "$TERM" != dumb
            starship init fish | source
          end

          if set -q KITTY_INSTALLATION_DIR
            set --global KITTY_SHELL_INTEGRATION no-rc
            source "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_conf.d/kitty-shell-integration.fish"
            set --prepend fish_complete_path "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_completions.d"
          end

          function nixup
            cd $FLAKE && nix flake update
          end

          function dev
            if test (count $argv) -eq 0
              nix develop "$FLAKE#default"
            else if string match -qr -- '^(--help|-h|list)$' "$argv[1]"
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
            else if test (count $argv) -eq 1
              nix develop "$FLAKE#$argv[1]"
            else
              set -l shellList (string join ' ' $argv)
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
          end
        '';
      };
    in
    {
      environment.systemPackages = [ wrappedFish ];
      users.users.${config.settings.username}.shell = "${wrappedFish}/bin/fish";
    };
}
