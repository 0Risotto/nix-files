_: {
  perSystem = { pkgs, ... }: {
    devShells.python = pkgs.mkShell {
      packages = with pkgs; [
        python3
        python3Packages.pip
        python3Packages.virtualenv
        poetry
        ruff
        basedpyright
      ];
      shellHook = ''
        exec fish
      '';
    };
  };
}
