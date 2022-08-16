-- Standard awesome library
local awful = require("awful")
local gears = require("gears")
-- Theme handling library
local beautiful = require("beautiful")

-- local bling = require("modules.bling")

local helpers = require("helpers")

local awesome, mouse, client = _G.awesome, _G.mouse, _G.client

--------------------------------------------------

require("awful.autofocus")
-- Flash focus
-- bling.module.flash_focus.enable()

client.connect_signal("request::manage", function (c)
    if not awesome.startup then
        -- Set new clients as slave
        awful.client.setslave(c)
    elseif not c.size_hints.user_position and not c.size_hints.program_position then
        awful.placement.no_offscreen(c)
    end
end)

-- Fix wrong geometry for clients in fullscreen with titlebars
local function fullscreen_geometry(c)
    if not c.fullscreen then return end
    gears.timer.delayed_call(function ()
        if not c.valid then return end
        c:geometry(c.screen.geometry)
    end)
end
client.connect_signal("request::manage", fullscreen_geometry)
client.connect_signal("property::fullscreen", fullscreen_geometry)

-- Maximize clients respect gaps
local function maximize_geometry(c)
    if not c.maximized then return end
    gears.timer.delayed_call(function ()
        if not c.valid then return end
        awful.placement.maximize(c, {
            honor_workarea = true,
            honor_padding  = true,
            margins        = beautiful.useless_gap * 2
        })
    end)
end
client.connect_signal("request::manage", maximize_geometry)
client.connect_signal("property::maximized", maximize_geometry)

-- Restore geometry for floating clients
client.connect_signal("property::floating", function (c)
    if not c.floating or c.fullscreen or c.maximized then return end
    if c.floating_geometry then
        c:geometry(c.floating_geometry)
    end
end)

-- Disble rounded corner for fuilscreen clients
client.connect_signal("property::fullscreen", function (c)
    if c.fullscreen then
        c.shape_backup = c.shape
        c.shape = gears.shape.rectangle
    else
        c.shape = c.shape_backup or helpers.ui.rrect(beautiful.border_radius)
        c.shape_backup = nil
    end
end)

-- Only respect size hints if client is floating and not maximized
local function honor_size_hints(c)
    c.size_hints_honor = c.floating and not c.maximized
end
client.connect_signal("request::manage", honor_size_hints)
client.connect_signal("property::floating", honor_size_hints)
client.connect_signal("property::maximized", honor_size_hints)

-- Raise focused clients automatically
client.connect_signal("focus", function (c) c:raise() end)

-- Raise the urgent client when switching to the tag attached to it
awful.tag.attached_connect_signal(nil, "property::selected", function ()
    local c = helpers.client.find({ urgent = true }, true)
    if c and c.first_tag == mouse.screen.selected_tag then client.focus = c end
end)

-- Disable ontop when the client is tiled
client.connect_signal("property::ontop", function (c)
    if not c.floating then c.ontop = false end
end)
-- Restore the ontop properties if needed when client becomes floating again
client.connect_signal("property::floating", function (c)
    if not c.floating then
        c.ontop_backup = c.ontop or nil;
        c.ontop = false
    else
        c.ontop = c.ontop_backup or false;
        c.ontop_backup = nil
    end
end)

client.connect_signal("property::requests_no_titlebar", function (c)
    if c.requests_no_titlebar then
        awful.titlebar.hide(c)
    else
        awful.titlebar.show(c)
    end
end)