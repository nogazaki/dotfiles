-- Widget and layout library
local wibox = require 'wibox'
-- Theme handling library
local beautiful = require 'beautiful'
local dpi = beautiful.xresources.apply_dpi

local helpers = require 'helpers'

--------------------------------------------------

local upower_service = require 'evil.upower'

--------------------------------------------------

local bar = wibox.widget {
   max_value = 100,
   value = 50,
   border_width = dpi(1),
   paddings = dpi(2),
   shape = helpers.ui.rrect(dpi(3)),
   color = beautiful.fg_normal,
   background_color = '#00000000',
   border_color = beautiful.fg_normal,
   widget = wibox.widget.progressbar,
}
local knob = wibox.widget {
   orientation = 'vertical',
   thickness = dpi(1),
   span_ratio = 0.6,
   widget = wibox.widget.separator,
}
local battery = wibox.widget {
   bar,
   knob,
   spacing = dpi(1),
   layout = wibox.layout.fixed.horizontal,
}
-- Ensure there is space for the knob
bar.fit = function(_, _, width, height) return width - dpi(2), height end
-- Width will always be double height
battery.fit = function(_, _, _, height) return height * 2, height end

upower_service:connect_signal('battery::update', function(_, device)
   bar.value = device.percentage

   if
      device.state == upower_service.states.charging
      or device.state == upower_service.states.fully_charged
   then
      bar.color = beautiful.xcolor2
   else
      bar.color = beautiful.fg_normal
   end
end)

return battery
