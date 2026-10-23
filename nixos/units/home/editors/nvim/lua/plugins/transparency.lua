-- Transparent background: let the terminal's opacity show through instead of
-- painting tokyonight's Normal background. Handles Normal, NormalNC, floats,
-- sign column and statusline groups.
return {
  { "folke/tokyonight.nvim", opts = { transparent = true } },
}
