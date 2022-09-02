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

--------------------------------------------------

local icons = {
	["01d"] = { icon = "", color = beautiful.xcolor3 }, -- clear sky
	["01n"] = { icon = "", color = beautiful.xcolor4 },
	["02d"] = { icon = "", color = beautiful.xcolor3 }, -- few clouds
	["02n"] = { icon = "", color = beautiful.xcolor4 },
	["03d"] = { icon = "", color = beautiful.xcolor6 }, -- scattered clouds
	["03n"] = { icon = "", color = beautiful.xcolor6 },
	["04d"] = { icon = "", color = beautiful.xcolor6 }, -- broken clouds
	["04n"] = { icon = "", color = beautiful.xcolor6 },
	["09d"] = { icon = "", color = beautiful.xcolor6 }, -- shower rain
	["09n"] = { icon = "", color = beautiful.xcolor6 },
	["10d"] = { icon = "", color = beautiful.xcolor3 }, -- rain
	["10n"] = { icon = "", color = beautiful.xcolor4 },
	["11d"] = { icon = "", color = beautiful.xcolor1 }, -- thunderstorm
	["11n"] = { icon = "", color = beautiful.xcolor1 },
	["13d"] = { icon = "", color = beautiful.xcolor7 }, -- snow
	["13n"] = { icon = "", color = beautiful.xcolor7 },
	["50d"] = { icon = "", color = beautiful.xcolor5 }, -- mist
	["50n"] = { icon = "", color = beautiful.xcolor5 },
    ["999"] = { icon = "", color = beautiful.xcolor1, flag = true }, -- unknown
}
setmetatable(icons, {
	__index = function (self) return self["999"] end
})

local description = wibox.widget {
    markup  = "Unavailable",
    font    = beautiful.gtk_font_family .. " 12",
    opacity = 0.5,
    widget  = wibox.widget.textbox,
}
local temperature = wibox.widget {
    markup = "...",
    font   = beautiful.gtk_font_family .. " 25",
    widget = wibox.widget.textbox,
}
local icon = wibox.widget {
    markup = icons["unknown"].icon,
    font   = "FiraCode Nerd Font Mono 40",
    widget = wibox.widget.textbox,
}
description.forced_height = beautiful.get_font_height(description.font)
temperature.forced_height = beautiful.get_font_height(temperature.font)
icon.forced_height        = beautiful.get_font_height(icon.font)

return widgets.container {
    {
        {
            description,
            temperature,
            spacing = dpi(3),
            layout  = wibox.layout.fixed.vertical,
        },
        nil,
        icon,
        layout = wibox.layout.align.horizontal,
    },
    paddings = dpi(10),
    bg       = beautiful.accent_color .. "22",
    shape    = helpers.ui.rrect(beautiful.border_radius),
}
