-- Standard awesome library
local gears = require("gears")
-- Widget and layout library
local wibox = require("wibox")

--------------------------------------------------

local overflow = require("pretty.ui._widgets.declarative.overflow")
local animation = require("evil.animation")

local _scroll = {}

function _scroll:fit(context, width, height)
    if not self._private.widget then return 0, 0 end

    -- Get the size that the child widget wants to use in an unlimited space
    local w, h = wibox.widget.base.fit_widget(self, context, self._private.widget, math.huge, math.huge)

    return math.min(width, w), math.min(height, h)
end
function _scroll:layout(context, width, height)
    if not self._private.widget then return end
    local is_x = self._private.dir == "x"

    -- Get the size that the child widget wants to use in an unlimited space
    local w, h = wibox.widget.base.fit_widget(self, context, self._private.widget, math.huge, math.huge)

    if (is_x and w <= width) or (not is_x and h <= height) then
        if self._private.animation then
            self._private.animation:stop()
            self._private.animation = nil
        end
        return { wibox.widget.base.place_widget_at(self._private.widget, 0, 0, width, height) }
    end

    w = is_x and w or width
    h = is_x and height or h

    if not self._private.animation then
        self._private.animation = animation {
            duration = 1000, initial = 0, target = 1000,
            update   = function () self:emit_signal("widget::layout_changed") end,
        }
        self._private.animation:connect_signal("ended", function (anim, pos)
            anim.target = pos * 2
        end)

        self._private.animation:restart()
    end

    local offset = - self._private.step_function (
        self._private.animation.pos,
        is_x and w or h,
        is_x and width or height,
        self._private.speed,
        self._private.extra_space
    )

    if is_x then
        local second_x = w + self._private.extra_space + offset

        return {
            wibox.widget.base.place_widget_at(self._private.widget, offset, 0, w, h),
            wibox.widget.base.place_widget_at(self._private.widget, second_x, 0, w, h)
        }
    else
        local second_y = h + self._private.extra_space + offset
        return {
            wibox.widget.base.place_widget_at(self._private.widget, 0, offset, w, h),
            wibox.widget.base.place_widget_at(self._private.widget, 0, second_y, w, h)
        }
    end
end
_scroll.before_draw_children = overflow.before_draw_children

_scroll.set_widget = wibox.widget.base.set_widget_common
_scroll.get_widget = function (self) return self._private.widget end
_scroll.set_children = function (self, children) self:set_widget(children[1]) end
_scroll.get_children = function (self) return { self._private.widget, self._private.widget } end

function _scroll:set_extra_space(value)
    if type(value) ~= "number" then return end
    self._private.extra_space = value
end
function _scroll:set_speed(value)
    if type(value) ~= "number" then return end
    self._private.speed = value
end
function _scroll:set_step_function(func)
    if type(func) ~= "function" then return end
    self._private.step_function = func
end

function _scroll:pause()
    if not self._private.animation then return end
    self._private.animation:stop()
end
function _scroll:continue()
    if not self._private.animation then return end
    self._private.animation:start()
end
function _scroll:reset_scrolling()
    if not self._private.animation then return end
    self._private.animation:restart()
end

local function new(direction)
    local ret = wibox.widget.base.make_widget(nil, nil, { enable_properties = true })

    gears.table.crush(ret, _scroll, true)
    ret._private.dir = direction

    -- Tell the widget system to prevent clicks outside the layout's extends
    ret.clip_child_extends = true

    return ret
end

function _scroll.horizontal()
    return new("x")
end

function _scroll.vertical()
    return new("y")
end

return _scroll
