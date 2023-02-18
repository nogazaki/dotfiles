-- Standard awesome library
local gears = require("gears")
-- Theme handling library
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local helpers = require("helpers")

--------------------------------------------------

local theme = {}

-- Get Xresources and GTK theme variables
for key, value in pairs(beautiful.xresources.get_current_theme()) do
    theme["x" .. key] = value
end
for key, value in pairs(beautiful.gtk.get_theme_variables()) do
    if gears.color.parse_color(value) then value = value:sub(1, 7) end
    theme["gtk_" .. key] = value
end

local assets_extensions = { "", ".png", ".jpg", ".svg" }
-- assets directory as table
theme.assets = setmetatable(
    { _path = gears.filesystem.get_configuration_dir() .. "pretty/assets/"},
    {
        __index = function (self, index)
            local path = self._path .. index
            if gears.filesystem.dir_readable(path) then
                return setmetatable({ _path = path .. "/"}, getmetatable(self))
            end
            for _, ext in ipairs(assets_extensions) do
                if gears.filesystem.file_readable(path .. ext) then
                    return path .. ext
                end
            end
        end
    }
)

theme.profile_pic = os.getenv("HOME") .. "/Pictures/.personalize/avatar.png"
theme.wallpaper   = os.getenv("HOME") .. "/Pictures/.personalize/wallpaper/[ouro_kronii]_asmr.png"
-- theme.wallpaper   = os.getenv("HOME") .. "/Pictures/.personalize/wallpaper/catppuccin/os/arch-black-4k.png"

theme.icon_theme = "Dracula"

theme.font_family = theme.gtk_font_family
theme.font_size   = theme.gtk_font_size
theme.font        = theme.font_family .. " " .. theme.font_size
theme.font_height = beautiful.get_font_height(theme.font)

theme.useless_gap             = dpi(3)
theme.gap_single_client       = true
theme.maximized_honor_padding = true

theme.accent_color = theme.xcolor4

theme.bg_normal   = theme.gtk_bg_color
theme.fg_normal   = theme.gtk_fg_color
theme.bg_focus    = theme.gtk_selected_bg_color
theme.fg_focus    = theme.gtk_selected_fg_color
theme.bg_urgent   = theme.gtk_warning_bg_color
theme.fg_urgent   = theme.gtk_warning_fg_color
theme.bg_minimize = theme.bg_normal
theme.fg_minimize = theme.fg_normal

theme.border_width        = dpi(theme.gtk_button_border_width)
theme.border_radius       = dpi(theme.gtk_button_border_radius)
theme.border_color        = theme.gtk_button_border_color
theme.border_color_normal = theme.gtk_wm_border_unfocused_color
theme.border_color_active = theme.gtk_wm_border_focused_color

-- {{{ Hotkeys popup
theme.hotkeys_bg               = theme.bg_normal .. "AA"
theme.hotkeys_fg               = theme.fg_normal
theme.hotkeys_border_width     = theme.border_width
theme.hotkeys_border_color     = theme.border_color
theme.hotkeys_shape            = helpers.ui.rrect(theme.border_radius)
theme.hotkeys_modifiers_fg     = theme.xcolor4
theme.hotkeys_font             = "Fira Code 10"
theme.hotkeys_description_font = theme.font_family .. " 12"
theme.hotkeys_group_margin     = dpi(50)
-- }}}

-- {{{ Layout icons
-- Default layouts
theme.layout_fairh      = theme.assets.layouts.fairh
theme.layout_fairv      = theme.assets.layouts.fairv
theme.layout_floating   = theme.assets.layouts.floating
theme.layout_magnifier  = theme.assets.layouts.magnifier
theme.layout_max        = theme.assets.layouts.max
theme.layout_fullscreen = theme.assets.layouts.fullscreen
theme.layout_tilebottom = theme.assets.layouts.tilebottom
theme.layout_tileleft   = theme.assets.layouts.tileleft
theme.layout_tile       = theme.assets.layouts.tile
theme.layout_tiletop    = theme.assets.layouts.tiletop
theme.layout_spiral     = theme.assets.layouts.spiral
theme.layout_dwindle    = theme.assets.layouts.dwindle
theme.layout_cornernw   = theme.assets.layouts.cornernw
theme.layout_cornerne   = theme.assets.layouts.cornerne
theme.layout_cornersw   = theme.assets.layouts.cornersw
theme.layout_cornerse   = theme.assets.layouts.cornerse
-- Bling
theme.layout_mstab		= theme.assets.layouts.mstab
theme.layout_centered   = theme.assets.layouts.centered
theme.layout_vertical   = theme.assets.layouts.vertical
theme.layout_horizontal = theme.assets.layouts.horizontal
theme.layout_equalarea  = theme.assets.layouts.equalarea
theme.layout_deck       = theme.assets.layouts.deck
-- machi
theme.layout_machi      = theme.assets.layouts.machi
-- }}}

-- {{{ Layouts variables
theme.column_count        = 1
theme.master_width_factor = 0.5
theme.master_fill_policy  = "expand"
theme.master_count        = 1
-- }}}

-- {{{ Systray
theme.bg_systray           = theme.bg_normal
theme.systray_icon_spacing = dpi(5)
-- }}}

-- {{{ Taglist
theme.taglist_bg_occupied = theme.bg_focus
theme.taglist_bg_urgent   = theme.bg_urgent
theme.taglist_bg_empty    = theme.fg_normal .. "88"
-- }}}

-- {{{ Tooltip
theme.tooltip_border_color = theme.fg_normal
theme.tooltip_bg           = theme.bg_normal
theme.tooltip_fg           = theme.fg_normal
theme.tooltip_font         = theme.font
theme.tooltip_border_width = dpi(1)
theme.tooltip_opacity      = 0.9
theme.tooltip_gaps         = 4
-- theme.tooltip_shape        = nil
theme.tooltip_align        = "left"
-- }}}

return theme
