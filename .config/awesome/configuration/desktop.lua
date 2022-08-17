-- Standard awesome library
local awful = require("awful")
local gears = require("gears")
-- Theme handling library
local beautiful = require("beautiful")

local bling = require("modules.bling")
local machi = require("modules.layout-machi")

local screen, tag = _G.screen, _G.tag

local math, table = math, table
local ipairs, tostring = ipairs, tostring

--------------------------------------------------

local widget = require("pretty.ui._widget")

-- Wallpapers
screen.connect_signal("request::wallpaper", function (s)
    if beautiful.wallpaper and gears.filesystem.file_readable(beautiful.wallpaper) then
        awful.wallpaper {
            screen = s,
            bg     = beautiful.bg_normal,
            widget = {
                image      = beautiful.wallpaper,
                resize     = true,
                fit_policy = "fill",
                halign     = "center",
                valign     = "center",
                widget     = widget.imagebox,
            }
        }
    else
        bling.module.tiled_wallpaper("+", s, {
            bg        = beautiful.bg_normal,
            fg        = beautiful.fg_normal,
            font      = beautiful.font_family,
            font_size = math.max(beautiful.font_size, 20),
            padding   = 75,
            zickzack  = false,
        })
    end
end)

-- Layouts
local layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.spiral.dwindle,

    bling.layout.centered,
    bling.layout.equalarea,
}
local machi_layout = machi.layout.create { new_placement_cb = machi.layout.placement.empty, default_cmd = "-" }
for index, layout in ipairs(layouts) do
    machi.editor.nested_layouts[tostring(index)] = layout
end
table.insert(layouts, machi_layout)

tag.connect_signal("request::default_layouts", function ()
    awful.layout.append_default_layouts(layouts)
end)
local tag_names = { "1", "2", "3", "4", "5" }
screen.connect_signal("request::desktop_decoration", function (s)
    awful.tag(tag_names, s, awful.layout.layouts[6])
end)
