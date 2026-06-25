_: {
  perSystem = { pkgs, ... }: {
    devShells.java = pkgs.mkShell {
      packages = with pkgs; [
        jdk
        maven
        gradle
        spring-boot-cli
        jdt-language-server
      ];
      shellHook = ''
        exec fish
      '';
    };
  };
}
