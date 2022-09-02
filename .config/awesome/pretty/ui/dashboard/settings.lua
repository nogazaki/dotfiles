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

local setting_button = function (icon, name, on_release)
    name = wibox.widget {
        markup = name,
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
            name,
            layout  = wibox.layout.fixed.vertical,
        },
        paddings = dpi(10),
        bg       = beautiful.accent_color .. "22",
        shape    = helpers.ui.rrect(beautiful.border_radius),
        on_button_release = function (self) self:toggle() end,
    }

    return ret
end

local slider = function (icon)
    icon = "<span font_desc='FiraCode Nerd Font Mono 15'>" .. (icon or "") .. "</span>"
    local text = wibox.widget {
        markup       = icon,
        font         = "Iosevka 11",
        align        = "center",
        forced_width = dpi(50),
        widget       = wibox.widget.textbox,
    }
    local bar = wibox.widget {
        handle_width     = 0,
        handle_color     = "#00000000",
        bar_shape        = helpers.ui.rrect(beautiful.border_radius),
        bar_color        = beautiful.accent_color .. "22",
        bar_active_color = beautiful.accent_color,
        value            = 0,
        minimum          = 0,
        maximium         = 100,
        widget           = wibox.widget.slider,
    }
    local ret = wibox.widget {
        text,
        bar,
        forced_height = dpi(25),
        layout        = wibox.layout.fixed.horizontal,
    }
    bar:connect_signal("button::press", function (self, _, _, button, mods)
        if #mods > 0 then return end

        if button == 5 then
            self.value = math.max(self.minimum, math.min(self.maximum, self.value + 1))
        elseif button == 4 then
            self.value = math.max(self.minimum, math.min(self.maximum, self.value - 1))
        end
    end)
    bar:connect_signal("property::value", function (self)
        if self.timer then self.timer:stop(); self.timer = nil end
        text:set_markup_silently(string.format("%02.0f", self.value))
        self.timer = gears.timer.start_new(3, function ()
            self.timer = nil; text:set_markup_silently(icon)
        end)
    end)

    return ret
end

return wibox.widget {
    {
        setting_button("", "Wireless"),
        setting_button("", "Bluetooth"),
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
        slider("墳"),
        spacing = dpi(5),
        layout  = wibox.layout.flex.horizontal,
    },
    spacing = dpi(5),
    layout  = wibox.layout.fixed.vertical,
}
