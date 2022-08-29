-- Standard awesome library
local gears = require("gears")

local UPower = require("lgi").require("UPowerGlib")

--------------------------------------------------

local upower = gears.object {
    enable_properties   = true,
    enable_auto_signals = true,
}

upower.states = {
    unknown           = 0,
    charging          = 1,
    discharging       = 2,
    empty             = 3,
    fully_charged     = 4,
    pending_charge    = 5,
    pending_discharge = 6,
}

function upower:init()
    if self.client then return end

    self.client = UPower.Client()

    self.client.on_device_added = function (_, device)
        device.on_notify = function () self:emit_signal("device::update", device) end
    end

    local battery = self.client:get_display_device()
    battery.on_notify = function () self:emit_signal("battery::update", battery) end

    self:emit_signal("battery::update", battery)
end

return upower
