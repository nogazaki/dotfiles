-- Standard awesome library
local awful = require("awful")
local gears = require("gears")

local machi = require("modules.layout-machi")

local capi = require("capi")

local string = string

--------------------------------------------------

local mod = require("configuration.bindings.mod")

-- General awesome keys
awful.keyboard.append_global_keybindings {
    awful.key {
        description = "Show this help",
        group       = "awesome",
        modifiers   = { mod.super },
        key         = "F1",
        on_press    = require("awful.hotkeys_popup").show_help,
    },
    -- awful.key {
    -- 	description = "Show main menu",
    -- 	group       = "awesome",
    -- 	modifiers   = { mod.super },
    -- 	key         = "Menu",
    -- 	on_press    = function ()
    -- 		-- TODO: add right click menu widget
    -- 	end,
    -- },
    awful.key {
        description = "Reload awesome",
        group       = "awesome",
        modifiers   = { mod.super },
        key         = "F5",
        on_press    = capi.awesome.restart,
    },
    -- awful.key {
    --     description = "Open a terminal",
    --     group       = "awesome",
    --     modifiers   = { mod.super },
    --     key         = "Return",
    --     on_press    = config.apps.terminal,
    -- },
    awful.key {
        description = "Application launcher",
        group       = "awesome",
        modifiers   = { mod.super },
        key         = "r",
        on_press    = function ()
            awful.spawn("rofi -show drun -display-run")
        end,
    },
    awful.key {
        description = "Prompt",
        group       = "awesome",
        modifiers   = { mod.super, mod.ctrl },
        key         = "r",
        on_press    = function ()
            awful.spawn("rofi -show run -display-run")
        end,
    },
    awful.key {
        description = "Lock the session",
        group       = "awesome",
        modifiers   = { mod.super },
        key         = "l",
        on_press    = function ()
            awful.spawn("betterlockscreen -l")
        end,
    },
}

-- Navigating
awful.keyboard.append_global_keybindings {
    awful.key {
        description = "View next tag",
        group       = "navigating",
        modifiers   = { mod.super },
        key         = "Right",
        on_press    = awful.tag.viewnext,
    },
    awful.key {
        description = "View previous tag",
        group       = "navigating",
        modifiers   = { mod.super },
        key         = "Left",
        on_press    = awful.tag.viewprev,
    },
    awful.key {
        description = "Focus on next client",
        group       = "navigating",
        modifiers   = { mod.alt },
        key         = "Tab",
        on_press    = function ()
            awful.client.focus.byidx( 1)
        end,
    },
    awful.key {
        description = "Focus on previous client",
        group       = "navigating",
        modifiers   = { mod.alt, mod.shift },
        key         = "Tab",
        on_press    = function ()
            awful.client.focus.byidx(-1)
        end,
    },
    awful.key {
        description = "Focus on urgent client",
        group       = "navigating",
        modifiers   = { mod.super },
        key         = "u",
        on_press    = awful.client.urgent.jumpto,
    },
    awful.key {
        description = "Focus on next screen",
        group       = "navigating",
        modifiers   = { mod.super },
        key         = "Next",
        on_press    = function ()
            awful.screen.focus_relative( 1)
        end,
    },
    awful.key {
        description = "Focus on previous screen",
        group       = "navigating",
        modifiers   = { mod.super },
        key         = "Prior",
        on_press    = function ()
            awful.screen.focus_relative(-1)
        end,
    },
    awful.key {
        description = "Restore last minimized client",
        group       = "client",
        modifiers   = { mod.super, mod.ctrl },
        key         = "n",
        on_press    = function ()
            local c = awful.client.restore()
            if not c then return end
            c:activate {
                raise   = true,
                context = "key.unminimize"
            }
        end,
    },
}

-- Layout
awful.keyboard.append_global_keybindings {
    awful.key {
        description = "Swap focused client with next one",
        group       = "layout",
        modifiers   = { mod.alt, mod.ctrl },
        key         = "Tab",
        on_press    = function ()
            awful.client.swap.byidx( 1)
        end,
    },
    awful.key {
        description = "Swap focused client with previous one",
        group       = "layout",
        modifiers   = { mod.alt, mod.shift, mod.ctrl },
        key         = "Tab",
        on_press    = function ()
            awful.client.swap.byidx(-1)
        end,
    },
    awful.key {
        description = "Increase master width factor",
        group       = "layout",
        modifiers   = { mod.super },
        key         = "=",
        on_press    = function ()
            awful.tag.incmwfact( 0.025)
        end,
    },
    awful.key {
        description = "Decrease master width factor",
        group       = "layout",
        modifiers   = { mod.super },
        key         = "-",
        on_press    = function ()
            awful.tag.incmwfact(-0.025)
        end,
    },
    awful.key {
        description = "Increase number of master clients",
        group       = "layout",
        modifiers   = { mod.super, mod.shift },
        key         = "=",
        on_press    = function ()
            awful.tag.incnmaster( 1, nil, true)
        end,
    },
    awful.key {
        description = "Decrease number of master clients",
        group       = "layout",
        modifiers   = { mod.super, mod.shift },
        key         = "-",
        on_press    = function ()
            awful.tag.incnmaster(-1, nil, true)
        end,
    },
    awful.key {
        description = "Increase number of slave columns",
        group       = "layout",
        modifiers   = { mod.super, mod.ctrl },
        key         = "=",
        on_press    = function ()
            awful.tag.incncol( 1, nil, true)
        end,
    },
    awful.key {
        description = "Decrease number of slave columns",
        group       = "layout",
        modifiers   = { mod.super, mod.ctrl },
        key         = "-",
        on_press    = function ()
            awful.tag.incncol(-1, nil, true)
        end,
    },
    awful.key {
        description = "Select next layout",
        group       = "layout",
        modifiers   = { mod.super },
        key         = "space",
        on_press    = function ()
            awful.layout.inc( 1)
        end,
    },
    awful.key {
        description = "Select previous layout",
        group       = "layout",
        modifiers   = { mod.super, mod.ctrl },
        key         = "space",
        on_press    = function ()
            awful.layout.inc(-1)
        end,
    },
}

