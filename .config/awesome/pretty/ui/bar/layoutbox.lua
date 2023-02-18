local capi = require 'capi'
-- Standard awesome library
local awful = require 'awful'
-- Widget and layout library
local wibox = require 'wibox'
-- Theme handling library
local beautiful = require 'beautiful'

local helpers = require 'helpers'

--------------------------------------------------

local mod = require 'configuration.bindings.mod'

local widgets = require 'pretty.ui._widgets'

local animation_service = require 'evil.animation'

--------------------------------------------------

local _layoutbox = {}
_layoutbox.manager = nil

local function get_screen(s) return s and capi.screen[s] end
local function update(widget, screen)
   local name = awful.layout.getname(awful.layout.get(get_screen(screen)))
   widget:set_image(beautiful['layout_' .. name])
end
local function update_from_tag(tag)
   local screen = get_screen(tag.screen)
   local widget = _layoutbox.manager[screen]
   if widget then update(widget, screen) end
end

local function new(_, screen)
   screen = get_screen(screen or 1)
   -- Do we already have the update callbacks registered?
   if _layoutbox.manager == nil then
      _layoutbox.manager = setmetatable({}, { __mode = 'kv' })
      capi.tag.connect_signal('property::selected', update_from_tag)
      capi.tag.connect_signal('property::layout', update_from_tag)
      capi.tag.connect_signal('property::screen', function()
         for s, w in pairs(_layoutbox.manager) do
            if s.valid then update(w, s) end
         end
      end)
   end

   local layoutbox = _layoutbox.manager[screen]
   if not layoutbox then
      layoutbox = widgets.button {
         wibox.widget.imagebox(),
         normal = beautiful.fg_normal,
         hover = beautiful.accent_color,
         press = beautiful.accent_color .. '88',

         create_callback = function(widget, _, args)
            widget.animation = animation_service {
               duration = 0.1,
               initial = helpers.color.hex_to_rgba(args.normal),
               update = function(_, pos)
                  widget.stylesheet = string.format(
                     'svg { fill:%s; }',
                     helpers.color.rgba_to_hex(pos)
                  )
               end,
            }
            widget.animation:emit_signal(
               'updated',
               helpers.color.hex_to_rgba(args.normal)
            )

            widget.buttons = {
               awful.button {
                  modifiers = { mod.ctrl },
                  button = 1,
                  on_release = function()
                     awful.layout.inc(1, screen)
                     widget.animation.target =
                        helpers.color.hex_to_rgba(args.hover)
                  end,
               },
               awful.button {
                  modifiers = { mod.ctrl },
                  button = 3,
                  on_release = function()
                     awful.layout.inc(-1, screen)
                     widget.animation.target =
                        helpers.color.hex_to_rgba(args.hover)
                  end,
               },
            }
         end,
         update_callback = function(widget, _, args, action)
            if action == 'mouse::enter' then
               widget.animation.target = helpers.color.hex_to_rgba(args.hover)
            end
            if action == 'mouse::leave' then
               widget.animation.target = helpers.color.hex_to_rgba(args.normal)
            end
            if action == 'button::press' then
               widget.animation.target = helpers.color.hex_to_rgba(args.press)
            end
            if action == 'button::release' then
               widget.animation.target = helpers.color.hex_to_rgba(args.hover)
            end
         end,
      }

      update(layoutbox, screen)
      _layoutbox.manager[screen] = layoutbox
   end

   update(layoutbox, screen)

   return layoutbox
end

return setmetatable(_layoutbox, { __call = new })
