# assemblies/development.nix — editors and developer tooling.
{
  nixos = { };

  home = {
    imports = [
      ../units/home/vscode.nix
      ../units/home/emacs.nix
      ../units/home/dev-packages.nix
    ];
  };
}
