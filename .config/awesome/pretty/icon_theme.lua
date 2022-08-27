local lgi = require("lgi")
local Gio = lgi.Gio
local Gtk = lgi.require("Gtk", "3.0")

local helpers = require("helpers")

--------------------------------------------------

local _icon = {}

local function get_icon_by_pid(client, apps)
    if not client.pid then return end

    local handle = io.popen(string.format("ps -p %d -o comm=", client.pid))
    if not handle then return end
    local command = helpers.string.trim(handle:read("*a"))
    handle:close()

    for _, app in ipairs(apps) do
        local executable = app:get_executable()
        if executable and executable:find(command, 1, true) then
            return _icon:get_gicon_path(app:get_icon())
        end
    end
end
local function get_icon_by_icon_name(client, apps)
    local icon_name = client.icon_name and client.icon_name:lower() or nil
    if not icon_name then return end

    for _, app in ipairs(apps) do
        local name = app:get_name():lower()
        if name and name:find(icon_name, 1, true) then
            return _icon:get_gicon_path(app:get_icon())
        end
    end
end
local function get_icon_by_class(client, apps)
    local class = client.class or client.instance
    if not class then return end

    class = class:lower()

    -- Try to match with dashes removed
    local class_1 = class:gsub("%-", "")
    -- Try to match with dashes replaced by dots
    local class_2 = class:gsub("%-", ".")
    -- Try to match only the first word
    local class_3 = class:match("(.-)-") or class
    class_3 = class_3:match("(.-)%.") or class_3
    class_3 = class_3:match("(.-)%s+") or class_3

    local possible_icon_names = { class, class_3, class_2, class_1 }

    for _, app in ipairs(apps) do
        local id = app:get_id():lower()
        for _, name in ipairs(possible_icon_names) do
            if id and id:find(name, 1, true) then
                return _icon:get_gicon_path(app:get_icon())
            end
        end
    end
end

local Icon = {}
function Icon:choose_icon(icon_names)
    local icon_info = self.gtk_theme:choose_icon(icon_names, self.icon_size, 0)
    return icon_info and icon_info:get_filename()
end
function Icon:get_gicon_path(gicon)
    if not gicon then return end

    local icon_info = self.gtk_theme:lookup_by_gicon(gicon, self.icon_size, 0)
    return icon_info and icon_info:get_filename()
end
function Icon:get_icon_path(icon_name)
    local icon_info = self.gtk_theme:lookup_icon(icon_name, self.icon_size, 0)
    return icon_info and icon_info:get_filename()
end

function Icon:get_client_icon(client)
    local apps = Gio.AppInfo.get_all()

    return
        get_icon_by_pid(client, apps) or
        get_icon_by_icon_name(client, apps) or
        get_icon_by_class(client, apps) or
        client.icon or
        self:choose_icon({"window", "window-manager", "xfwm4-default", "window-list"})
end

_icon.name = require("beautiful").icon_theme
_icon.icon_size = 128

if _icon.name then
    _icon.gtk_theme = Gtk.IconTheme.new()
    Gtk.IconTheme.set_custom_theme(_icon.gtk_theme, _icon.name)
else
    _icon.gtk_theme = Gtk.IconTheme.get_default()
end

return setmetatable(_icon, { __index = Icon })
