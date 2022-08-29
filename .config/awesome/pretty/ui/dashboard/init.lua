-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

--------------------------------------------------

return wibox.widget {
    require(... .. ".header"),
    {
        {
            require(... .. ".stats"),
            {
                {
                    nil,
                    {
                        require(... .. ".notifs_center"),
                        bottom = dpi(10),
                        widget = wibox.container.margin,
                    },
                    require(... .. ".weather"),
                    layout = wibox.layout.align.vertical,
                },
                left   = dpi(10),
                widget = wibox.container.margin,
            },
            layout  = wibox.layout.align.horizontal,
        },
        top    = dpi(10),
        bottom = dpi(10),
        widget = wibox.container.margin,
    },
    {
        require(... .. ".players"),
        require(... .. ".settings"),
        spacing = dpi(10),
        layout  = wibox.layout.fixed.vertical,
    },
    layout = wibox.layout.align.vertical,
}
