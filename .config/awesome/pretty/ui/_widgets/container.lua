-- Widget and layout library
local wibox = require("wibox")

--------------------------------------------------

local _container = {}

local function new(_, args)
    args = args or {}
    local ret = (args.widget or args.is_widget or args.layout) and args or args[1]

    -- Rotation
    if args.direction then
        ret = {
            ret,
            id        = "container_rotate",
            direction = args.direction,
            widget    = wibox.container.rotate,
        }
    end
    -- Alignments
    if args.halign or args.valign then
        ret = {
            ret,
            id     = "container_align",
            halign = args.halign,
            valign = args.valign,
            widget = wibox.container.place,
        }
    end
    -- Paddings
    if args.paddings then
        ret = {
            ret,
            id      = "container_padding",
            margins = args.paddings,
            widget  = wibox.container.margin,
        }
    end
    -- Background and shape
    if args.bg or args.fg or args.shape or args.border_width or args.border_color then
        ret = {
            ret,
            id           = "container_background",
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
            id      = "container_margin",
            margins = args.margins,
            widget  = wibox.container.margin,
        }
    end
    -- Constraint
    if args.constraint_strategy or args.constraint_width or args.constraint_height then
        ret = {
            ret,
            id       = "container_constraint",
            strategy = args.constraint_strategy,
            width    = args.constraint_width,
            height   = args.constraint_height,
            widget   = wibox.container.constraint,
        }
    end

    if not ret then return end

    ret.forced_width = args.forced_width or ret.forced_width
    ret.forced_height = args.forced_height or ret.forced_height
    ret.opacity = args.opacity or ret.opacity

    return ret.is_widget and ret or wibox.widget(ret)
end

return setmetatable(_container, { __call = new })
