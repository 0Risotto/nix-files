#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ ! -f /etc/nixos/hardware-configuration.nix ]; then
  echo "Error: /etc/nixos/hardware-configuration.nix not found."
  echo "  Run 'nixos-generate-config' first."
  exit 1
fi

echo "[1/5] Reading hardware config..."

HW="/etc/nixos/hardware-configuration.nix"
initrd_modules=$(grep "boot.initrd.availableKernelModules" "$HW" | sed 's/.*= \[//;s/\];.*//;s/^[[:space:]]*//')
kvm_modules=$(grep "boot.kernelModules" "$HW" | sed 's/.*= \[//;s/\];.*//;s/^[[:space:]]*//')
filesystems=$(awk '/^[[:space:]]*fileSystems/,/^[[:space:]]*swapDevices/' "$HW" \
  | head -n -2 | sed 's/^[[:space:]]*//')

echo "[2/5] Gathering identity..."

read -r -p "  Hostname [legion]: " HOSTNAME
HOSTNAME="${HOSTNAME:-legion}"
read -r -p "  Username [${HOSTNAME}]: " USERNAME
USERNAME="${USERNAME:-$HOSTNAME}"
echo -n "  Password: "
HASHED=$(mkpasswd)
HASHED="${HASHED//$/\$}"
echo

echo "[3/5] Writing host file..."

cat > "$REPO_DIR/nixos/hosts/${HOSTNAME}.nix" << NIXEOF
# hosts/${HOSTNAME}.nix
_: let
  hostSettings = {
    hostname = "${HOSTNAME}";
    username = "${USERNAME}";
    timezone = "Asia/Amman";
    stateVersion = "26.05";
    nvidia = false;
    displayManager = true;
    niri = true;
    noctalia = true;
    flatpak = true;
    kvm = true;
    efi.secureBoot = false;
  };
in {
  flake.nixosModules.${HOSTNAME} =
    {
      config,
      lib,
      modulesPath,
      ...
    }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      boot.initrd.availableKernelModules = [ ${initrd_modules} ];
      boot.kernelModules = [ ${kvm_modules} ];
      hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

$(echo "$filesystems" | sed 's/^/      /')

      swapDevices = [{
        device = "/swapfile";
        size = 8192;
      }];

      boot.zswap.enable = true;
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

      settings = hostSettings;

      users.users.${USERNAME}.hashedPassword = "${HASHED}";
    };

  flake.hostSettings.${HOSTNAME} = hostSettings;
}
NIXEOF

echo "[4/5] Staging changes for NixOS build..."
cd "$REPO_DIR"
git add -A

echo "[5/5] Building NixOS..."
cd "$REPO_DIR/nixos"
sudo nixos-rebuild switch --flake ".#${HOSTNAME}" --option experimental-features "nix-command flakes"
sudo nixos-rebuild switch --flake ".#${HOSTNAME}"

echo "Done. After this, just run: nh os switch"
