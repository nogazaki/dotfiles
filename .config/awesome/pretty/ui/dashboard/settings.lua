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

local mod = require("configuration.bindings.mod")

local widgets = require("pretty.ui._widgets")

local animation_service = require("evil.animation")
local pactl_service = require("evil.pactl")
local network_service = require("evil.network")

--------------------------------------------------

local setting_button = function (icon, text, on_release)
    text = wibox.widget {
        markup = text,
        font   = "Iosevka 9",
        align  = "center",
        widget = wibox.widget.textbox,
    }
    local ret = widgets.button.state {
        {
            {
                markup = icon,
                font   = "FiraCode Nerd Font Mono 20",
                align  = "center",
                widget = wibox.widget.textbox,
            },
            text,
            layout  = wibox.layout.fixed.vertical,
        },
        paddings = dpi(10),
        bg       = beautiful.accent_color .. "22",
        fg_on    = beautiful.fg_focus,
        shape    = helpers.ui.rrect(beautiful.border_radius),
        on_button_release = on_release,
    }
    ret.text = text

    return ret
end
local slider = function (icon)
    icon = "<span font_desc='FiraCode Nerd Font Mono 15'>" .. (icon or "") .. "</span>"
    local text = wibox.widget {
        markup = icon,
        font   = "Iosevka Bold 9",
        align  = "center",
        widget = wibox.widget.textbox,
    }
    text.forced_width = beautiful.get_font_height(text.font) * 1.5
    local bar = wibox.widget {
        handle_width     = 0,
        bar_shape        = helpers.ui.prrect(beautiful.border_radius, false, true, false, true),
        bar_color        = beautiful.accent_color .. "22",
        bar_active_color = beautiful.accent_color,
        value            = 30,
        minimum          = 0,
        maximum          = 100,
        cursor           = "hand1",
        widget           = wibox.widget.slider,
    }

    local ret = wibox.widget {
        widgets.container {
            text,
            shape = helpers.ui.prrect(beautiful.border_radius, true, false, true, false),
            fg = beautiful.bg_normal,
            bg = beautiful.accent_color,
        },
        bar,
        spacing       = dpi(2),
        forced_height = dpi(20),
        layout        = wibox.layout.fixed.horizontal,
    }

    ret.animation = animation_service {
        initial = { bar.value, 1 },
        duration = 0.1,
        update = function (_, pos)
            bar.value = pos[1]
            bar.bar_active_color = beautiful.accent_color .. string.format("%02x", math.floor(pos[2] * 255 + 0.5))
        end,
    }
    bar:connect_signal("property::value", function (_, value)
        if ret.timer then ret.timer:stop(); ret.timer = nil end
        text:set_markup_silently(string.format("%02.f", value))
        ret.timer = gears.timer.start_new(2, function ()
            ret.timer = nil
            text:set_markup_silently(icon)
        end)
    end)

    ret.text = text
    ret.bar = bar
    return ret
end

local wireless = setting_button("", "Wireless")
local wireless_panel = require("pretty.ui.panels.wireless")
wireless:connect_signal("button::trigger", function (_, _, _, button_id, mods)
    if mods and #mods == 1 and mods[1] == mod.super and button_id == 1 then
       capi.mouse.screen.bar.panel = wireless_panel
       return
    end
    -- if (not mods or #mods == 0) and button_id == 1 then
    --     network_service:toggle_wireless()
    --     return
    -- end
end)
network_service:connect_signal("wireless::state", function (_, state)
    if state > network_service.DeviceState.UNAVAILABLE and state < network_service.DeviceState.FAILED then
        wireless:turn_on()
    else
        wireless:turn_off()
    end

    if state == network_service.DeviceState.DISCONNECTED then
        wireless.text:set_markup_silently("No connection")
    elseif state > network_service.DeviceState.DISCONNECTED and state < network_service.DeviceState.ACTIVATED then
        wireless.text:set_markup_silently("Connecting...")
    elseif state ~= network_service.DeviceState.ACTIVATED and state ~= network_service.DeviceState.DEACTIVATING then
        wireless.text:set_markup_silently("Wireless")
    end
end)
network_service:connect_signal("wireless::active_access_point", function (_, ssid)
    wireless.text:set_markup_silently(ssid)
end)

local volume = slider("墳")
volume.bar.buttons = {
    awful.button {
        modifiers = {},
        button    = 4,
        on_press  = function () pactl_service:sink_volume_up(1) end,
    },
    awful.button {
        modifiers = {},
        button    = 5,
        on_press  = function () pactl_service:sink_volume_down(1) end,
    },
}
volume.bar:connect_signal("property::value", function (_, value)
    volume.animation._private.pos[1] = value
end)
volume.bar:connect_signal("button::release_from_pressed", function (_)
    pactl_service:sink_set_volume(math.floor(volume.bar.value + 0.5))
end)
pactl_service:connect_signal("sink::updated", function (_, device)
    if not device.default then return end

    for _, channel in pairs(device.volume) do
        local vol = tonumber(channel.value_percent:match("(%d+)%%"))
        volume.animation.target = { vol, device.mute and 0.5 or 1 }
    end
end)

return wibox.widget {
    {
        wireless,
        setting_button("", "Bluetooth"),
        setting_button("", "Airplane mode"),
        setting_button("", "Do not disturb"),
        setting_button("頋", "Compositor"),
        setting_button("", "Screenshot"),
        setting_button("辶", "Record"),
        setting_button("", "???"),
        forced_num_cols = 4,
        spacing         = dpi(5),
        expand          = true,
        homogeneous     = true,
        layout          = wibox.layout.grid,
    },
    {
        slider(""),
        volume,
        spacing = dpi(5),
        layout  = wibox.layout.flex.horizontal,
    },
    spacing = dpi(5),
    layout  = wibox.layout.fixed.vertical,
}
