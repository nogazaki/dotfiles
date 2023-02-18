local capi = require 'capi'
-- Standard awesome library
local awful = require 'awful'
-- Widget and layout library
local wibox = require 'wibox'
-- Theme handling library
local beautiful = require 'beautiful'
local dpi = beautiful.xresources.apply_dpi

--------------------------------------------------

local path = ...

local widgets = require 'pretty.ui._widgets'

--------------------------------------------------

capi.screen.connect_signal('request::desktop_decoration', function(screen)
   if screen == capi.screen.primary then
      screen.systray = wibox.widget {
         wibox.widget.systray(),
         widget = wibox.container.place,
      }
   end

   screen.bar = awful.wibar {
      screen = screen,
      position = 'top',
      height = beautiful.font_height * 2,
      bg = '#00000000',
      margins = {
         top = beautiful.useless_gap * 2,
         left = beautiful.useless_gap * 2,
         right = beautiful.useless_gap * 2,
      },
      type = 'menu',
      widget = {
         {
            require(path .. '.clock')(screen),
            require(path .. '.tasklist')(screen),
            spacing = beautiful.font_size * 0.5,
            layout = wibox.layout.fixed.horizontal,
         },
         widgets.container {
            require(path .. '.taglist')(screen),
            bg = beautiful.bar_bg,
            shape = beautiful.bar_shape,
            paddings = {
               top = beautiful.font_height * 0.5,
               bottom = beautiful.font_height * 0.5,
               left = beautiful.font_height,
               right = beautiful.font_height,
            },
         },
         widgets.container {
            {
               require(path .. '.network'),
               require(path .. '.volume'),
               {
                  require(path .. '.battery'),
                  top = beautiful.font_height * 0.1,
                  bottom = beautiful.font_height * 0.1,
                  widget = wibox.container.margin,
               },
               {
                  forced_width = dpi(1, screen),
                  widget = wibox.widget.separator,
               },
               require(path .. '.layoutbox')(screen),
               spacing = beautiful.font_height * 0.5,
               layout = wibox.layout.fixed.horizontal,
            },
            bg = beautiful.bar_bg,
            fg = beautiful.bar_fg,
            shape = beautiful.bar_shape,
            paddings = {
               top = beautiful.font_height * 0.4,
               bottom = beautiful.font_height * 0.4,
               left = beautiful.font_height,
               right = beautiful.font_height,
            },
         },
         expand = 'none',
         layout = wibox.layout.align.horizontal,
      },
   }
end)
