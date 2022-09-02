-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

--------------------------------------------------

local animation = require("evil.animation")
local pactl_service = require("evil.pactl")

--------------------------------------------------

local arc = wibox.widget {
    max_value    = 100,
    min_value    = 0,
    values       = { 0, 100 },
    start_angle  = - math.pi / 2,
    thickness    = dpi(3),
    border_width = dpi(2),
    border_color = "#00000000",
    colors       = { beautiful.accent_color, beautiful.accent_color .. "44" },
    widget       = wibox.container.arcchart,
}

pactl_service:connect_signal("sink::updated", function (_, device)
    if not device.default then return end

    for _, channel in pairs(device.volume) do
        local vol = channel.value_percent:match("(%d+)%%")

        if not arc.animation then
            arc.animation = animation {
                initial = { arc.values[1], arc.opacity },
                duration = 0.1,
                update = function (_, pos)
                    arc.values = { pos[1], 100 - pos[1] }
                    arc.opacity = pos[2]
                end
            }
            arc.animation:connect_signal("ended", function () arc.animation = nil end)
        end

        arc.animation.target = { tonumber(vol), device.mute and 0.5 or 1 }

        if channel then break end
    end
end)

return arc
