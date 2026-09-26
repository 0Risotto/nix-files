# units/home/editors/zed.nix — Zed editor (vim mode, Catppuccin, language servers)
{ pkgs, ... }:
{
  programs.zed-editor = {
    enable = true;
    defaultEditor = true;

    extraPackages = with pkgs; [
      nixd
      tinymist
      rust-analyzer
      clang-tools
      jdt-language-server
      gopls
      basedpyright
      typescript-language-server
      vscode-langservers-extracted
      yaml-language-server
      tailwindcss-language-server
    ];

    extensions = [
      "nix"
      "typst"
      "java"
      "catppuccin"
      "material-icon-theme"
    ];

    userSettings = {
      vim_mode = true;
      vim.use_system_clipboard = "always";

      theme = {
        mode = "dark";
        dark = "Catppuccin Mocha";
        light = "Catppuccin Latte";
      };
      icon_theme = {
        mode = "dark";
        dark = "Material Icon Theme";
        light = "Material Icon Theme";
      };

      telemetry = {
        metrics = false;
        diagnostics = false;
      };
    };
  };
}
