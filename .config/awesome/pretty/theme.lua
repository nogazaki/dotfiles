-- Standard awesome library
local gears = require("gears")
-- Theme handling library
local beautiful = require("beautiful")

local helpers = require("helpers")

local dpi = beautiful.xresources.apply_dpi

--------------------------------------------------

local theme = {}

-- {{{ Get Xresources and GTK theme variables
for key, value in pairs(beautiful.xresources.get_current_theme()) do
	theme["x" .. key] = value
end
for key, value in pairs(beautiful.gtk.get_theme_variables()) do
	if gears.color.parse_color(value) then value = value:sub(1, 7) end
	theme["gtk_" .. key] = value
end
-- }}}

theme.profile_pic = os.getenv("HOME") .. "/Pictures/.personalize/avatar.png"
theme.wallpaper   = os.getenv("HOME") .. "/Pictures/.personalize/wallpaper/[ouro_kronii]_asmr.png"

theme.icon_theme = "Dracula"

theme.font_family = theme.gtk_font_family
theme.font_size   = theme.gtk_font_size
theme.font        = theme.font_family .. " " .. theme.font_size

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
local layout_icon_path = os.getenv("HOME") .. "/.config/awesome/pretty/assets/layouts/"
-- Default layouts
theme.layout_fairh      = layout_icon_path .. "fairh.svg"
theme.layout_fairv      = layout_icon_path .. "fairv.svg"
theme.layout_floating   = layout_icon_path .. "floating.svg"
theme.layout_magnifier  = layout_icon_path .. "magnifier.svg"
theme.layout_max        = layout_icon_path .. "max.svg"
theme.layout_fullscreen = layout_icon_path .. "fullscreen.svg"
theme.layout_tilebottom = layout_icon_path .. "tilebottom.svg"
theme.layout_tileleft   = layout_icon_path .. "tileleft.svg"
theme.layout_tile       = layout_icon_path .. "tile.svg"
theme.layout_tiletop    = layout_icon_path .. "tiletop.svg"
theme.layout_spiral     = layout_icon_path .. "spiral.svg"
theme.layout_dwindle    = layout_icon_path .. "dwindle.svg"
theme.layout_cornernw   = layout_icon_path .. "cornernw.svg"
theme.layout_cornerne   = layout_icon_path .. "cornerne.svg"
theme.layout_cornersw   = layout_icon_path .. "cornersw.svg"
theme.layout_cornerse   = layout_icon_path .. "cornerse.svg"
-- Bling
theme.layout_mstab		= layout_icon_path .. "mstab.svg"
theme.layout_centered   = layout_icon_path .. "centered.svg"
theme.layout_vertical   = layout_icon_path .. "vertical.svg"
theme.layout_horizontal = layout_icon_path .. "horizontal.svg"
theme.layout_equalarea  = layout_icon_path .. "equalarea.svg"
theme.layout_deck       = layout_icon_path .. "deck.svg"
-- machi
theme.layout_machi      = layout_icon_path .. "machi.svg"
-- }}}

-- {{{ Layouts variables
theme.column_count        = 1
theme.master_width_factor = 0.75
theme.master_fill_policy  = "expand"
theme.master_count        = 1
-- }}}

-- {{{ Systray
theme.bg_systray           = theme.bg_normal
theme.systray_icon_spacing = dpi(5)
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
