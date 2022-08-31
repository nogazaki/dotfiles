local capi = require("capi")
-- Standard awesome library
local awful = require("awful")
local gears = require("gears")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local helpers = require("helpers")

--------------------------------------------------

local animation = require("evil.animation")
local pactl = require("evil.pactl")

local icon = wibox.widget {
    markup = "",
    font   = "FiraCode Nerd Font Mono 22",
    align  = "center",
    widget = wibox.widget.textbox,
}
icon.forced_width = beautiful.get_font_height(icon.font)
local slider = wibox.widget {
    handle_shape     = gears.shape.circle,
    handle_color     = beautiful.fg_normal,
    handle_width     = dpi(7),
    bar_shape        = gears.shape.rounded_bar,
    bar_height       = dpi(3),
    bar_color        = beautiful.fg_normal .. "44",
    bar_active_color = beautiful.fg_normal,
    value            = 30,
    minimum          = 0,
    maximum          = 100,
    cursor           = "hand1",
    forced_width     = dpi(200),
    forced_height    = dpi(10),
    widget           = wibox.widget.slider,
    buttons          = {
        awful.button {
            modifiers = {},
            button    = 4,
            on_press  = function () pactl:sink_volume_down(1) end,
        },
        awful.button {
            modifiers = {},
            button    = 5,
            on_press  = function () pactl:sink_volume_up(1) end,
        },
    },
}
local text = wibox.widget {
    markup = "00",
    font   = "Iosevka 15",
    align  = "center",
    widget = wibox.widget.textbox,
}
text.forced_width = beautiful.get_font_height(text.font) * 1.5

local volume_popup = awful.popup {
    type    = "notification",
    screen  = capi.mouse.screen,
    visible = false,
    ontop   = true,
    placement = function (popup)
        awful.placement.bottom(popup, {
            honor_workarea = true,
            honor_padding  = true,
            offset         = { y = - 150 },
        })
    end,
    bg           = beautiful.bg_normal,
    border_width = dpi(1),
    border_color = beautiful.fg_normal,
    widget       = {
        {
            icon,
            {
                slider,
                halign = "center",
                widget = wibox.container.place,
            },
            text,
            spacing = dpi(10),
            layout  = wibox.layout.fixed.horizontal,
        },
        margins = dpi(10),
        widget  = wibox.container.margin,
    },
}
function volume_popup:show()
    if self.timer then self.timer:stop(); self.timer = nil end
    self.visible = true
    if self == capi.mouse.current_wibox then return end
    self.timer = gears.timer.start_new(2, function ()
        self.timer = nil; self.visible = false
    end)
end
volume_popup.animation = animation {
    initial = { slider.value, helpers.color.hex_to_rgba(beautiful.fg_normal) },
    duration = 0.1,
    update = function (_, pos)
        slider.value = pos[1]

        local color = helpers.color.rgba_to_hex(pos[2]):sub(1, 7)
        volume_popup.border_color = color
        volume_popup.fg = color
        slider.handle_color = color
        slider.bar_color = color .. "44"
        slider.bar_active_color = color
    end
}
volume_popup:connect_signal("mouse::enter", function (self)
    if self.timer then self.timer:stop(); self.timer = nil end
end)
volume_popup:connect_signal("mouse::leave", volume_popup.show)

slider:connect_signal("property::value", function ()
    volume_popup.animation._private.pos[1] = slider.value
    text:set_markup_silently(string.format("%02.0f", slider.value))
end)
slider:connect_signal("property::value::mouse_set", function (_, value)
    pactl:sink_set_volume(math.floor(value + 0.5))
end)

local old = { index = -1, port = "", vol = -1, mute = -1 }

pactl:connect_signal("sink::updated", function (_, device)
    if not device.default then return end

    local mute = device.mute and 1 or 0
    local vol
    for _, channel in pairs(device.volume) do
        vol = channel.value_percent:match("(%d+)%%")
        if channel then break end
    end

    if old.index == device.index
        and old.port == device.active_port
        and old.vol == tonumber(vol)
        and old.mute == mute
    then return end

    local type
    for _, port in pairs(device.ports) do
        if port.name == device.active_port then type = port.type break end
    end

    local color = device.mute and beautiful.fg_normal or beautiful.accent_color
    volume_popup.animation.target = { tonumber(vol), helpers.color.hex_to_rgba(color) }

    icon:set_markup_silently (
        type:match(gears.string.query_to_pattern("speaker"))
        and (device.mute and "遼" or "蓼")
        or (device.mute and "ﳌ" or "")
    )

    if old.index ~= -1 then volume_popup:show() end
    old.index = device.index; old.port = device.active_port; old.vol = tonumber(vol); old.mute = mute
end)

return volume_popup
