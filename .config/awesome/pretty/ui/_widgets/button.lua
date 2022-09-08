local capi = require("capi")
-- Standard awesome library
local gears = require("gears")
-- Theme handling library
local beautiful = require("beautiful")

local helpers = require("helpers")

--------------------------------------------------

local container = require("pretty.ui._widgets.container")

local animation_service = require("evil.animation")

--------------------------------------------------

local _button = {}

local Button = {}
function Button:effect(bg, fg, opacity)
    if not self.animation then return end
    if not bg and not opacity then return end
    self.animation.target = {
        bg      = bg and helpers.color.hex_to_rgba(bg) or nil,
        fg      = fg and helpers.color.hex_to_rgba(fg) or nil,
        opacity = opacity,
    }
end
function Button:turn_on()
    if self.state then return end
    self.state = true
    self:emit_signal("button::state", true)
end
function Button:turn_off()
    if not self.state then return end
    self.state = nil
    self:emit_signal("button::state", false)
end
function Button:toggle()
    self[self.state and "turn_off" or "turn_on"](self)
end

function _button.normal(args)
    args = args or {}
    args = (args.widget or args.layout or args.is_widget) and { args } or args

    args.bg = args.bg or ((args.bg_hover or args.bg_press) and "#00000000")
    args.bg_hover = args.bg_hover or (args.bg_press and args.bg)

    args.opacity = args.opacity or ((args.opacity_hover or args.opacity_press) and 1)
    args.opacity_hover = args.opacity_hover or (args.opacity_press and args.opacity)

    local ret = container(args)
    if not ret then return end
    ret.effect = Button.effect

    if args.bg or args.opacity then
        local background = ret.get_children_by_id and ret:get_children_by_id("background")[1]
        ret.animation = animation_service {
            duration = 0.1,
            initial  = {
                bg      = args.bg and helpers.color.hex_to_rgba(args.bg),
                opacity = args.opacity,
            },
            update = function (_, pos)
                if background then background.bg = pos.bg and helpers.color.rgba_to_hex(pos.bg) end
                ret.opacity = pos.opacity or ret.opacity
            end
        }
    end

    local content = args.margins and ret:get_children_by_id("margins")[1].widget or ret
    content:connect_signal("mouse::enter", function (_, ...)
        -- Cursor
        ret.wbox_backup = capi.mouse.current_wibox
        if ret.wbox_backup then
            ret.cursor_backup = ret.wbox_backup.cursor
            ret.wbox_backup.cursor = args.cursor or "hand1"
        end
        -- Call functions
        if type(args.on_mouse_enter) == "function" then args.on_mouse_enter(ret, ...) end
        -- Effect
        ret:effect(args.bg_hover, args.fg_hover, args.opacity_hover)
    end)
    content:connect_signal("mouse::leave", function (self, ...)
        self.pressed = nil
        -- Cursor
        if ret.wbox_backup then
            ret.wbox_backup.cursor = ret.cursor_backup
            ret.wbox_backup, ret.cursor_backup = nil, nil
        end
        -- Call functions
        if type(args.on_mouse_leave) == "function" then args.on_mouse_leave(ret, ...) end
        -- Effect
        ret:effect(args.bg, args.fg, args.opacity)
    end)
    content:connect_signal("button::press", function (self, ...)
        self.pressed = true
        -- Call functions
        if type(args.on_button_press) == "function" then args.on_button_press(ret, ...) end
        -- Effect
        ret:effect(args.bg_press, args.fg_press, args.opacity_press)
    end)
    content:connect_signal("button::release", function (self, ...)
        if not self.pressed then return end
        self.pressed = nil
        -- Call functions
        if type(args.on_button_release) == "function" then args.on_button_release(ret, ...) end
        ret:emit_signal("button::trigger", ...)
        -- Effect
        ret:effect(args.bg_hover, args.fg_hover, args.opacity_hover)
    end)

    return ret
end

