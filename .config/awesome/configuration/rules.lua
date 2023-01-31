local capi = require("capi")
-- Standard awesome library
local awful = require("awful")
-- Theme handling library
local beautiful = require("beautiful")
-- Declarative object management
local ruled = require("ruled")

local helpers = require("helpers")

--------------------------------------------------

ruled.client.connect_signal("request::rules", function ()
    -- All client will match this
    ruled.client.append_rule {
        id = "global",
        rule = {},
        properties = {
            focus     = awful.client.focus.filter,
            raise     = true,
            screen    = awful.screen.preferred,
            shape     = helpers.ui.rrect(beautiful.border_radius),
            placement = function (c)
                local args = {}
                args.honor_workarea = true
                local client_geometry = c:geometry()
                local transient_geometry = c.transient_for and c.transient_for:geometry()
                if transient_geometry and
                    (client_geometry.width < transient_geometry.width) and
                    (client_geometry.height < transient_geometry.height)
                then args.parent = c.transient_for end
                awful.placement.centered(c, args)
                awful.placement.no_offscreen(c, args)
            end,
        },
    }
    -- Floating clients
    ruled.client.append_rule {
        id = "floating",
        rule_any = {
            class = {
                "MEGAsync", "Thunar", "lxappearance", "Gnome-disks",
                "Minecraft.*", "Steam",
            },
            instance = {
                "copyq", "pinentry",
            },
            name = {
                "Event Tester", "Picture in picture",
            },
            role = {
                "AlarmWindow", "ConfigManager", "pop-up",
            },
        },
        properties = { floating = true },
    }
    -- Ontop clients
    ruled.client.append_rule {
        rule = { class = "copyq" },
        properties = { ontop = true, },
    }
    -- Add title bar to clients
    ruled.client.append_rule {
        id = "titlebar",
        rule_any = { type = { "normal", "dialog" } },
        except = { requests_no_titlebar = true },
        properties = { titlebars_enabled = true },
    }
    -- Assign default tags
    ruled.client.append_rule {
        rule_any = { class = { "Spotify" } },
        properties = { tag = capi.screen[1].tags[2] },
    }
    ruled.client.append_rule {
        rule_any = { class = { "Evolution", "discord" } },
        properties = { tag = capi.screen[1].tags[3] },
    }
end)

--------------------------------------------------

ruled.notification.connect_signal("request::rules", function ()
    -- All notification will match this
    ruled.notification.append_rule {
        rule = {},
        properties = {
            screen           = awful.screen.preferred,
            implicit_timeout = 5,
        },
    }
end)
