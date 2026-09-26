# assemblies/development.nix — editors and developer tooling.
{
  nixos = { };

  home = {
    imports = [
      ../units/home/editors/zed.nix
      ../units/home/editors/emacs.nix
      ../units/home/editors/neovim.nix
      ../units/home/apps/dev-packages.nix
    ];
  };
}
