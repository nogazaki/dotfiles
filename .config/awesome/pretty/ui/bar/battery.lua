-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local helpers = require("helpers")

--------------------------------------------------

local upower = require("evil.upower")

local bar = wibox.widget {
    max_value        = 100,
    value            = 50,
    border_width     = dpi(1),
    paddings         = dpi(2),
    shape            = helpers.ui.rrect(dpi(3)),
    color            = beautiful.fg_normal,
    background_color = "#00000000",
    border_color     = beautiful.fg_normal,
    widget           = wibox.widget.progressbar,
}
local knob = wibox.widget {
    orientation = "vertical",
    thickness   = dpi(1),
    span_ratio  = 0.6,
    widget      = wibox.widget.separator,
}
local battery = wibox.widget {
    bar,
    knob,
    spacing = dpi(1),
    layout  = wibox.layout.fixed.horizontal,
}

upower:connect_signal("battery::update", function (_, device)
    bar.value = device.percentage

    if device.state == upower.states.charging or device.state == upower.states.fully_charged then
        bar.color = beautiful.xcolor2
    else
        bar.color = beautiful.fg_normal
    end
end)

bar.fit = function (_, _, width, height) return width - dpi(2), height end
knob.fit = function (self, _, _, height) return self.thickness, height end
battery.fit = function (_, _, width) return width, width * 0.55 end

return battery
