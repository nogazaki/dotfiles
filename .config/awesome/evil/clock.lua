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
        timeout     = 0.1,
        call_now    = true,
        autostart   = true,
        single_shot = false,
        callback    = function ()
            gears.table.crush(self, os.date("*t"))
            self:emit_signal("updated")
            return true
        end
    }

    return true
end

return clock
