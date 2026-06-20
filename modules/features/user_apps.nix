{ self, inputs, ... }:
{
  flake.nixosModules.userApps = { config, pkgs, ... }:
  let
    # Default user, but can be overridden
    userName = config.userName or "legion";
  in {
    options.userName = pkgs.lib.mkOption {
      type = pkgs.lib.types.str;
      default = "legion";
      description = "Username for user applications";
    };

    config.users.users.${userName}.packages = with pkgs; [
      #entertainment
      spotify
      discord
      
      #media
      vlc
      deluge

      #gaming lol
      steam 
      bottles
      gamescope
      gamemode
      heroic
      lutris

      #productivity 
      thunderbird
      obsidian
      tuxedo

      #ai
      pi-coding-agent
    ];
  };
}
