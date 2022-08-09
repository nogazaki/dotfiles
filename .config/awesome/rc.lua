pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")

--------------------------------------------------

-- {{{ Error handling
naughty.connect_signal("request::display_error", function (message, startup)
    naughty.notification {
        timeout = 0,
        urgency = "critical",
        title = "Oops, an error happened " ..
            (startup and "during startup!" or "!"),
        message = message,
    }
end)
-- }}}

--------------------------------------------------

-- Themes
local theme_dir = gears.filesystem.get_configuration_dir() .. "themes/"
beautiful.init(theme_dir .. "default.lua")

-- Configurations
require("configuration")

-- Modules
require("modules")

-- UI
require("pretty")

-- Signals (make sure this is called after UI so widgets properly subscribed)
require("evil")

--------------------------------------------------

-- Garbage collector settings, enable for lower memory consumption
collectgarbage("setpause", 110)
collectgarbage("setstepmul", 1000)
gears.timer {
    timeout   = 5,
    autostart = true,
    call_now  = true,
    callback  = function () collectgarbage("collect") return true end,
}
