-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")

local helpers = require("helpers")

--------------------------------------------------

local clock = require("evil.clock")

local function set_markup(widget, text)
    widget:set_markup_silently(helpers.string.colorize(text, beautiful.accent_color))
end
local hour = wibox.widget {
    font   = beautiful.gtk_font_family .. " 17",
    align  = "center",
    valign = "center",
    widget = wibox.widget.textbox,
}
set_markup(hour, "...")
hour:connect_signal("property::text", set_markup)
local minute = wibox.widget {
    font    = beautiful.gtk_font_family .. " 17",
    align   = "center",
    valign  = "center",
    opacity = 0.5,
    widget  = wibox.widget.textbox,
}
set_markup(minute, "...")
minute:connect_signal("property::text", set_markup)

clock:connect_signal("property::hour", function (_, new_value)
    hour:set_text(string.format("%02d", new_value))
end)
clock:connect_signal("property::min", function (_, new_value)
    minute:set_text(string.format("%02d", new_value))
end)

return wibox.widget {
    hour,
    minute,
    layout = wibox.layout.fixed.vertical,
}
