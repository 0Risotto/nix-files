# Personal fish additions. Ryoku's own ~/.config/fish/config.fish sources this
# file last and never touches it, so the shell stack itself (colors,
# ryoku-fastfetch, starship, zoxide, fzf, eza aliases) stays Ryoku's while the
# pre-Ryoku conveniences below survive.

set -g FLAKE "@flakeDir@"

fish_add_path ~/.config/emacs/bin

if test "$TERM" = xterm-kitty
    alias ssh 'kitten ssh'
end

abbr --add nhos --position command 'nh os switch'
abbr --add nhhm --position command 'nh home switch'
abbr --add nhc --position command 'nh clean all'
abbr --add ga --position command 'git add'
abbr --add gaa --position command 'git add --all'
abbr --add gc --position command 'git commit'
abbr --add gca --position command 'git commit --amend'
abbr --add gco --position command 'git checkout'
abbr --add gcb --position command 'git checkout -b'
abbr --add gd --position command 'git diff'
abbr --add gds --position command 'git diff --staged'
abbr --add gf --position command 'git fetch'
abbr --add gl --position command 'git log --oneline'
abbr --add gp --position command 'git push'
abbr --add gpl --position command 'git pull'
abbr --add gr --position command 'git restore'
abbr --add grb --position command 'git rebase'
abbr --add grem --position command 'git remote'
abbr --add grh --position command 'git reset --hard'
abbr --add grs --position command 'git restore --staged'
abbr --add gst --position command 'git status'
abbr --add gs --position command 'git stash'
abbr --add gsp --position command 'git stash pop'
abbr --add gsl --position command 'git stash list'
abbr --add gm --position command 'git merge'
abbr --add gh --position command 'gh'
abbr --add q --position command 'ryoku-shell hub open'

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
                echo "  $shell"
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