-- Tags content
awful.keyboard.append_global_keybindings {
    awful.key {
        description = "Only view tag #",
        group       = "tag",
        modifiers   = { mod.super, mod.alt },
        keygroup    = "numrow",
        on_press    = function (index)
            local tag = capi.mouse.screen.tags[index]
            if tag then
                tag:view_only(tag)
            end
        end,
    },
    awful.key {
        description = "Toggle tag #",
        group       = "tag",
        modifiers   = { mod.super, mod.ctrl },
        keygroup    = "numrow",
        on_press    = function (index)
            local tag = capi.mouse.screen.tags[index]
            if tag then
                awful.tag.viewtoggle(tag)
            end
        end,
    },
    awful.key {
        description = "Move focused client to tag #",
        group       = "tag",
        modifiers   = { mod.super, mod.shift },
        keygroup    = "numrow",
        on_press    = function (index)
            if capi.client.focus then
                local tag = capi.client.focus.screen.tags[index]
                if tag then
                    capi.client.focus:move_to_tag(tag)
                end
            end
        end,
    },
}

-- Multimedia
awful.keyboard.append_global_keybindings {
    -- Volume
    awful.key {
        modifiers = {},
        key       = "XF86AudioMute",
        on_press  = function ()
            awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle", false)
        end,
    },
    awful.key {
        modifiers = {},
        key       = "XF86AudioLowerVolume",
        on_press  = function ()
            awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%", false)
        end,
    },
    awful.key {
        modifiers = {},
        key       = "XF86AudioRaiseVolume",
        on_press  = function ()
            awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%", false)
        end,
    },
}

-- Screenshot
local screenshot = gears.filesystem.get_configuration_dir() .. "screenshot"
awful.keyboard.append_global_keybindings {
    awful.key {
        description = "Take a screenshot of current screen",
        group       = "multimedia",
        modifiers   = {},
        key         = "Print",
        on_press    = function ()
            awful.spawn.with_shell(string.format(
                "%s single %dx%d%+d%+d",
                screenshot,
                capi.mouse.screen.geometry.width,
                capi.mouse.screen.geometry.height,
                capi.mouse.screen.geometry.x,
                capi.mouse.screen.geometry.y
            ))
        end,
    },
    awful.key {
        description = "Take a screenshot of an area",
        group       = "multimedia",
        modifiers   = { mod.alt },
        key         = "Print",
        on_press    = function ()
            awful.spawn.with_shell(screenshot .. " area")
        end,
    },
    awful.key {
        description = "Take a screenshot of all screens",
        group       = "multimedia",
        modifiers   = { mod.super },
        key         = "Print",
        on_press    = function ()
            awful.spawn.with_shell(screenshot .. " full")
        end,
    },
}

-- Playerctl
local playerctl = require("evil.playerctl")
awful.keyboard.append_global_keybindings {
    -- MPRIS
    awful.key {
        modifiers = {},
        key       = "XF86AudioPlay",
        on_press  = function ()
            playerctl:play_pause()
        end,
    },
    awful.key {
        modifiers = {},
        key       = "XF86AudioPrev",
        on_press  = function ()
            playerctl:previous()
        end,
    },
    awful.key {
        modifiers = {},
        key       = "XF86AudioNext",
        on_press  = function ()
            playerctl:next()
        end,
    },
}

-- Layout-machi
awful.keyboard.append_global_keybindings {
    awful.key {
        description = "Edit layout-machi",
        group       = "layout",
        modifiers   = { mod.super },
        key         = "/",
        on_press    = machi.default_editor.start_interactive,
    },
}

-- test function
awful.keyboard.append_global_keybindings {
    awful.key {
        modifiers = { mod.super },
        key       = "Escape",
        on_press  = require("testzone"),
    },
}


