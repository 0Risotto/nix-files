_: {
  perSystem = { pkgs, ... }: {
    devShells.backend = pkgs.mkShell {
      packages = with pkgs; [
        jdk
        maven
        go
        rustc
        cargo
        python3
        python3Packages.pip
        docker-compose
        kubectl
        jq
        yq
        grpcurl
        postgresql
        redis
      ];
      shellHook = ''
        exec fish
      '';
    };
  };
}
