#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── Checks ──────────────────────────────────────────────────────────

if [ ! -f /etc/nixos/hardware-configuration.nix ]; then
  echo "❌ /etc/nixos/hardware-configuration.nix not found."
  echo "   Run 'nixos-generate-config' first."
  exit 1
fi

# ── Extract from hardware-config ─────────────────────────────────────

HW="/etc/nixos/hardware-configuration.nix"

# Extract specific lines/values (strip leading whitespace)
initrd_modules=$(grep "boot.initrd.availableKernelModules" "$HW" | sed 's/.*= \[//;s/\];.*//;s/^[[:space:]]*//')
kvm_modules=$(grep "boot.kernelModules" "$HW" | sed 's/.*= \[//;s/\];.*//;s/^[[:space:]]*//')

# filesystems block (strip leading indent, we re-add it below)
filesystems=$(awk '/^[[:space:]]*fileSystems/,/^[[:space:]]*swapDevices/' "$HW" \
  | head -n -2 | sed 's/^[[:space:]]*//')

# ── Generate hosts/legion.nix ────────────────────────────────────────

HOST_FILE="$REPO_DIR/nixos/hosts/legion.nix"

cat > "$HOST_FILE" << NIXEOF
# hosts/legion.nix
{
  flake.nixosModules.legion =
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

      swapDevices = [ ];
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

      settings = {
        hostname = "legion";
        timezone = "Asia/Amman";
        stateVersion = "26.05";
        nvidia = false;
        displayManager = true;
        niri = true;
        noctalia = true;
        flatpak = true;
        kvm = true;
        efi.secureBoot = false;
        users = {
          legion = {
            isAdmin = true;
            homeModule = ../home/legion.nix;
          };
        };
      };
    };
}
NIXEOF

echo "✔ Generated nixos/hosts/legion.nix"
echo ""
echo "  ═══════════════════════════════════════════════"
echo "  First build — flakes not enabled yet on this"
echo "  system, so pass experimental features once:"
echo "  ═══════════════════════════════════════════════"
echo ""
echo "    sudo nixos-rebuild switch \\"
echo "      --flake $REPO_DIR/nixos#legion \\"
echo "      --option experimental-features 'nix-command flakes'"
echo ""
echo "  After that, just:"
echo "    nh os switch"
