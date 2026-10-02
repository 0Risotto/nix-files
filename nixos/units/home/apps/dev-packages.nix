# units/home/apps/dev-packages.nix — development applications
{ lib, pkgs, ... }:
let
  # nixpkgs' `opencode` is still v1 and v2 only ships as a prebuilt Bun binary.
  opencode = pkgs.stdenv.mkDerivation (finalAttrs: {
    pname = "opencode";
    version = "2.0.21";

    src = pkgs.fetchurl {
      url = "https://opencode.ai/files/bin/${finalAttrs.version}/opencode-linux-x64.tar.gz";
      hash = "sha256-1hOl1TTlDXRPmDZy+gBubxIXn+tDoLoUWJ15bNyTmDs=";
    };

    nativeBuildInputs = [ pkgs.makeBinaryWrapper ];

    # The artifact is a Bun-compiled binary: stripping relocates the embedded
    # payload and it will no longer start.
    dontStrip = true;
    dontConfigure = true;
    dontBuild = true;

    # The tarball contains a single file at the root, no directory to unpack.
    dontUnpack = true;

    installPhase = ''
      runHook preInstall

      tar -xzf $src
      install -Dm755 opencode $out/bin/opencode

      # Official builds are linked against FHS glibc; point the interpreter at
      # Nix's dynamic linker so the binary runs without an FHS environment.
      patchelf --set-interpreter "${pkgs.stdenv.cc.bintools.dynamicLinker}" $out/bin/opencode

      # OpenCode shells out to rg. A copy on PATH skips its runtime download.
      wrapProgram $out/bin/opencode \
        --prefix PATH : ${lib.makeBinPath [ pkgs.ripgrep ]} \
        --set OPENCODE_DISABLE_AUTOUPDATE true

      runHook postInstall
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck

      home=$(mktemp -d)
      HOME=$home TMPDIR=$home \
      XDG_CACHE_HOME=$home/.cache \
      XDG_CONFIG_HOME=$home/.config \
      XDG_DATA_HOME=$home/.local/share \
      XDG_STATE_HOME=$home/.local/state \
      OPENCODE_DISABLE_MODELS_FETCH=true \
        $out/bin/opencode --version | grep -F "${finalAttrs.version}"

      runHook postInstallCheck
    '';

    meta = {
      description = "OpenCode v2 AI coding agent for the terminal";
      homepage = "https://opencode.ai";
      downloadPage = "https://opencode.ai/v2/docs";
      license = lib.licenses.mit;
      sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
      platforms = [ "x86_64-linux" ];
      mainProgram = "opencode";
    };
  });
in
{
  home.packages = with pkgs; [
    typst
    tinymist
    obsidian
    pi-coding-agent
    opencode
  ];
}
