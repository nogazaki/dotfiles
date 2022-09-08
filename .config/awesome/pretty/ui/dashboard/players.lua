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

local assets_path = capi.awesome.conffile:match("^(.-)rc%.lua$") .. "pretty/assets/"

local widgets = require("pretty.ui._widgets")

local playerctl_service = require("evil.playerctl")

--------------------------------------------------

local size = dpi(160)
local default_art = assets_path .. "music.svg"

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
        font    = "FiraCode Nerd Font Mono Bold 14",
        widget  = wibox.widget.textbox,
    },
    opacity    = 0.2,
    opacity_on = 0.6,
}
local next_player = widgets.button.state {
    {
        markup  = "",
        font    = "FiraCode Nerd Font Mono Bold 14",
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
    stylesheet = string.format("svg { fill:%s; }", beautiful.bg_normal),
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
                        widget        = wibox.container.scroll.horizontal,
                    },
                    {
                        artist_album,
                        id            = "scroll",
                        fps           = 60,
                        speed         = 75,
                        extra_space   = size,
                        step_function = helpers.ui.wait_linear_increase_scrolling,
                        widget        = wibox.container.scroll.horizontal,
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
    bg     = beautiful.accent_color,
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

local function update_control(player)
    if player.playback_status == "PLAYING" then
        play_button:set_markup_silently("")
        play_button[player.can_pause and "turn_on" or "turn_off"](play_button)
    else
        play_button:set_markup_silently("奈")
        play_button[player.can_play and "turn_on" or "turn_off"](play_button)
    end

    prev_button[player.can_go_previous and "turn_on" or "turn_off"](prev_button)
    next_button[player.can_go_next and "turn_on" or "turn_off"](next_button)
end

local function redraw_filter()
    album_art_filter:emit_signal("widget::redraw_needed")
end
local function update_position(player)
    local p, l = player:get_position() or 0, player:print_metadata_prop("mpris:length") or 0
    local value = p / l
    progress.value = (value ~= math.huge and value == value) and value or 0

    position:set_markup_silently(helpers.string.time_to_hms(p / 1000000))
    length:set_markup_silently(helpers.string.time_to_hms(l / 1000000))

    redraw_filter()
end

local function update_player_switch()
    local index, last = playerctl_service:get_player_index(players.current_display or playerctl_service.active_player)

    prev_player[index > 1 and "turn_on" or "turn_off"](prev_player)
    next_player[last and "turn_off" or "turn_on"](next_player)
end

local function real_update_info(player, path, bg)
    if player ~= players.current_display then return end

    player_name:set_markup_silently(player.player_name)

    local title_text = helpers.string.blank_to_nil(player:get_title()) or "..."
    title_text = gears.string.xml_escape(title_text)
    title:set_markup_silently(title_text)

    local artist = helpers.string.blank_to_nil(player:get_artist())
    artist = gears.string.xml_escape(artist)
    local album = helpers.string.blank_to_nil(player:get_album())
    album = gears.string.xml_escape(album)
    artist_album:set_markup_silently(string.format (
        "%s%s%s",
        artist or "",
        artist and album and " - " or "",
        album and ("<i>" .. album .. "</i>") or ""
    ))
    info:get_children_by_id("scroll")[1]:reset_scrolling()
    info:get_children_by_id("scroll")[2]:reset_scrolling()

    bg = bg or beautiful.accent_color
    local fg = helpers.color.check_contrast(beautiful.fg_normal, bg)
        and beautiful.fg_normal or beautiful.bg_normal

    info.bg = bg
    info.fg = fg

    progress.background_color = fg .. "22"
    progress.color = fg

    controls.bg = bg
    controls.fg = fg

    album_art:set_image(path or default_art)
    album_art_filter.bg = create_filter(bg)

    update_control(player)
    update_position(player)

    update_player_switch()
end
local function get_art_color(player, path)
    if not path then real_update_info(player) return end
    awful.spawn.easy_async (
        "colorz -n 1 --no-preview " .. path,
        function (out, err)
            local color
            if err == "" then
                color = out:match("%S+%s+(%S+)")
            end
            real_update_info(player, path, color)
        end
    )
end
local function update_info(player)
    players.current_display = player

    local art_url = helpers.string.blank_to_nil(player:print_metadata_prop("mpris:artUrl"))
    if not art_url then real_update_info(player) return end

    if art_url:match("^file://") then get_art_color(player, art_url:match("^file://(.-)$")) return end

    if not art_url:match("^http") then return end

    local path = art_url:reverse():match(".-/")
    path = os.getenv("HOME") .. "/.cache/awesome/album_art/" .. player.player_name .. path:reverse()
    -- File downloaded
    if gears.filesystem.file_readable(path) then
        get_art_color(player, path)
        return
    end
    gears.filesystem.make_parent_directories(path)
    -- File not downloaded
    awful.spawn.easy_async (
        string.format("curl -L -s %s -o %s", art_url, path),
        function (_, error)
            if error ~= "" then path = nil end
            get_art_color(player, path)
        end
    )
end

playerctl_service:connect_signal("playerctl::initialized", function (self)
    update_info(self.active_player)
end)
playerctl_service:connect_signal("playerctl::player::added", function ()
    update_player_switch()
end)
playerctl_service:connect_signal("playerctl::player::removed", function (self)
    update_info(self.active_player)
end)
playerctl_service:connect_signal("playback_status", function (_, player, playing)
    if player == players.current_display then
        update_control(player)
        return
    end

    if (not playing) or
        capi.mouse.current_widgets and gears.table.hasitem(capi.mouse.current_widgets, players)
    then return end

    update_info(player)
end)
playerctl_service:connect_signal("metadata", function (_, player)
    if players.current_display and player ~= players.current_display then return end

    update_info(player)
end)
playerctl_service:connect_signal("position", function (_, player)
    if players.current_display and player ~= players.current_display then return end

    update_position(player)
end)

prev_player.animation:connect_signal("updated", redraw_filter)
next_player.animation:connect_signal("updated", redraw_filter)

prev_player:connect_signal("button::trigger", function ()
    local index = playerctl_service:get_player_index(players.current_display)
    if not index or index == 1 then return end

    update_info(playerctl_service.players[index - 1])
end)
next_player:connect_signal("button::trigger", function ()
    local index, last = playerctl_service:get_player_index(players.current_display)
    if not index or last then return end

    update_info(playerctl_service.players[index + 1])
end)

local function control_command(self)
    playerctl_service[self.role](playerctl_service, players.current_display)
end
prev_button:connect_signal("button::trigger", control_command)
play_button:connect_signal("button::trigger", control_command)
next_button:connect_signal("button::trigger", control_command)

return players
