-- Standard awesome library
local gears = require("gears")
-- Theme handling library
local beautiful = require("beautiful")

local helpers = require("helpers")

local mouse = _G.mouse

local setmetatable, type = setmetatable, type

--------------------------------------------------

local container = require("pretty.ui._widgets.container")
local animation = require("evil.animation")

local Button = {}
function Button:effect(bg)
    if not self.animation or not bg then return end
    self.animation:set { color = helpers.color.hex_to_rgba(bg) }
end
function Button:turn_on()
    if self.state then return end
    self.state = true
    self:emit_signal("button::state", true)
end
function Button:tunr_off()
    if not self.state then return end
    self.state = nil
    self:emit_signal("button::state", false)
end
function Button:toggle()
    self[self.state and "tunr_off" or "turn_on"](self)
end

local _button = {}

function _button.normal(args)
    args = args or {}
    args = (args.widget or args.is_widget) and { args } or args

    args.bg = args.bg or ((args.bg_hover or args.bg_press) and "#00000000")
    args.bg_hover = args.bg_hover or (args.bg_press and args.bg)

    local ret = container(args)
    if not ret then return end
    gears.table.crush(ret, Button, true)

    -- Animation
    if args.bg_hover then
        ret.animation = animation {
            duration = 0.1,
            initial  = { color = helpers.color.hex_to_rgba(args.bg) },
            update   = function (_, pos)
                ret:get_children_by_id("background")[1].bg = helpers.color.rgba_to_hex(pos.color)
            end
        }
    end

    local content = args.margins and ret:get_children_by_id("margins")[1].widget or ret
    content:connect_signal("mouse::enter", function (_, ...)
        -- Cursor
        ret.wbox_backup = mouse.current_wibox
        if ret.wbox_backup then
            ret.cursor_backup = ret.wbox_backup.cursor
            ret.wbox_backup.cursor = args.cursor or "hand1"
        end
        -- Apply effects
        ret:effect(args.bg_hover)
        -- Call functions
        if type(args.on_mouse_enter) == "function" then args.on_mouse_enter(ret, ...) end
    end)
    content:connect_signal("mouse::leave", function (_, ...)
        -- Cursor
        if ret.wbox_backup then
            ret.wbox_backup.cursor = ret.cursor_backup
            ret.wbox_backup, ret.cursor_backup = nil, nil
        end
        -- Apply effects
        ret:effect(args.bg)
        -- Call functions
        if type(args.on_mouse_leave) == "function" then args.on_mouse_leave(ret, ...) end
    end)
    content:connect_signal("button::press", function (_, ...)
        -- Apply effects
        ret:effect(args.bg_press)
        -- Call functions
        if type(args.on_button_press) == "function" then args.on_button_press(ret, ...) end
    end)
    content:connect_signal("button::release", function (_, ...)
        -- Apply effects
        ret:effect(args.bg_hover)
        -- Call functions
        if type(args.on_button_release) == "function" then args.on_button_release(ret, ...) end
    end)

    return ret
end

function _button.state(args)
    args = args or {}
    args = (args.widget or args.is_widget) and { args } or args

    args.bg = args.bg or ((args.bg_hover or args.bg_press or args.bg_on) and "#00000000")
    args.bg_on = args.bg_on or ((args.bg_on_hover or args.bg_on_press or args.bg) and beautiful.accent_color .. "44")
    args.bg_hover = args.bg_hover or (args.bg_press and args.bg)

    local ret = container(args)
    if not ret then return end
    gears.table.crush(ret, Button, true)

    -- Animation
    if args.bg then
        ret.animation = animation {
            duration = 0.1,
            initial  = { color = helpers.color.hex_to_rgba(args.bg) },
            update   = function (_, pos)
                ret:get_children_by_id("background")[1].bg = helpers.color.rgba_to_hex(pos.color)
            end
        }
    end

    local content = args.margins and ret:get_children_by_id("margins")[1].widget or ret
    content:connect_signal("mouse::enter", function (_, ...)
        -- Cursor
        ret.wbox_backup = mouse.current_wibox
        if ret.wbox_backup then
            ret.cursor_backup = ret.wbox_backup.cursor
            ret.wbox_backup.cursor = args.cursor or "hand1"
        end
        -- Apply effects
        ret:effect(args.bg_hover or (ret.state and args.bg_on or args.bg))
        -- Call functions
        if type(args.on_mouse_enter) == "function" then args.on_mouse_enter(ret, ...) end
    end)
    content:connect_signal("mouse::leave", function (_, ...)
        -- Cursor
        if ret.wbox_backup then
            ret.wbox_backup.cursor = ret.cursor_backup
            ret.wbox_backup, ret.cursor_backup = nil, nil
        end
        -- Apply effects
        ret:effect(ret.state and args.bg_on or args.bg)
        -- Call functions
        if type(args.on_mouse_leave) == "function" then args.on_mouse_leave(ret, ...) end
    end)
    content:connect_signal("button::press", function (_, ...)
        -- Apply effects
        ret:effect(args.bg_press or args.bg_hover)
        -- Call functions
        if type(args.on_button_press) == "function" then args.on_button_press(ret, ...) end
    end)
    content:connect_signal("button::release", function (_, ...)
        ret:toggle()
        -- Apply effects
        ret:effect(ret.state and args.bg_on or args.bg)
        -- Call functions
        if type(args.on_button_release) == "function" then args.on_button_release(ret, ...) end
    end)

    return ret
end

function _button.new(_, ...)
    return _button.normal(...)
end

return setmetatable(_button, { __call = _button.new })
