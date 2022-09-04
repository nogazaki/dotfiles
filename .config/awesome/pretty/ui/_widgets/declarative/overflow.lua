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

--------------------------------------------------

local _overflow = {}

function _overflow:fit(context, width, height)
    if not self._private.widget then return 0, 0 end

    local fit_width = self._private.dir == "x" and math.huge or width
    local fit_height = self._private.dir == "y" and math.huge or height

    -- Get the size that the child widget wants to use in an unlimited space
    local w, h = wibox.widget.base.fit_widget(self, context, self._private.widget, fit_width, fit_height)

    return math.min(w, width), math.min(h, height)
end
function _overflow:layout(context, width, height)
    if not self._private.widget then return end

    local is_x = self._private.dir == "x"

    local layout_width = is_x and math.huge or width
    local layout_height = not is_x and math.huge or height

    -- Get the size that the child widget wants to use in an unlimited space
    local w, h = wibox.widget.base.fit_widget(self, context, self._private.widget, layout_width, layout_height)

    -- Is scroll widget required?
    layout_width = self._private.enable_scroll and not is_x and h > height and
        layout_width - (self._private.scroll_widget_size or dpi(10)) or layout_width
    layout_height = self._private.enable_scroll and is_x and w > width and
        layout_height - (self._private.scroll_widget_size or dpi(10)) or layout_height
    w, h = wibox.widget.base.fit_widget(self, context, self._private.widget, layout_width, layout_height)

    layout_width, layout_height = math.min(layout_width, width), math.min(layout_height, height)

    local x, y = 0, 0
    local need_scrollbar, visible_percentage
    if is_x then
        local min = (layout_width - w >= 0) and 0 or layout_width - w
        self._private.offset = helpers.misc.clip(self._private.offset or 0, min, 0)

        x = self._private.enable_scroll and self._private.offset or 0
        need_scrollbar = self._private.enable_scroll and min < 0
        visible_percentage = layout_width / w
        self._private.visible = visible_percentage
    else
        local min = (layout_height - h >= 0) and 0 or layout_height - h
        self._private.offset = helpers.misc.clip(self._private.offset or 0, min, 0)

        y = self._private.enable_scroll and self._private.offset or 0
        need_scrollbar = self._private.enable_scroll and min < 0
        visible_percentage = layout_height / h
        self._private.visible = visible_percentage
    end

    local results = {}
    table.insert(results, wibox.widget.base.place_widget_at(self._private.widget, x, y, w, h))

    if need_scrollbar then
        local bar_w = is_x and visible_percentage * layout_width or self._private.scroll_widget_size or dpi(10)
        local bar_h = not is_x and visible_percentage * layout_height or self._private.scroll_widget_size or dpi(10)
        local bar_x = is_x and - (layout_width * x / w) or layout_width
        local bar_y = not is_x and - (layout_height * y / h) or layout_height

        table.insert (
            results,
            wibox.widget.base.place_widget_at(self._private.scroll_widget,
            bar_x, bar_y, bar_w, bar_h)
        )
    end

    self:emit_signal("widget::redraw_needed")

    return results
end
function _overflow.before_draw_children(_, _, cr, width, height)
    -- Clip drawing for children to the space we're allowed to draw in
    cr:rectangle(0, 0, width, height)
    cr:clip()
end

_overflow.set_widget = wibox.widget.base.set_widget_common
_overflow.get_widget = function (self) return self._private.widget end
_overflow.set_children = function (self, children) self:set_widget(children[1]) end
_overflow.get_children = function (self) return { self:get_widget() } end

function _overflow:set_enable_scroll(value)
    if type(value) ~= "boolean" then return end
    self._private.enable_scroll = value
    self:emit_signal("widget::layout_changed")
end

local function build_grabber(self, initial_x, initial_y, geo)
    local is_x = self._private.dir == "x"
    local start_offset = self._private.offset
    local start_pos = is_x and initial_x or initial_y

    local matrix_from_device = geo.hierarchy:get_matrix_from_device()
    local wgeo = geo.drawable.drawable:geometry()
    local matrix = matrix_from_device:translate(- wgeo.x, - wgeo.y)

    return function (mouse)
        if not mouse.buttons[1] then return false end

        local x, y = matrix:transform_point(mouse.x, mouse.y)
        local pos = is_x and x or y
        self:set_offset(start_offset - (pos - start_pos) / (self._private.visible))

        return true
    end
end
local function scroll_widget_button(self, scroll_widget)
    scroll_widget:connect_signal("button::press", function (_, x, y, button_id, _, geo)
        if button_id ~= 1 then return end
        capi.mousegrabber.run(build_grabber(self, x, y, geo), "left_ptr")
    end)
end
function _overflow:set_scroll_widget(widget)
    local w = wibox.widget.base.make_widget_from_value(widget)
    scroll_widget_button(self, w)

    self._private.scroll_widget = w
    self:emit_signal("widget::layout_changed")
end

function _overflow:set_offset(value)
    if type(value) ~= "number" then return end
    self._private.offset = value
    self:emit_signal("widget::layout_changed")
end
function _overflow:get_offset()
    return self._private.offset
end
function _overflow:set_scroll_step(value)
    if type(value) ~= "number" then return end
    self._private.scroll_step = value
end
function _overflow:get_scroll_step()
    return self._private.scroll_step
end
function _overflow:set_scroll_widget_size(value)
    if type(value) ~= "number" then return end
    self._private.scroll_widget_size = value
end

function _overflow:reset_scroll()
    self.offset = 0
end

-- Return a new overflow container
-- Child widget can take as much space as they want on one axis
-- If the size needed exceeds the size available then it will crop the child widget
local function new(direction)
    local ret = wibox.widget.base.make_widget(nil, nil, { enable_properties = true })

    gears.table.crush(ret, _overflow, true)
    ret._private.dir = direction
    -- Tell the widget system to prevent clicks outside the layout's extends
    ret.clip_child_extends = true

    ret.buttons = {
        awful.button {
            modifiers = {},
            button    = 4,
            on_press  = function ()
                if direction == "y" then ret.offset = (ret.offset or 0) + (ret.scroll_step or 15) end
            end,
        },
        awful.button {
            modifiers = {},
            button    = 5,
            on_press  = function ()
                if direction == "y" then ret.offset = (ret.offset or 0) - (ret.scroll_step or 15) end
            end,
        },
        awful.button {
            modifiers = { mod.shift },
            button    = 4,
            on_press  = function ()
                if direction == "x" then ret.offset = (ret.offset or 0) + (ret.scroll_step or 15) end
            end,
        },
        awful.button {
            modifiers = { mod.shift },
            button    = 5,
            on_press  = function ()
                if direction == "x" then ret.offset = (ret.offset or 0) - (ret.scroll_step or 15) end
            end,
        },
    }
    local scrollbar = wibox.widget {
        bg     = beautiful.accent_color,
        shape  = gears.shape.rounded_bar,
        widget = wibox.container.background,
    }
    scroll_widget_button(ret, scrollbar)
    ret._private.scroll_widget = scrollbar

    return ret
end

function _overflow.horizontal()
    return new("x")
end
function _overflow.vertical()
    return new("y")
end

return _overflow
