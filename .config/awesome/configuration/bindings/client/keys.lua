-- Standard awesome library
local awful = require("awful")

local client = _G.client

--------------------------------------------------

local mod = require("configuration.bindings.mod")

client.connect_signal("request::default_keybindings", function ()
    awful.keyboard.append_client_keybindings{
        awful.key {
            description = "Toggle fullscreen",
            group       = "client",
            modifiers   = { mod.super },
            key         = "F11",
            on_press    = function (c)
                c.fullscreen = not c.fullscreen
                c:raise()
            end,
        },
        awful.key {
            description = "Toggle floating",
            group       = "client",
            modifiers   = { mod.super },
            key         = "f",
            on_press    = awful.client.floating.toggle
        },
        awful.key {
            description = "Toggle pin",
            group       = "client",
            modifiers   = { mod.super },
            key         = "p",
            on_press    = function (c)
                c.ontop = not c.ontop
            end,
        },
        awful.key {
            description = "Toggle maximize",
            group       = "client",
            modifiers   = { mod.super },
            key         = "m",
            on_press    = function (c)
                if c.fullscreen then return end
                c.maximized = not c.maximized
                c:raise()
            end,
        },
        awful.key {
            description = "Close",
            group       = "client",
            modifiers   = { mod.alt},
            key         = "F4",
            on_press    = function (c)
                c:kill()
            end,
        },
        awful.key {
            description = "Minimize",
            group       = "client",
            modifiers   = { mod.super },
            key         = "n",
            on_press    = function (c)
                c.minimized = true
            end,
        },
        awful.key {
            description = "Set as master",
            group       = "client",
            modifiers   = { mod.super, mod.ctrl },
            key         = "Return",
            on_press    = function (c)
                c:swap(awful.client.getmaster())
            end,
        },
        awful.key {
            description = "Move to next screen",
            group       = "client",
            modifiers   = { mod.super },
            key         = "o",
            on_press    = function (c)
                c:move_to_screen()
            end,
        },
    }
end)
