-- Widget and layout library
local wibox = require 'wibox'
-- Theme handling library
local beautiful = require 'beautiful'
local dpi = beautiful.xresources.apply_dpi

--------------------------------------------------

local animation_service = require 'evil.animation'
local pactl_service = require 'evil.pactl'

--------------------------------------------------

local arc = wibox.widget {
   max_value = 100,
   min_value = 0,
   values = { 50, 50 },
   start_angle = -math.pi / 2,
   thickness = dpi(3),
   colors = { beautiful.accent_color, beautiful.accent_color .. '44' },
   widget = wibox.container.arcchart,
}

pactl_service:connect_signal('sink::updated', function(_, device)
   if not device.default then return end

   for _, channel in pairs(device.volume) do
      local vol = channel.value_percent:match '(%d+)%%'

      if not arc.animator then
         arc.animator = animation_service {
            initial = { arc.values[1], arc.opacity },
            duration = 0.1,
            update = function(_, pos)
               arc.values = { pos[1], 100 - pos[1] }
               arc.opacity = pos[2]
            end,
         }
         arc.animator:connect_signal('ended', function() arc.animator = nil end)
      end

      arc.animator.target = { tonumber(vol), device.mute and 0.5 or 1 }

      if channel then break end
   end
end)

return wibox.widget {
   arc,
   reflection = { horizontal = true },
   widget = wibox.container.mirror,
}
