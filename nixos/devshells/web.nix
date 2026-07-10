_: {
  perSystem = { pkgs, ... }: {
    devShells.web = pkgs.mkShell {
      packages = with pkgs; [
        typescript
        typescript-language-server
        tailwindcss-language-server
        prettierd
        eslint_d
        prisma
      ];
      shellHook = ''
        exec fish
      '';
    };
  };
}
