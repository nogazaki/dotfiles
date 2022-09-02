local capi = require("capi")
-- Standard awesome library
local awful = require("awful")

--------------------------------------------------

local mod = require("configuration.bindings.mod")

--------------------------------------------------

-- Set the resize mode
awful.mouse.resize.set_mode("live")

capi.client.connect_signal("request::default_mousebindings", function ()
    awful.mouse.append_client_mousebindings {
        awful.button {
            modifiers = {},
            button    = 1,
            on_press  = function (c)
                c:activate {
                    context = "mouse_click",
                }
            end,
        },
        awful.button {
            modifiers = { mod.super },
            button    = 1,
            on_press  = function (c)
                c:activate {
                    context = "mouse_click",
                    action  = "mouse_move",
                }
            end,
        },
        awful.button {
            modifiers = { mod.super },
            button    = 3,
            on_press  = function (c)
                c:activate {
                    context = "mouse_click",
                    action  = "mouse_resize",
                }
            end,
        },
    }
end)
