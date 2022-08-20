-- Standard awesome library
local awful = require("awful")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")

local capi = require("capi")

local dpi = beautiful.xresources.apply_dpi

--------------------------------------------------

local path = ...

local width = {
    bar = dpi(50),
    panel = dpi(500),
}
local arrange = awful.placement.left + awful.placement.maximize_vertically

capi.screen.connect_signal("request::desktop_decoration", function (s)
    local bar = wibox {
        screen  = s,
        bg      = beautiful.bg_normal .. "CC",
        width   = width.bar,
        visible = true,
        ontop   = true,
        type    = "dock",
    }
    bar:struts { left = width.bar }
    arrange(bar)

    -- Setup widgets
    bar:setup {
        nil,
        nil,
        {
            {
                require(path .. ".clock"),
                {
                    require(path.. ".taglist")(s),
                    left   = dpi(5),
                    right  = dpi(5),
                    widget = wibox.container.margin,
                },
                {
                    require(path .. ".layoutbox")(s),
                    left   = dpi(10),
                    right  = dpi(10),
                    widget = wibox.container.margin,
                },
                expand = "none",
                layout = wibox.layout.align.vertical,
            },
            forced_width = width.bar,
            top          = dpi(10),
            bottom       = dpi(10),
            widget       = wibox.container.margin,
        },
        layout = wibox.layout.align.horizontal,
    }
end)
