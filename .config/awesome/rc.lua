pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")

math.randomseed(os.time())

--------------------------------------------------

-- {{{ Error handling
naughty.connect_signal("request::display_error", function (message, startup)
    naughty.notification {
        timeout  = 0,
        urgency  = "critical",
        app_name = "awesomewm",
        title    = "Oops, an error happened" .. (startup and " during startup!" or "!"),
        message  = message,
    }
end)
-- }}}

--------------------------------------------------

-- Theme
beautiful.init(gears.filesystem.get_configuration_dir() .. "pretty/theme.lua")

-- Configurations
require("configuration")

-- UI
require("pretty")

-- Signals (make sure this is called after UI so widgets properly subscribed)
require("evil")

--------------------------------------------------

-- Garbage collector settings, enable for lower memory consumption
collectgarbage("generational")
gears.timer {
    timeout   = 5,
    autostart = true,
    call_now  = true,
    callback  = function () collectgarbage() return true end,
}
