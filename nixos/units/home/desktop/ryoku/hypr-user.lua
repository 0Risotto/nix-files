-- Host settings for Hyprland. Ryoku loads this file last, so these values and
-- keybinds win over the shipped catalogue. Binds live in hypr-binds.lua
-- (generated from lib/keybinds.nix) and are dofile'd at the end.

hl.config({
    input = {
        kb_layout = "@xkbLayout@",
        kb_variant = "",
        kb_options = "@xkbOptions@",
    },
})

hl.config({
    cursor = {
        theme = "@cursorTheme@",
        size = @cursorSize@,
    },
})

-- Workspaces 1-9 on the external monitor, 10 on the panel.
for i = 1, 9 do
    hl.workspace_rule({ workspace = tostring(i), monitor = "@primaryOutput@" })
end
@secondaryRule@

-- Host keybinds.
dofile("@hyprBinds@")
