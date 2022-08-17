-- Standard awesome library
local gears = require("gears")

local helpers = require("helpers")

local mouse = _G.mouse

local setmetatable, type = setmetatable, type

--------------------------------------------------

local container = require("pretty.ui._widget.container")
local animation = require("evil.animation")

local _button = {}

local function effect(button, bg)
    if not button.animation or not bg then return end

    button.animation:set { color = helpers.color.hex_to_rgba(bg) }
end

function _button.normal(args)
    args = args or {}
    args = (args.widget or args.is_widget) and { args } or args

    args.bg = args.bg or ((args.bg_hover or args.bg_press) and "#00000000")
    args.bg_hover = args.bg_hover or (args.bg_press and args.bg)

    local ret = container(args)
    if not ret or not ret.get_children_by_id then return end

    -- Animation
    if args.bg and (args.bg_hover or args.bg_press) then
        ret.animation = animation {
            duration = 0.1,
            initial  = { color = helpers.color.hex_to_rgba(args.bg) },
            update   = function (_, pos)
                ret:get_children_by_id("background")[1].bg = helpers.color.rgba_to_hex(pos.color)
            end
        }
    end

    local content = args.margins and ret:get_children_by_id("margins")[1].widget or ret

    content:connect_signal("mouse::enter", function (...)
        effect(ret, args.bg_hover)

        if type(args.on_mouse_hover) == "function" then args.on_mouse_hover(...) end

        ret.wbox_backup = mouse.current_wibox
        if ret.wbox_backup then
            ret.cursor_backup = ret.wbox_backup.cursor
            ret.wbox_backup.cursor = args.cursor or "hand1"
        end
    end)
    content:connect_signal("mouse::leave", function (...)
        effect(ret, args.bg)

        if type(args.on_mouse_leave) == "function" then args.on_mouse_leave(...) end

        if ret.wbox_backup then
            ret.wbox_backup.cursor = ret.cursor_backup
            ret.wbox_backup, ret.cursor_backup = nil, nil
        end
    end)
    content:connect_signal("button::press", function (...)
        effect(ret, args.bg_press)

        if type(args.on_button_press) == "function" then args.on_button_press(...) end
    end)
    content:connect_signal("button::release", function (...)
        effect(ret, args.bg_hover)

        if type(args.on_button_release) == "function" then args.on_button_release(...) end
    end)

    gears.table.join(args.buttons, ret.buttons)
    ret.buttons = nil; content.buttons = args.buttons

    return ret
end

function _button.new(_, ...)
    return _button.normal(...)
end

return setmetatable(_button, { __call = _button.new })
