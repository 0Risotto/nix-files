_: {
  perSystem = { pkgs, ... }: {
    devShells.devops = pkgs.mkShell {
      packages = with pkgs; [
        docker-compose
        kubectl
        k9s
        ansible
        hcloud
        ssm-session-manager-plugin
      ];
      shellHook = ''
        exec fish
      '';
    };
  };
}
