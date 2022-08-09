-- Standard awesome library
local awful = require("awful")
local gears = require("gears")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")

local bling = require("modules.bling")
local machi = require("modules.layout-machi")

local screen, tag = _G.screen, _G.tag

local math, table = math, table
local ipairs, tostring = ipairs, tostring

--------------------------------------------------

-- Wallpapers
local cairo = require("lgi").cairo
screen.connect_signal("request::wallpaper", function (s)
    if gears.filesystem.file_readable(beautiful.wallpaper) then
        local wallpaper = cairo:ImageSurface(s.geometry.width, s.geometry.height)

        local source = gears.surface.load_uncached(beautiful.wallpaper)
        local w, h = gears.surface.get_size(source)

        local aspect_w = s.geometry.width / w
        local aspect_h = s.geometry.height / h
        aspect_w = math.max(aspect_w, aspect_h)
        aspect_h = math.max(aspect_w, aspect_h)
        local scaled_width = s.geometry.width / aspect_w
        local scaled_height = s.geometry.height / aspect_h

        local cr = cairo.Context(wallpaper)
        cr:scale(aspect_w, aspect_h)
        cr:translate((scaled_width - w) / 2, (scaled_height - h) / 2)
        cr:set_source_surface(source, 0, 0)
        cr.operator = cairo.Operator.SOURCE
        cr:paint()
        source:finish()

        awful.wallpaper {
            screen = s,
            bg     = beautiful.bg_normal,
            widget = {
                image  = (cr.status == "SUCCESS") and wallpaper or beautiful.wallpaper,
                resize = true,
                halign = "center",
                valign = "center",
                widget = wibox.widget.imagebox,
            }
        }
    else
        bling.module.tiled_wallpaper("+", s, {
            bg        = beautiful.bg_normal,
            fg        = beautiful.fg_normal,
            font      = beautiful.font_family,
            font_size = math.max(beautiful.font_size, 15),
            padding   = 100,
            zickzack  = true,
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
