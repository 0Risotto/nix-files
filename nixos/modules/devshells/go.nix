_: {
  perSystem = { pkgs, ... }: {
    devShells.go = pkgs.mkShell {
      packages = with pkgs; [
        go
        gopls
        golangci-lint
        gotools
      ];
      shellHook = ''
        exec fish
      '';
    };
  };
}
