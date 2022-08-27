-- Standard awesome library
local awful = require("awful")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")

local helpers = require("helpers")

local capi = require("capi")

--------------------------------------------------

local widgets = require("pretty.ui._widgets")
local animation = require("evil.animation")

local _layoutbox = {}
_layoutbox.manager = nil

local function get_screen(s) return s and capi.screen[s] end
local function update(widget, screen)
    local name = awful.layout.getname(awful.layout.get(get_screen(screen)))
    widget:set_image(beautiful["layout_" .. name])
end
local function update_from_tag(tag)
    local screen = get_screen(tag.screen)
    local widget = _layoutbox.manager[screen]
    if widget then update(widget, screen) end
end

function _layoutbox:new(screen)
    screen = get_screen(screen or 1)
    -- Do we already have the update callbacks registered?
    if self.manager == nil then
        self.manager = setmetatable({}, { __mode = "kv" })
        capi.tag.connect_signal("property::selected", update_from_tag)
        capi.tag.connect_signal("property::layout", update_from_tag)
        capi.tag.connect_signal("property::screen", function()
            for s, w in pairs(self.manager) do
                if s.valid then update(w, s) end
            end
        end)
    end

    local layoutbox = self.manager[screen]
    if not layoutbox then
        layoutbox = widgets.button {
            {
                image      = beautiful.profile_pic,
                stylesheet = string.format("svg { fill:%s; }", beautiful.fg_normal),
                widget     = wibox.widget.imagebox,
            },
            on_mouse_enter = function (widget)
                widget.animation:set(helpers.color.hex_to_rgba(beautiful.accent_color))
            end,
            on_mouse_leave = function (widget)
                widget.animation:set(helpers.color.hex_to_rgba(beautiful.fg_normal))
            end,
            on_button_press = function (widget)
                widget.animation:set(helpers.color.hex_to_rgba(beautiful.xcolor1))
            end,
            on_button_release = function (widget, _, _, button, mods)
                widget.animation:set(helpers.color.hex_to_rgba(beautiful.accent_color))
                if #mods ~= 0 then return end
                if button == 1 then
                    awful.layout.inc(1, screen)
                elseif button == 3 then
                    awful.layout.inc(-1, screen)
                end
            end,
        }
        layoutbox.animation = animation {
            initial  = helpers.color.hex_to_rgba(beautiful.fg_normal),
            duration = 0.1,
            update   = function (_, pos)
                layoutbox:set_stylesheet(string.format("svg { fill:%s; }", helpers.color.rgba_to_hex(pos)))
            end
        }

        update(layoutbox, screen)
        self.manager[screen] = layoutbox
    end

    update(layoutbox, screen)

    return layoutbox
end

return setmetatable(_layoutbox, { __call = _layoutbox.new })
