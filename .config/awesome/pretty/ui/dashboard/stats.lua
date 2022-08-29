local capi = require("capi")
-- Standard awesome library
local awful = require("awful")
local gears = require("gears")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
-- Notification library
local naughty = require("naughty")
-- Declarative object management
local ruled = require("ruled")
local menubar = require("menubar")
-- Modules
local bling = require("modules.bling")
local machi = require("modules.layout-machi")

local helpers = require("helpers")

--------------------------------------------------

local widgets = require("pretty.ui._widgets")

local function set_value(self, value)
    self.text:set_markup_silently(tostring(value) .. "%")
    self.arc.value = value
end
local function set_icon(self, icon)
    self.arc.icon:set_markup_silently(helpers.string.colorize(icon, self.color))
end
local arc_widget = function (icon, color)
    color = color or beautiful.accent_color

    local ret = wibox.widget {
        nil,
        {
            {
                id     = "icon",
                markup = helpers.string.colorize(icon, color),
                font   = "FiraCode Nerd Font Mono 25",
                align  = "center",
                widget = wibox.widget.textbox,
            },
            id           = "arc",
            max_value    = 100,
            min_value    = 0,
            value        = 0,
            thickness    = dpi(5),
            start_angle  = - math.pi / 2,
            bg           = color .. "44",
            colors       = { color },
            forced_width = dpi(60),
            widget       = wibox.container.arcchart,
        },
        {
            id     = "text",
            markup = "...",
            font   = "Iosevka 10",
            align  = "center",
            widget = wibox.widget.textbox,
        },
        spacing = dpi(5),
        layout  = wibox.layout.fixed.vertical,
    }
    ret.set_value = set_value
    ret.set_icon = set_icon
    ret.color = color

    return ret
end
local cpu = arc_widget("﬙", beautiful.xcolor6)
local ram = arc_widget("", beautiful.xcolor4)
local temperator = arc_widget("", beautiful.xcolor1)
local gpu = arc_widget("", beautiful.xcolor2)

return widgets.container {
    {
        cpu,
        ram,
        temperator,
        gpu,
        arc_widget("", beautiful.xcolor3),
        arc_widget("", beautiful.xcolor5),
        spacing = dpi(20),
        layout = wibox.layout.flex.vertical,
    },
    bg       = beautiful.accent_color .. "22",
    shape    = helpers.ui.rrect(beautiful.border_radius),
    paddings = dpi(10),
}
