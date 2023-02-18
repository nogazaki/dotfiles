-- Standard awesome library
local awful = require 'awful'
-- Widget and layout library
local wibox = require 'wibox'
-- Theme handling library
local beautiful = require 'beautiful'

--------------------------------------------------

local _tasklist = {}

local function new(_, screen)
   return awful.widget.tasklist {
      screen = screen,
      filter = awful.widget.tasklist.filter.focused,
      style = {
         fg_focus = beautiful.bar_fg,
         font = 'Iosevka ' .. beautiful.font_size,
      },
      widget_template = {
         {
            {
               { id = 'icon_role', widget = wibox.widget.imagebox },
               {
                  {
                     id = 'text_role',
                     forced_height = beautiful.font_height,
                     widget = wibox.widget.textbox,
                  },
                  widget = wibox.container.place,
               },
               spacing = beautiful.font_height * 0.5,
               layout = wibox.layout.fixed.horizontal,
            },
            right = beautiful.font_height * 0.5,
            widget = wibox.container.margin,
         },
         bg = beautiful.bar_bg,
         fg = beautiful.bar_fg,
         shape = beautiful.bar_shape,
         forced_width = beautiful.font_height * 20,
         widget = wibox.container.background,
      },
   }
end

return setmetatable(_tasklist, { __call = new })
