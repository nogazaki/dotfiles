-- Standard awesome library
local gears = require("gears")
-- Widget and layout library
local wibox = require("wibox")

local math = math
local setmetatable = setmetatable

--------------------------------------------------

local _overflow = {}

local near_inf = 2 ^ 50
function _overflow:fit(context, width, height)
    if not self._private.widget then return 0, 0 end

    -- Get the size that the child widget wants to use in an unlimited space
    -- Cant use math.huge beacause of some -nan stuffs
    local w, h = wibox.widget.base.fit_widget(self, context, self._private.widget, near_inf, near_inf)

    return math.min(width, w), math.min(height, h)
end

function _overflow:layout(context, width, height)
    if not self._private.widget then return end

    -- Get the size that the child widget wants to use in an unlimited space
    -- Cant use math.huge beacause of some -nan stuffs
    local w, h = wibox.widget.base.fit_widget(self, context, self._private.widget, near_inf, near_inf)

    w = self._private.crop_horizontal and w or width
    h = self._private.crop_vertical and h or height

    local x = self._private.halign == "center" and (width - w) / 2 or
        (self._private.halign == "right" and width - w or 0)
    local y = self._private.valign == "center" and (height - h) / 2 or
        (self._private.valign == "bottom" and height - h or 0)


    return { wibox.widget.base.place_widget_at(self._private.widget, x, y, w, h) }
end
function _overflow.before_draw_children(_, _, cr, width, height)
    -- Clip drawing for children to the space we're allowed to draw in
    cr:rectangle(0, 0, width, height)
    cr:clip()
end

_overflow.set_widget = wibox.widget.base.set_widget_common
_overflow.get_widget = function (self) return self._private.widget end
_overflow.set_children = function (self, children) self:set_widget(children[1]) end
_overflow.get_children = function (self) return { self._private.widget } end

function _overflow:set_crop_horizontal(value)
    self._private.crop_horizontal = value
    self:emit_signal("widget::layout_changed")
end
function _overflow:set_crop_vertical(value)
    self._private.crop_vertical = value
    self:emit_signal("widget::layout_changed")
end
function _overflow:set_halign(value)
    if value ~= "center" and value ~= "left" and value ~= "right" then return end

    self._private.halign = value
    self:emit_signal("widget::layout_changed")
end
function _overflow:set_valign(value)
    if value ~= "center" and value ~= "top" and value ~= "bottom" then return end

    self._private.valign = value
    self:emit_signal("widget::layout_changed")
end

-- Return a new crop container
-- Child widget can take as much space as they want
-- If the size needed exceeds the size available then it will crop the child widget
local function new()
    local ret = wibox.widget.base.make_widget(nil, nil, { enable_properties = true })

    gears.table.crush(ret, _overflow, true)
    -- Tell the widget system to prevent clicks outside the layout's extends
    ret.clip_child_extends = true

    return ret
end

return setmetatable(_overflow, { __call = new })
