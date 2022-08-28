-- Standard awesome library
local gears = require("gears")

--------------------------------------------------

local clock = gears.object {
    enable_properties   = true,
    enable_auto_signals = true,
}

function clock:init()
    if self.update_timer then return end

    self.update_timer = gears.timer {
        timeout     = 1,
        call_now    = true,
        autostart   = true,
        single_shot = false,
        callback    = function ()
            self = gears.table.crush(self, os.date("*t"))
            return true
        end
    }

    return true
end

return clock
