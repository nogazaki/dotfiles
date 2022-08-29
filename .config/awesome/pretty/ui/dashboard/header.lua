local capi = require("capi")
-- Standard awesome library
local gears = require("gears")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local helpers = require("helpers")

--------------------------------------------------

local widgets = require("pretty.ui._widgets")

local power = widgets.button {
    {
        markup = "",
        font   = "FiraCode Nerd Font Mono Bold 17",
        align  = "center",
        widget = wibox.widget.textbox,
    },
    bg            = beautiful.xcolor1,
    bg_hover      = helpers.color.lighten(beautiful.xcolor1, 0.05),
    bg_press      = helpers.color.darken(beautiful.xcolor1, 0.05),
    fg            = beautiful.xcolor0,
    shape         = gears.shape.circle,
    forced_width  = dpi(35),
    forced_height = dpi(35),
}
local icon = wibox.widget {
    widgets.container {
        {
            image      = beautiful.profile_pic,
            resize     = true,
            fit_policy = "fill",
            halign     = "center",
            valign     = "center",
            clip_shape = gears.shape.circle,
            widget     = wibox.widget.imagebox
        },
        border_width = dpi(3),
        border_color = beautiful.xcolor1,
        shape        = gears.shape.circle,
        paddings     = dpi(5),
    },
    {
        power,
        halign = "right",
        valign = "bottom",
        widget = wibox.container.place,
    },
    layout = wibox.layout.stack
}
-- Make the icon the widget with smallest size
-- Since layouts ignore widgets forced size on secondary axis,
-- the icon will take the height of other widgets when putting into the layout
icon.forced_height = 0
-- Ensure the icon's width to be the same as the height
function icon.fit(_, _, _, height)
    return height, height
end

local greetings = wibox.widget {
    markup = "...",
    font   = "Iosevka Bold 20",
    widget = wibox.widget.textbox,
}
local info = wibox.widget {
    markup = string.format(
        "%s@%s",
        helpers.string.colorize(os.getenv("USER"), beautiful.xcolor6),
        helpers.string.colorize(capi.awesome.hostname, beautiful.xcolor3)
    ),
    font   = "Iosevka 12.5",
    widget = wibox.widget.textbox,
}

local weekday = wibox.widget {
    markup  = "...",
    font    = beautiful.gtk_font_family .. " 17",
    align   = "right",
    valign  = "center",
    opacity = 0.5,
    widget  = wibox.widget.textbox,
}
local date = wibox.widget {
    markup  = "...",
    font    = beautiful.gtk_font_family .. " 17",
    align   = "right",
    valign  = "center",
    widget  = wibox.widget.textbox,
}

local search_icon = wibox.widget {
    markup = "",
    font   = "FiraCode Nerd Font Mono Bold 15",
    align  = "center",
    widget = wibox.widget.textbox,
}
local search_text = wibox.widget {
    markup  = "Looking for something?",
    font    = beautiful.gtk_font_family .. " 12",
    opacity = 0.5,
    widget  = wibox.widget.textbox,
}

local clock = require("evil.clock")
clock:connect_signal("property::day", function ()
    weekday:set_markup_silently(os.date("%A"))
    date:set_markup_silently(os.date("%b %d, %Y"))
end)
clock:connect_signal("property::hour", function (_, new_value)
    local greet
    if (22 <= new_value) or (new_value < 3) then
        greet = "night"
    elseif new_value < 12 then
        greet = "morning"
    elseif new_value < 18 then
        greet = "afternoon"
    else
        greet = "evening"
    end
    greetings:set_markup_silently(string.format("Good %s!", greet))
end)

return wibox.widget {
    icon,
    {
        {
            {
                {
                    greetings,
                    {
                        info,
                        left   = dpi(7),
                        right  = dpi(15),
                        widget = wibox.container.margin,
                    },
                    layout = wibox.layout.fixed.vertical,
                },
                nil,
                {
                    weekday,
                    date,
                    layout = wibox.layout.fixed.vertical,
                },
                layout = wibox.layout.align.horizontal,
            },
            widgets.container {
                {
                    search_icon,
                    search_text,
                    spacing = dpi(10),
                    layout  = wibox.layout.fixed.horizontal,
                },
                bg            = beautiful.fg_normal .. "22",
                shape         = gears.shape.rounded_bar,
                paddings      = { left = dpi(15), right = dpi(15) },
                forced_height = dpi(35),
            },
            spacing = dpi(5),
            layout  = wibox.layout.fixed.vertical,
        },
        left   = dpi(5),
        widget = wibox.container.margin,
    },
    layout = wibox.layout.align.horizontal,
}
