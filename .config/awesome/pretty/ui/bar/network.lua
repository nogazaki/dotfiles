local capi = require("capi")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")

--------------------------------------------------

local assets_path = capi.awesome.conffile:match("^(.-)rc%.lua$") .. "pretty/assets/"

local network_service = require("evil.network")

--------------------------------------------------

local icon = wibox.widget {
    image      = assets_path .. "ethernet.svg",
    halign     = "center",
    resize     = true,
    stylesheet = string.format("svg { fill:%s; }", beautiful.xcolor3 .. "44"),
    opacity    = 0,
    widget     = wibox.widget.imagebox,
}

network_service:connect_signal("network::type", function (_, connection_type)
    if connection_type:match("wireless") then
        icon:set_image(assets_path .. "wireless.svg")
        icon.stylesheet = string.format("svg { fill:%s; }", beautiful.xcolor3 .. "44")
    else
        icon:set_image(assets_path .. "ethernet.svg")
        icon.stylesheet = string.format("svg { fill:%s; }", beautiful.xcolor3)
    end
end)
network_service:connect_signal("network::state", function (_, state)
    local indicator = state == network_service.State.CONNECTED_LOCAL
    indicator = indicator or state == network_service.State.CONNECTED_SITE
    indicator = indicator or state == network_service.State.CONNECTED_GLOBAL

    icon.opacity = indicator and 1 or 0
end)
network_service:connect_signal("wireless::active_access_point", function (_, _, strength)
    if not network_service.primary_type:match("wireless") then return end
    local level = math.floor(strength / 25)

    local stylesheet = ""
    for i = 0, 3 do
        stylesheet = stylesheet .. string.format (
            ".p%d { fill:%s%s; } ", i, beautiful.xcolor3,
            i <= level and "" or "44"
        )
    end
    icon.stylesheet = stylesheet
end)

return icon