function _button.state(args)
    args = args or {}
    args = (args.widget or args.layout or args.is_widget) and { args } or args

    for key, _ in pairs(args) do
        if type(key) == "string" and key:match("bg") then
            args.bg = args.bg or "#00000000"
            args.bg_on = args.bg_on or beautiful.accent_color
            args.bg_hover = args.bg_hover or args.bg
            args.bg_on_hover = args.bg_on_hover or args.bg_on
        end
        if type(key) == "string" and key:match("fg") then
            args.fg = args.fg or beautiful.fg_normal
            args.fg_on = args.fg_on or beautiful.fg_focus
            args.fg_hover = args.fg_hover or args.fg
            args.fg_on_hover = args.fg_on_hover or args.fg_on
        end

        if type(key) == "string" and key:match("opacity") then
            args.opacity = args.opacity or 0.5
            args.opacity_hover = args.opacity_hover or args.opacity
            args.opacity_on_hover = args.opacity_on_hover or args.opacity_on
        end
    end

    local ret = container(args)
    if not ret then return end
    gears.table.crush(ret, Button, true)

    -- Animation
    local background = ret.get_children_by_id and ret:get_children_by_id("background")[1] or nil
    ret.animation = animation_service {
        duration = 0.1,
        initial  = {
            bg      = args.bg and helpers.color.hex_to_rgba(args.bg) or nil,
            fg      = args.fg and helpers.color.hex_to_rgba(args.fg) or nil,
            opacity = args.opacity,
        },
        update   = function (_, pos)
            if background then
                background.bg = pos.bg and helpers.color.rgba_to_hex(pos.bg)
                background.fg = pos.fg and helpers.color.rgba_to_hex(pos.fg)
            end
            ret.opacity = pos.opacity or ret.opacity
        end
    }

    local content = args.margins and ret:get_children_by_id("margins")[1].widget or ret
    content:connect_signal("mouse::enter", function (_, ...)
        -- Cursor
        ret.wbox_backup = capi.mouse.current_wibox
        if ret.wbox_backup then
            ret.cursor_backup = ret.wbox_backup.cursor
            ret.wbox_backup.cursor = args.cursor or "hand1"
        end
        -- Call functions
        if type(args.on_mouse_enter) == "function" then args.on_mouse_enter(ret, ...) end
        -- Effects
        if ret.state then
            ret:effect(args.bg_on_hover, args.fg_on_hover, args.opacity_on_hover)
        else
            ret:effect(args.bg_hover, args.fg_hover, args.opacity_hover)
        end
    end)
    content:connect_signal("mouse::leave", function (self, ...)
        self.pressed = nil
        -- Cursor
        if ret.wbox_backup then
            ret.wbox_backup.cursor = ret.cursor_backup
            ret.wbox_backup, ret.cursor_backup = nil, nil
        end
        -- Call functions
        if type(args.on_mouse_leave) == "function" then args.on_mouse_leave(ret, ...) end
        -- Effects
        if ret.state then
            ret:effect(args.bg_on, args.fg_on, args.opacity_on)
        else
            ret:effect(args.bg, args.fg, args.opacity)
        end
    end)
    content:connect_signal("button::press", function (self, ...)
        self.pressed = true
        -- Call functions
        if type(args.on_button_press) == "function" then args.on_button_press(ret, ...) end
        -- Effects
        if ret.state then
            ret:effect(args.bg_on_press, args.fg_on_press, args.opacity_on_press)
        else
            ret:effect(args.bg_press, args.fg_press, args.opacity_press)
        end
    end)
    content:connect_signal("button::release", function (self, ...)
        if not self.pressed then return end
        self.pressed = nil
        -- Call functions
        if type(args.on_button_release) == "function" then args.on_button_release(ret, ...) end
        ret:emit_signal("button::trigger", ...)
        -- Effects
        if ret.state then
            ret:effect(args.bg_on_hover, args.fg_on_hover, args.opacity_on_hover)
        else
            ret:effect(args.bg_hover, args.fg_hover, args.opacity_hover)
        end
    end)

    ret:connect_signal("button::state", function (_, state)
        if state then
            ret:effect(args.bg_on, args.fg_on, args.opacity_on)
        else
            ret:effect(args.bg, args.fg, args.opacity)
        end
    end)

    return ret
end

local function new(_, ...)
    return _button.normal(...)
end

return setmetatable(_button, { __call = new })
