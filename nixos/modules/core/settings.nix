_: {
  flake.nixosModules.settings = { lib, ... }: {
    options.settings = {
      hostname = lib.mkOption {
        type = lib.types.str;
        description = "Machine's hostname";
      };

      username = lib.mkOption {
        type = lib.types.str;
        description = "Primary username for this machine";
      };

      homeDirectory = lib.mkOption {
        type = lib.types.str;
        description = "Home directory path for the primary user";
      };

      timezone = lib.mkOption {
        type = lib.types.str;
        default = "UTC";
        description = "System timezone (e.g. America/New_York, Europe/London)";
      };

      locale = lib.mkOption {
        type = lib.types.str;
        default = "en_US.UTF-8";
        description = "System locale";
      };

      stateVersion = lib.mkOption {
        type = lib.types.str;
        default = "26.05";
        description = "NixOS state version (do not change after install)";
      };

      networking = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable NetworkManager";
      };

      bluetooth = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Bluetooth";
      };

      printing = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable printing (CUPS)";
      };

      sudo = lib.mkOption {
        type = lib.types.submodule {
          options = {
            wheelNeedsPassword = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Whether sudo requires a password for wheel users";
            };
          };
        };
        default = { };
        description = "Sudo configuration";
      };

      audio = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable PipeWire audio (rtkit, ALSA, Pulse, JACK)";
      };

      flatpak = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Flatpak support";
      };

      displayManager = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable SDDM display manager with SilentSDDM theme";
      };

      niri = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable the Niri scrollable-tiling Wayland compositor";
      };

      noctalia = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Noctalia app store and cachix cache";
      };

      nvidia = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable NVIDIA GPU drivers (offload mode for hybrid laptops)";
      };

      kvm = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable KVM virtualization (libvirtd, virt-manager)";
      };

      yubikey = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable YubiKey support (pcscd, udev rules, GPG agent, ykman)";
      };

      nh = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable nh (Nix CLI helper) with system-level flake vars";
      };

      flakeDir = lib.mkOption {
        type = lib.types.str;
        description = "Absolute path to the nixos flake directory (for nh, etc.)";
      };

      efi = lib.mkOption {
        type = lib.types.submodule {
          options = {
            secureBoot = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Whether to use Secure Boot with Lanzaboote (requires enrolling keys)";
            };
            canTouchEfiVariables = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Whether to allow the bootloader to modify EFI variables";
            };
          };
        };
        default = { };
        description = "EFI-related settings";
      };

      users = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              isAdmin = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = "Whether user gets wheel + networkmanager groups";
              };
              homeModule = lib.mkOption {
                type = lib.types.nullOr lib.types.path;
                default = null;
                description = "Path to user's home-manager config (optional)";
              };
            };
          }
        );
        description = "Per user config";
      };
    };
  };
}
