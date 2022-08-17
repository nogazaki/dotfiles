-- Widget and layout library
local wibox = require("wibox")

--------------------------------------------------

local _spacer = {}

function _spacer.vertical(height, color)
    return wibox.widget {
        forced_height = height,
        bg            = color or "#00000000",
        widget        = wibox.container.background,
    }
end
function _spacer.horizontal(height, color)
    return wibox.widget {
        forced_width = height,
        bg           = color or "#00000000",
        widget       = wibox.container.background,
    }
end

return _spacer
