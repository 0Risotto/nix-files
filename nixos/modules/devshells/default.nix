_: {
  imports = [
    ./web.nix
    ./rust.nix
    ./go.nix
    ./python.nix
    ./java.nix
    ./devops.nix
    ./backend.nix
  ];

  perSystem =
    { pkgs, config, ... }:
    let
      inherit (config) devShells;
      shells = builtins.removeAttrs devShells [
        "default"
        "all"
        "fullstack"
        "data"
        "cloud"
      ];
    in
    {
      devShells = {
        default = pkgs.mkShell {
          packages = with pkgs; [
            ripgrep
            fd
            jq
            yq
            just
            nix-output-monitor
            nix-tree
            delta
          ];
          shellHook = ''
            exec fish
          '';
        };

        all = pkgs.mkShell {
          inputsFrom = builtins.attrValues shells;
          shellHook = ''
            exec fish
          '';
        };

        fullstack = pkgs.mkShell {
          inputsFrom = with devShells; [
            web
            rust
            go
            java
            backend
          ];
          shellHook = ''
            exec fish
          '';
        };

        data = pkgs.mkShell {
          inputsFrom = with devShells; [
            python
            go
          ];
          shellHook = ''
            exec fish
          '';
        };

        cloud = pkgs.mkShell {
          inputsFrom = with devShells; [
            devops
            go
          ];
          shellHook = ''
            exec fish
          '';
        };
      };
    };
}
