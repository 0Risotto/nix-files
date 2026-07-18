_: {
  flake.nixosModules.starship =
    {
      pkgs,
      inputs,
      ...
    }:
    let
      wrap = inputs.nix-wrapper-modules.wrappers.starship.wrap;
    in
    {
      environment.systemPackages = [
        (wrap {
          inherit pkgs;

          settings = {
            add_newline = false;
            format = ''
              $cmd_duration 󰜥 $directory $git_branch
              $character
            '';
            character = {
              error_symbol = "[   ](bold fg:red)";
              success_symbol = "[   ](bold fg:blue)";
            };
            cmd_duration = {
              format = "[](bold fg:yellow)[󰪢 $duration](bold bg:yellow fg:black)[▌](bold fg:yellow)";
              min_time = 0;
            };
            directory = {
              format = "[▐](bold fg:green)[󰉋 →$path]($style)[▌](bold fg:green)";
              home_symbol = "  ";
              read_only = "  ";
              style = "bg:green fg:black";
              truncation_length = 6;
              truncation_symbol = " ••/";
              substitutions = {
                Desktop = "  ";
                Documents = "  ";
                Downloads = "  ";
                GitHub = " 󰊤 ";
                Music = " 󰎈 ";
                Pictures = "  ";
                Videos = "  ";
              };
            };
            git_branch = {
              format = "󰜥 [▐](bold fg:cyan)[$symbol $branch(:$remote_branch)](fg:black bg:cyan)[▌ ](bold fg:cyan)";
              style = "bg: cyan";
              symbol = "󰘬";
              truncation_length = 12;
              truncation_symbol = "";
            };
            git_commit = {
              commit_hash_length = 4;
              tag_symbol = " ";
            };
            git_state = {
              cherry_pick = "[🍒 PICKING](bold red)";
              format = "[($state( $progress_current of $progress_total))]($style) ";
            };
            git_status = {
              ahead = " 🏎💨 ";
              behind = " 😰 ";
              conflicted = " 🏳 ";
              deleted = " 🗑 ";
              diverged = " 😵 ";
              modified = " 📝 ";
              renamed = " ✍️ ";
              staged = "[++($count)](green)";
              stashed = " 📦 ";
              untracked = " 🤷 ‍";
            };
            hostname = {
              disabled = false;
              format = "[•$hostname](bg:cyan bold fg:black)[▌](bold fg:cyan)";
              ssh_only = false;
              trim_at = ".companyname.com";
            };
            line_break.disabled = false;
            memory_usage = {
              disabled = true;
              style = "bold dimmed green";
              symbol = " ";
              threshold = -1;
            };
            package.disabled = true;
            time = {
              disabled = true;
              format = "🕙[[ $time ]]($style) ";
              time_format = "%T";
            };
            username = {
              disabled = false;
              format = "[▐](bold fg:cyan)[$user]($style)";
              show_always = true;
              style_root = "red bold";
              style_user = "bold bg:cyan fg:black";
            };
          };
        })
      ];
    };
}
