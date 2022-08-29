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

local widgets = require("pretty.ui._widgets")

local size = dpi(160)
local default_art = gears.filesystem.get_configuration_dir() .. "pretty/assets/music.svg"

local function create_filter(color)
    return {
        type  = "linear",
        from  = {0, 0},
        to    = {size, 0},
        stops = { { 0, color .. "00" }, { 1, color .. "FF" } },
    }
end

local player_name = wibox.widget {
    markup  = "...",
    font    = "Iosevka 10",
    opacity = 0.6,
    widget  = wibox.widget.textbox,
}
local prev_player = widgets.button.state {
    {
        markup  = "",
        font    = "FiraCode Nerd Font Bold 14",
        widget  = wibox.widget.textbox,
    },
    opacity    = 0.2,
    opacity_on = 0.6,
}
local next_player = widgets.button.state {
    {
        markup  = "",
        font    = "FiraCode Nerd Font Bold 14",
        widget  = wibox.widget.textbox,
    },
    opacity    = 0.2,
    opacity_on = 0.6,
}

local album_art = wibox.widget {
    image      = default_art,
    resize     = true,
    halign     = "right",
    valign     = "center",
    stylesheet = string.format (
        "svg { fill:%s; } ",
        beautiful.accent_color, beautiful.bg_normal
    ),
    widget     = wibox.widget.imagebox,
}
local album_art_filter = wibox.widget {
    bg     = create_filter(beautiful.accent_color),
    widget = wibox.container.background,
}

local title = wibox.widget {
    markup = "...",
    font   = beautiful.gtk_font_family .. " Bold 15",
    widget = wibox.widget.textbox,
}
title.forced_height = beautiful.get_font_height(title.font)
local artist_album = wibox.widget {
    font   = beautiful.gtk_font_family .. " 11",
    widget = wibox.widget.textbox,
}
artist_album.forced_height = beautiful.get_font_height(artist_album.font)

local progress = wibox.widget {
    max_value        = 1,
    value            = 0,
    background_color = beautiful.bg_normal .. "22",
    color            = beautiful.bg_normal,
    shape            = gears.shape.rounded_bar,
    bar_shape        = gears.shape.rounded_bar,
    forced_height    = dpi(2),
    widget           = wibox.widget.progressbar,
}
local position = wibox.widget {
    markup = "00:00",
    font   = "Iosevka 9",
    widget = wibox.widget.textbox,
}
local length = wibox.widget {
    markup = "00:00",
    font   = "Iosevka 9",
    widget = wibox.widget.textbox,
}

local info = wibox.widget {
    {
        album_art,
        {
            album_art_filter,
            reflection = { horizontal = true },
            widget     = wibox.container.mirror,
        },
        {
            {
                {
                    prev_player,
                    next_player,
                    player_name,
                    spacing = dpi(10),
                    layout  = wibox.layout.fixed.horizontal,
                },
                {
                    widgets.spacer.vertical(dpi(15)),
                    {
                        title,
                        id            = "scroll",
                        fps           = 60,
                        speed         = 75,
                        extra_space   = size,
                        step_function = helpers.ui.wait_linear_increase_scrolling,
                        widget        = widgets.declarative.scroll.horizontal,
                    },
                    {
                        artist_album,
                        id            = "scroll",
                        fps           = 60,
                        speed         = 75,
                        extra_space   = size,
                        step_function = helpers.ui.wait_linear_increase_scrolling,
                        widget        = widgets.declarative.scroll.horizontal,
                    },
                    layout = wibox.layout.fixed.vertical,
                },
                {
                    {
                        position,
                        widgets.container {
                            progress,
                            margins = { left = dpi(5), right = dpi(5) },
                            valign  = "center",
                        },
                        length,
                        layout = wibox.layout.align.horizontal,
                    },
                    right  = size,
                    widget = wibox.container.margin,
                },
                layout = wibox.layout.align.vertical,
            },
            margins = dpi(10),
            widget = wibox.container.margin,
        },
        layout = wibox.layout.stack,
    },
    fg     = beautiful.bg_normal,
    shape  = helpers.ui.rrect(beautiful.border_radius),
    widget = wibox.container.background,
}

local function create_control_button(symbol, role)
    local button = widgets.button.state {
        {
            markup = symbol,
            font   = "FiraCode Nerd Font Mono 32",
            align  = "center",
            valign = "center",
            widget = wibox.widget.textbox,
        },
        opacity          = 0.2,
        opacity_hover    = 0.2,
        opacity_on       = 0.6,
        opacity_on_hover = 1,
    }
    button.role = role

    return button
end

local prev_button = create_control_button("ﭣ", "previous")
local play_button = create_control_button("奈", "play_pause")
local next_button = create_control_button("ﭡ", "next")

local controls = widgets.container {
    {
        prev_button,
        play_button,
        next_button,
        spacing = dpi(10),
        layout  = wibox.layout.flex.vertical,
    },
    paddings = dpi(10),
    bg       = beautiful.accent_color,
    fg       = beautiful.bg_normal,
    shape    = helpers.ui.rrect(beautiful.border_radius),
}

local players = wibox.widget {
    nil,
    info,
    {
        controls,
        left   = dpi(5),
        widget = wibox.container.margin,
    },
    forced_height = size,
    layout        = wibox.layout.align.horizontal,
}

return players
