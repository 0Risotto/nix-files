#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
HOSTS_DIR="$REPO_DIR/nixos/modules/hosts"
HOME_DIR="$REPO_DIR/nixos/home"
STATE_VERSION="26.05"

# ── Checks ──────────────────────────────────────────────────────────────

if [ ! -f "$REPO_DIR/flake.nix" ]; then
  echo "❌ Run this script from inside the dotties repo."
  exit 1
fi

if [ ! -f /etc/nixos/hardware-configuration.nix ]; then
  echo "❌ /etc/nixos/hardware-configuration.nix not found."
  echo "   Run 'nixos-generate-config' first, or install NixOS."
  exit 1
fi

# ── Prompts ─────────────────────────────────────────────────────────────

read -rp "Hostname: "                          hostname
read -rp "Timezone [UTC]: "                     timezone
timezone="${timezone:-UTC}"
read -rp "Primary username: "                   username

echo ""
echo "Optional features (y/N):"
read -rp "  NVIDIA GPU? "                       has_nvidia
read -rp "  Secure Boot (Lanzaboote)? "         has_secureboot
read -rp "  Flatpak? "                          has_flatpak
read -rp "  KVM/libvirt + virt-manager? "        has_kvm
read -rp "  Printing (CUPS)? "                   has_printing
read -rp "  Bluetooth? "                         has_bluetooth

# Normalise booleans
nvidia=$(       [[ "$has_nvidia" =~ ^[yY] ]]     && echo "true"  || echo "false")
secureboot=$(   [[ "$has_secureboot" =~ ^[yY] ]] && echo "true"  || echo "false")
flatpak=$(      [[ "$has_flatpak" =~ ^[yY] ]]    && echo "true"  || echo "false")
kvm=$(          [[ "$has_kvm" =~ ^[yY] ]]        && echo "true"  || echo "false")
printing=$(     [[ "$has_printing" =~ ^[yY] ]]   && echo "true" || echo "false")
bluetooth=$(    [[ "$has_bluetooth" =~ ^[yY] ]]  && echo "true" || echo "false")

# Detect CPU vendor for KVM kernel module
if grep -q "GenuineIntel" /proc/cpuinfo; then
  kvm_module="kvm-intel"
elif grep -q "AuthenticAMD" /proc/cpuinfo; then
  kvm_module="kvm-amd"
else
  kvm_module="kvm-intel"
fi

# ── Create host directory ───────────────────────────────────────────────

host_dir="$HOSTS_DIR/$hostname"
if [ -d "$host_dir" ]; then
  echo "❌ Host directory already exists: $host_dir"
  exit 1
fi
mkdir -p "$host_dir"
echo "✔ Created $host_dir"

# ── Generate hardware.nix ───────────────────────────────────────────────
# Inlines the auto-generated /etc/nixos/hardware-configuration.nix directly
# into the flake module so it can be imported as self.nixosModules.<host>Hardware.

# Use a temp awk file to avoid quoting hell inside the bash group command
awk_script="$host_dir/.extract-hw.awk"
cat > "$awk_script" << 'AWKEOF'
/^#/ { next }
/^{.*\.\.\..*}:$/ { next }
/^[[:space:]]*$/ { next }
first == 0 { first = 1; next }
{ lines[++n] = $0 }
END { for (i = 1; i < n; i++) print lines[i] }
AWKEOF

{
  echo "_: { config, lib, ... }: {"
  echo "  flake.nixosModules.${hostname}Hardware = { modulesPath, ... }: {"

  awk -f "$awk_script" /etc/nixos/hardware-configuration.nix | sed 's/^/    /'

  echo "    boot.kernelModules = lib.mkDefault [ \"${kvm_module}\" ];"
  echo "  };"
  echo "};"
} > "$host_dir/hardware.nix"
rm "$awk_script"
echo "✔ Generated hardware.nix (inlined from /etc/nixos/hardware-configuration.nix)"

# ── Generate configuration.nix ──────────────────────────────────────────

cat > "$host_dir/configuration.nix" << CFG_EOF
{ self, ... }:

{
  flake.nixosModules.${hostname}Configuration =
    { ... }:
    {
      imports = [
        self.nixosModules.${hostname}Hardware
        self.nixosModules.nvidia
        self.nixosModules.efi
      ];

      settings = {
        hostname = "${hostname}";
        timezone = "${timezone}";
        stateVersion = "${STATE_VERSION}";
        audio = true;
        displayManager = true;
        niri = true;
        noctalia = true;
        flatpak = ${flatpak};
        kvm = ${kvm};
        printing = ${printing};
        bluetooth = ${bluetooth};
        nvidia = ${nvidia};
        efi.secureBoot = ${secureboot};
        users = {
          ${username} = {
            isAdmin = true;
            homeModule = ../../../home/${username}.nix;
          };
        };
      };
    };
}
CFG_EOF
echo "✔ Generated configuration.nix"

# ── Generate home-manager stub ──────────────────────────────────────────

if [ ! -f "$HOME_DIR/${username}.nix" ]; then
  cat > "$HOME_DIR/${username}.nix" << HOME_EOF
_: {
  imports = [
    ./packages.nix
    ./compositor.nix
  ];
}
HOME_EOF
  echo "✔ Created home/${username}.nix (edit to personalise)"
else
  echo "⏭  home/${username}.nix already exists, skipping"
fi

# ── Summary ─────────────────────────────────────────────────────────────

echo ""
echo "═══════════════════════════════════════════════"
echo "  Done!  Host '$hostname' is ready."
echo "═══════════════════════════════════════════════"
echo ""
echo "  Review & tweak:"
echo "    $host_dir/configuration.nix"
echo "    $host_dir/hardware.nix"
echo "    $HOME_DIR/${username}.nix"
echo ""
echo "  Then build:"
echo "    sudo nixos-rebuild switch --flake $REPO_DIR#$hostname"
echo ""
