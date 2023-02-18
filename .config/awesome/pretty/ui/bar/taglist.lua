local capi = require 'capi'
-- Standard awesome library
local awful = require 'awful'
local gears = require 'gears'
-- Widget and layout library
local wibox = require 'wibox'
-- Theme handling library
local beautiful = require 'beautiful'
local dpi = beautiful.xresources.apply_dpi

local helpers = require 'helpers'

--------------------------------------------------

local mod = require 'configuration.bindings.mod'

local animation_service = require 'evil.animation'

--------------------------------------------------

local _taglist = {}

-- size of the indicator
_taglist.default_size = beautiful.font_height * 0.75
_taglist.selected_size = _taglist.default_size * 4

_taglist.buttons = {
   layout = {
      awful.button {
         modifiers = {},
         button = 4,
         on_press = function() awful.tag.viewprev() end,
      },
      awful.button {
         modifiers = {},
         button = 5,
         on_press = function() awful.tag.viewnext() end,
      },
   },
   item = {
      awful.button {
         modifiers = {},
         button = 1,
         on_release = function(t) t:view_only() end,
      },
      awful.button {
         modifiers = { mod.super },
         button = 1,
         on_release = function(t)
            if capi.client.focus then capi.client.focus:move_to_tag(t) end
         end,
      },
      awful.button {
         modifiers = {},
         button = 3,
         on_release = awful.tag.viewtoggle,
      },
   },
}

function _taglist:update(tag)
   self.size_animator.target = tag.selected and _taglist.selected_size
      or _taglist.default_size

   if not tag.urgent then
      if self.timer then
         self.timer:stop()
         self.timer = nil
      end
      self.blinking = nil
      self.color_animator.duration = 0.3
      self.color_animator.target = helpers.color.hex_to_rgba(
         #tag:clients() > 0 and beautiful.taglist_bg_occupied
            or beautiful.taglist_bg_empty
      )
   else
      self.color_animator.duration = 1
      self.timer = self.timer
         or gears.timer {
            timeout = self.color_animator.duration,
            autostart = true,
            call_now = true,
            single_shot = false,
            callback = function()
               self.blinking = not self.blinking
               self.color_animator.target = helpers.color.hex_to_rgba(
                  self.blinking and beautiful.taglist_bg_urgent
                     or beautiful.taglist_bg_occupied
               )
            end,
         }
   end
end

local function new(_, screen)
   local taglist = awful.widget.taglist {
      screen = screen,
      filter = awful.widget.taglist.filter.all,
      buttons = _taglist.buttons.item,
      layout = {
         spacing = dpi(10),
         buttons = _taglist.buttons.layout,
         layout = wibox.layout.fixed.horizontal,
      },
      widget_template = {
         {
            id = 'indicator',
            bg = beautiful.taglist_bg_empty,
            shape = gears.shape.rounded_bar,
            forced_height = _taglist.default_size,
            forced_width = _taglist.default_size,
            widget = wibox.container.background,
         },
         widget = wibox.container.place,

         create_callback = function(widget, tag)
            local indicator = widget:get_children_by_id('indicator')[1]
            widget.size_animator = animation_service {
               initial = _taglist.default_size,
               duration = 0.1,
               update = function(_, pos) indicator.forced_width = pos end,
            }
            widget.color_animator = animation_service {
               initial = helpers.color.hex_to_rgba(beautiful.taglist_bg_empty),
               update = function(_, pos)
                  indicator.bg = helpers.color.rgba_to_hex(pos)
               end,
            }
            _taglist.update(widget, tag)
         end,
         update_callback = _taglist.update,
      },
   }

   return taglist
end

return setmetatable(_taglist, { __call = new })
