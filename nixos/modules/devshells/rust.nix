_: {
  perSystem = { pkgs, ... }: {
    devShells.rust = pkgs.mkShell {
      packages = with pkgs; [
        rustc
        cargo
        clippy
        rust-analyzer
        rustfmt
        cargo-tauri
        trunk
      ];
      shellHook = ''
        exec fish
      '';
    };
  };
}
