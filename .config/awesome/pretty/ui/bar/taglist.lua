local capi = require("capi")
-- Standard awesome library
local awful = require("awful")
local gears = require("gears")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local helpers = require("helpers")

--------------------------------------------------

local mod = require("configuration.bindings.mod")

local widgets = require("pretty.ui._widgets")

local animation_service = require("evil.animation")

--------------------------------------------------

local _taglist = {}
_taglist.buttons = {
    layout = {
        awful.button {
            modifiers = {},
            button    = 4,
            on_press  = function () awful.tag.viewprev() end,
        },
        awful.button {
            modifiers = {},
            button    = 5,
            on_press  = function () awful.tag.viewnext() end,
        },
    },
    item = {
        awful.button {
            modifiers  = {},
            button     = 1,
            on_release = function (t)
                t:view_only()
            end,
        },
        awful.button {
            modifiers  = { mod.super },
            button     = 1,
            on_release = function (t)
                if capi.client.focus then capi.client.focus:move_to_tag(t) end
            end,
        },
        awful.button {
            modifiers  = {},
            button     = 3,
            on_release = awful.tag.viewtoggle,
        },
    }
}
function _taglist:update(tag)
    self:get_children_by_id("indicator")[1]:set_markup_silently(#tag:clients() > 0 and "" or "")

    if not tag.urgent then
        if self.timer then self.timer:stop(); self.timer = nil end
        self.blinking = nil

        self.fg = beautiful.bg_focus
        self.animation.target = helpers.color.hex_to_rgba (
            beautiful.bg_focus .. (tag.selected and "88" or "00")
        )
    else
        self.fg = beautiful.bg_urgent
        self.timer = self.timer or gears.timer {
            timeout     = 1,
            autostart   = true,
            call_now    = true,
            single_shot = false,
            callback    = function ()
                self.blinking = not self.blinking
                self.animation.target = helpers.color.hex_to_rgba (
                    beautiful.bg_urgent .. (self.blinking and "88" or "22")
                )
            end,
        }
    end
end

function _taglist:new(screen)
    local taglist = awful.widget.taglist {
        screen  = screen,
        filter  = awful.widget.taglist.filter.all,
        buttons = self.buttons.item,
        layout = {
            spacing = dpi(10),
            buttons = self.buttons.layout,
            layout  = wibox.layout.fixed.vertical,
        },
        widget_template = setmetatable({}, { __call = function ()
            local ret = widgets.button {
                {
                    id     = "indicator",
                    markup = "",
                    align  = "center",
                    font   = "FiraCode Nerd Font Mono 12",
                    widget = wibox.widget.textbox,
                },
                border_width  = 0,
                fg            = beautiful.bg_focus,
                shape         = helpers.ui.rrect(beautiful.border_radius),
                forced_height = dpi(40),
            }

            ret.animation = animation_service {
                initial = helpers.color.hex_to_rgba("#00000000"),
                duration = 0.2,
                update = function (_, pos)
                    ret.bg = helpers.color.rgba_to_hex(pos)
                end,
            }

            ret.create_callback = self.update
            ret.update_callback = self.update

            return ret
        end })
    }
    return taglist
end

return setmetatable(_taglist, { __call = _taglist.new })
