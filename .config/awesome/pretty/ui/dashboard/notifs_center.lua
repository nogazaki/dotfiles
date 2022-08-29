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

return widgets.container {
    {
        {
            markup  = "Notifications",
            font    = "Iosevka 10",
            opacity = 0.6,
            widget  = wibox.widget.textbox,
        },
        spacing = dpi(10),
        layout  = wibox.layout.fixed.vertical,
    },
    paddings = dpi(10),
    bg    = beautiful.accent_color .. "22",
    shape = helpers.ui.rrect(beautiful.border_radius),
}
