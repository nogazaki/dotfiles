-- Standard awesome library
local gears = require("gears")

--------------------------------------------------

local path = ...

gears.timer.delayed_call(function ()
    -- Clock
    require(path .. ".clock"):init()

    -- Animating clock
    require(path .. ".animation"):init()

    -- Playerctl
    require(path .. ".playerctl"):init()

    -- Pactl
    require(path .. ".pactl"):init()

    -- UPower
    require(path .. ".upower"):init()

    -- Connections
    require(path .. ".network"):init()
end)
