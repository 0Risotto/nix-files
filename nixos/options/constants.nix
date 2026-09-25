# options/constants.nix — injection points for immutable data, with typed schemas.
{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.my.constants = mkOption {
    type = types.submodule {
      options = {
        identity.flakeSubpath = mkOption {
          type = types.str;
          description = "Path of this flake relative to the user's home directory";
        };

        keyboard = {
          xkb = {
            layout = mkOption { type = types.str; };
            variant = mkOption { type = types.str; };
          };
          compositor = {
            layout = mkOption { type = types.str; };
            options = mkOption { type = types.str; };
          };
        };

        session = {
          path = mkOption { type = types.listOf types.str; };
          variables = mkOption { type = types.attrsOf types.str; };
        };

        theme = {
          fonts = {
            sansSerif = mkOption { type = types.str; };
            monospace = mkOption { type = types.str; };
            serif = mkOption { type = types.str; };
            emoji = mkOption { type = types.str; };
            terminal = mkOption { type = types.str; };
            editor = mkOption { type = types.str; };
            gtk = mkOption { type = types.str; };
          };

          cursor = {
            name = mkOption { type = types.str; };
            size = mkOption { type = types.int; };
          };

          icons.name = mkOption { type = types.str; };

          gtk.theme = mkOption { type = types.str; };

          kitty = {
            opacity = mkOption { type = types.float; };
            backgroundBlur = mkOption { type = types.int; };
            windowMargin = mkOption { type = types.int; };
          };

          compositor = {
            gap = mkOption { type = types.int; };
            windowOpacity = mkOption { type = types.float; };
            niri.cornerRadius = mkOption { type = types.int; };
            umbriel.cornerRadius = mkOption { type = types.int; };
          };
        };
      };
    };
    default = import ../constants/shared.nix;
    description = "Host-independent constants shared by all machines";
  };

  options.my.host = mkOption {
    type = types.submodule {
      options = {
        hostname = mkOption { type = types.str; };
        username = mkOption { type = types.str; };
        homeDirectory = mkOption { type = types.str; };
        timezone = mkOption { type = types.str; };
        locale = mkOption { type = types.str; };
        stateVersion = mkOption { type = types.str; };

        users = mkOption {
          type = types.attrsOf (
            types.submodule {
              options = {
                isAdmin = mkOption {
                  type = types.bool;
                  default = false;
                  description = "Whether user gets wheel + networkmanager groups";
                };
                homeModule = mkOption {
                  type = types.nullOr types.path;
                  default = null;
                  description = "Path to user's home-manager config (optional)";
                };
              };
            }
          );
          default = { };
          description = "Additional users, keyed by name";
        };

        assemblies = mkOption {
          type = types.listOf types.str;
          default = [ ];
          description = "Assemblies composed into this host (assemblies/<name>.nix)";
        };

        compositors = mkOption {
          type = types.listOf (
            types.enum [
              "niri"
              "umbriel"
            ]
          );
          default = [ ];
          description = "Wayland compositors to install and configure";
        };

        boot = {
          initrdAvailableKernelModules = mkOption {
            type = types.listOf types.str;
            default = [ ];
          };
          kernelModules = mkOption {
            type = types.listOf types.str;
            default = [ ];
          };
          zswap = mkOption {
            type = types.bool;
            default = true;
          };
        };

        swap = mkOption {
          type = types.nullOr (
            types.submodule {
              options = {
                device = mkOption { type = types.str; };
                size = mkOption { type = types.int; };
              };
            }
          );
          default = null;
          description = "Swap device; null disables swap";
        };

        disks = {
          root = mkOption { type = types.str; };
          boot = mkOption { type = types.str; };
        };

        monitors = mkOption {
          type = types.attrsOf (
            types.submodule {
              options = {
                position = {
                  x = mkOption {
                    type = types.int;
                    default = 0;
                  };
                  y = mkOption {
                    type = types.int;
                    default = 0;
                  };
                };
                mode = mkOption {
                  type = types.nullOr types.str;
                  default = null;
                };
                workspaces = mkOption {
                  type = types.listOf types.str;
                  default = [ ];
                };
              };
            }
          );
          default = { };
          description = "Outputs, keyed by connector name (e.g. HDMI-A-1)";
        };

        gpu = {
          nvidiaBusId = mkOption {
            type = types.nullOr types.str;
            default = null;
          };
          intelBusId = mkOption {
            type = types.nullOr types.str;
            default = null;
          };
        };

        efi = {
          secureBoot = mkOption {
            type = types.bool;
            default = false;
          };
          canTouchEfiVariables = mkOption {
            type = types.bool;
            default = true;
          };
        };
      };
    };
    default = { };
    description = "Per-host facts, set by hosts/<name>.nix";
  };
}
