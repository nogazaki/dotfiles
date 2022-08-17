-- Standard awesome library
local gears = require("gears")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")

local helpers = require("helpers")

local setmetatable = setmetatable
local dpi = beautiful.xresources.apply_dpi

--------------------------------------------------

local _container = {}

function _container.new(_, args)
    args = args or {}
    local ret = args[1]

    -- Rotation
    if args.direction then
        ret = {
            ret,
            id        = "rotate",
            direction = args.direction,
            widget    = wibox.container.rotate,
        }
    end
    -- Alignments
    if args.halign or args.valign then
        ret = {
            ret,
            id     = "place",
            halign = args.halign,
            valign = args.valign,
            widget = wibox.container.place,
        }
    end
    -- Paddings
    if args.paddings then
        ret = {
            id      = "paddings",
            margins = args.paddings,
            widget  = wibox.container.margin,
        }
    end
    -- Background and shape
    if args.bg or args.fg or args.shape or args.border_width or args.border_color then
        ret = {
            ret,
            id           = "background",
            bg           = args.bg,
            fg           = args.fg,
            shape        = args.shape,
            border_width = args.border_width,
            border_color = args.border_color,
            widget       = wibox.container.background,
        }
    end
    -- Margins
    if args.margins then
        ret = {
            ret,
            id      = "margins",
            margins = args.margins,
            widget  = wibox.container.margin,
        }
    end
    -- Constraint
    if args.constraint_strategy or args.constraint_width or args.constraint_height then
        ret = {
            ret,
            id       = "constraint",
            strategy = args.constraint_strategy,
            width    = args.constraint_width,
            height   = args.constraint_height,
            widget   = wibox.container.constraint,
        }
    end

    if not ret then return end
    ret.forced_width = args.forced_width
    ret.forced_height = args.forced_height

    return ret.is_widget and ret or wibox.widget(ret)
end

-- Presets
function _container.panel_box(args)
    args = args or {}
    args = (args.widget or args.is_widget) and { args } or args

    gears.table.crush(args, {
        paddings = args. paddings and dpi(10) or nil,
        bg       = args.bg and beautiful.accent_color .. "22" or nil,
        shape    = helpers.ui.rrect(beautiful.border_radius),
        margins  = dpi(5),
    })

    return _container:new(args)
end

return setmetatable(_container, { __call = _container.new })
