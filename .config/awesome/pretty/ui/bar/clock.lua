-- Standard awesome library
local gears = require 'gears'
-- Widget and layout library
local wibox = require 'wibox'
-- Theme handling library
local beautiful = require 'beautiful'

local helpers = require 'helpers'

--------------------------------------------------

local widgets = require 'pretty.ui._widgets'

local animation_service = require 'evil.animation'

--------------------------------------------------

local _clock = {}
_clock.date_widget = wibox.widget {
   format = '%A, %B %d, %Y',
   font = 'Iosevka ' .. beautiful.font_size,
   widget = wibox.widget.textclock,
}
_clock.time_widget = wibox.widget {
   format = '%H:%M:%S',
   refresh = 1,
   font = 'Iosevka Bold ' .. beautiful.font_size,
   widget = wibox.widget.textclock,
}

local function new()
   local ret = widgets.container {
      wibox.layout.fixed.horizontal(),
      bg = beautiful.bg_focus,
      fg = beautiful.fg_focus,
      shape = gears.shape.rounded_bar,
   }

   local date_button = widgets.button.state {
      _clock.date_widget,
      bg = beautiful.bg_normal,
      fg = beautiful.fg_normal,
      shape = gears.shape.rounded_bar,
      paddings = {
         top = beautiful.font_height / 2,
         bottom = beautiful.font_height / 2,
         left = beautiful.font_height,
         right = beautiful.font_height,
      },

      create_callback = function(self)
         self.animator = animation_service {
            initial = helpers.color.hex_to_rgba(beautiful.bg_normal),
            duration = 0.1,
            update = function(_, pos) self.bg = helpers.color.rgba_to_hex(pos) end,
         }
         self:connect_signal(
            'mouse::enter',
            function()
               self.animator.target = helpers.color.hex_to_rgba(
                  helpers.color.lighten(beautiful.bg_normal)
               )
            end
         )
         self:connect_signal(
            'mouse::leave',
            function()
               self.animator.target =
                  helpers.color.hex_to_rgba(beautiful.bg_normal)
            end
         )
         self:connect_signal(
            'button::press',
            function()
               self.animator.target = helpers.color.hex_to_rgba(
                  helpers.color.darken(beautiful.bg_normal)
               )
            end
         )
         self:connect_signal(
            'button::release',
            function()
               self.animator.target = helpers.color.hex_to_rgba(
                  helpers.color.lighten(beautiful.bg_normal)
               )
            end
         )
      end,
   }
   local time_button = widgets.button.state {
      _clock.time_widget,
      paddings = {
         left = beautiful.font_height / 2,
         right = beautiful.font_height,
      },

      create_callback = function(self)
         self.animator = animation_service {
            initial = helpers.color.hex_to_rgba(beautiful.bg_focus),
            duration = 0.1,
            update = function(_, pos) ret.bg = helpers.color.rgba_to_hex(pos) end,
         }
         self:connect_signal(
            'mouse::enter',
            function()
               self.animator.target = helpers.color.hex_to_rgba(
                  helpers.color.lighten(beautiful.bg_focus)
               )
            end
         )
         self:connect_signal(
            'mouse::leave',
            function()
               self.animator.target =
                  helpers.color.hex_to_rgba(beautiful.bg_focus)
            end
         )
         self:connect_signal(
            'button::press',
            function()
               self.animator.target = helpers.color.hex_to_rgba(
                  helpers.color.darken(beautiful.bg_focus)
               )
            end
         )
         self:connect_signal(
            'button::release',
            function()
               self.animator.target = helpers.color.hex_to_rgba(
                  helpers.color.lighten(beautiful.bg_focus)
               )
            end
         )
      end,
   }

   ret.widget:add(date_button)
   ret.widget:add(time_button)

   return ret
end

return setmetatable(_clock, { __call = new })
