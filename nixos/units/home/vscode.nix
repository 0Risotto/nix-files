{
  my,
  pkgs,
  ...
}:
let
  kanagawa = pkgs.vscode-utils.extensionFromVscodeMarketplace {
    name = "kanagawa";
    publisher = "qufiwefefwoyn";
    version = "1.5.1";
    sha256 = "sha256-AGGioXcK/fjPaFaWk2jqLxovUNR59gwpotcSpGNbj1c=";
  };
in
{
  programs.vscodium = {
    enable = true;
    profiles.default = {
      extensions =
        with pkgs.vscode-extensions;
        [
          myriad-dreamin.tinymist
          jnoortheen.nix-ide
          pkief.material-icon-theme
        ]
        ++ [ kanagawa ];
      userSettings = {
        "window.titleBarStyle" = "custom";
        "workbench.colorTheme" = "Kanagawa";
        "workbench.iconTheme" = "material-icon-theme";
        "editor.fontFamily" = "'${my.constants.theme.fonts.editor}', 'monospace', monospace";
        "editor.fontSize" = 14;
        "editor.fontLigatures" = true;
        "tinymist.serverPath" = "${pkgs.tinymist}/bin/tinymist";
      };
    };
  };
}
