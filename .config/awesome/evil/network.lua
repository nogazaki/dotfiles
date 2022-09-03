-- Standard awesome library
local gears = require("gears")

local lgi = require("lgi")
local NM = lgi.NM
local dbus_proxy = require("dbus_proxy")
-- Note: Proxy's 'connect_signal' method takes arguments different from gears.object
-- callback first instead of signal's name

--------------------------------------------------

local network = gears.object {
    enable_properties   = true,
    enable_auto_signals = true,
}

network.State = {
    UNKNOWN = 0, -- Networking state is unknown. This indicates a daemon error that
    -- makes it unable to reasonably assess the state. In such event the applications
    -- are expected to assume Internet connectivity might be present and not disable
    -- controls that require network access. The graphical shells may hide the network
    -- accessibility indicator altogether since no meaningful status indication can be provided.
    ASLEEP = 10, -- Networking is not enabled, the system is being suspended or resumed from suspend.
    DISCONNECTED = 20, -- There is no active network connection. The graphical
    -- shell should indicate no network connectivity and the applications
    -- should not attempt to access the network.
    DISCONNECTING = 30, -- Network connections are being cleaned up.
    -- The applications should tear down their network sessions.
    CONNECTING = 40, -- A network connection is being started The graphical
    -- shell should indicate the network is being connected while the
    -- applications should still make no attempts to connect the network.
    CONNECTED_LOCAL = 50, -- There is only local IPv4 and/or IPv6 connectivity,
    -- but no default route to access the Internet. The graphical
    -- shell should indicate no network connectivity.
    CONNECTED_SITE = 60, -- There is only site-wide IPv4 and/or IPv6 connectivity.
    -- This means a default route is available, but the Internet connectivity check
    -- (see "Connectivity" property) did not succeed. The graphical shell
    -- should indicate limited network connectivity.
    CONNECTED_GLOBAL = 70, -- There is global IPv4 and/or IPv6 Internet connectivity
    -- This means the Internet connectivity check succeeded, the graphical shell should
    -- indicate full network connectivity.
}
network.DeviceType = {
    ETHERNET = 1,
    WIFI = 2
}
network.DeviceState = {
    UNKNOWN = 0, -- the device's state is unknown
    UNMANAGED = 10, -- the device is recognized, but not managed by NetworkManager
    UNAVAILABLE = 20, --the device is managed by NetworkManager,
    --but is not available for use. Reasons may include the wireless switched off,
    --missing firmware, no ethernet carrier, missing supplicant or modem manager, etc.
    DISCONNECTED = 30, -- the device can be activated,
    --but is currently idle and not connected to a network.
    PREPARE = 40, -- the device is preparing the connection to the network.
    -- This may include operations like changing the MAC address,
    -- setting physical link properties, and anything else required
    -- to connect to the requested network.
    CONFIG = 50, -- the device is connecting to the requested network.
    -- This may include operations like associating with the Wi-Fi AP,
    -- dialing the modem, connecting to the remote Bluetooth device, etc.
    NEED_AUTH = 60, -- the device requires more information to continue
    -- connecting to the requested network. This includes secrets like WiFi passphrases,
    -- login passwords, PIN codes, etc.
    IP_CONFIG = 70, -- the device is requesting IPv4 and/or IPv6 addresses
    -- and routing information from the network.
    IP_CHECK = 80, -- the device is checking whether further action
    -- is required for the requested network connection.
    -- This may include checking whether only local network access is available,
    -- whether a captive portal is blocking access to the Internet, etc.
    SECONDARIES = 90, -- the device is waiting for a secondary connection
    -- (like a VPN) which must activated before the device can be activated
    ACTIVATED = 100, -- the device has a network connection, either local or global.
    DEACTIVATING = 110, -- a disconnection from the current network connection
    -- was requested, and the device is cleaning up resources used for that connection.
    -- The network connection may still be valid.
    FAILED = 120 -- the device failed to connect to
    -- the requested network and is cleaning up the connection request
}
local function flags_to_security(flags, wpa_flags, rsn_flags)
    local security = ""

    if flags ~=0 and wpa_flags == 0 and rsn_flags == 0 then
        security = security .. "WEP/"
    end
    if wpa_flags ~= 0 then
        security = security .. "WPA/"
    end
    if rsn_flags ~= 0 then
        security = security .. "WPA2/"
    end
    if wpa_flags == 512 or rsn_flags == 512 then
        security = security .. "802.1X/"
    end

    return security:match("^(.-)/?$")
end

local function scan_active_access_point(proxy)
    if proxy.object_path ~= network._private.wireless_proxy.ActiveAccessPoint then return end
    local access_point_proxy = dbus_proxy.Proxy:new {
        bus       = dbus_proxy.Bus.SYSTEM,
        name      = "org.freedesktop.NetworkManager",
        interface = "org.freedesktop.NetworkManager.AccessPoint",
        path      = proxy.object_path,
    }
    network:emit_signal (
        "wireless::active_access_point",
        NM.utils_ssid_to_utf8(access_point_proxy.Ssid),
        access_point_proxy.Strength
    )
end

-- local function get_access_point_connections(ssid)
--     local connection_proxies = {}
--     local connections = network._private.settings_proxy:ListConnections()
--     for _, connection_path in ipairs(connections) do
--         local connection_proxy = dbus_proxy.Proxy:new {
--             bus       = dbus_proxy.Bus.SYSTEM,
--             name      = "org.freedesktop.NetworkManager",
--             interface = "org.freedesktop.NetworkManager.Settings.Connection",
--             path      = connection_path,
--         }

--         if connection_proxy.Filename:find(ssid) then
--             table.insert(connection_proxies, connection_proxy)
--         end
--     end

--     return connection_proxies
-- end

function network:scan_access_points()
    if not self._private.wireless_proxy then return end
    if self._private.access_points and self._private.access_points.scanning then return end

    self._private.access_points = { scanning = true }
    self._private.access_points_properties = self._private.access_points_properties or {}

    self._private.wireless_proxy:RequestScanAsync(function (_, _, _, failure)
        if failure then
            -- print("Rescan wifi failed: ", failure)
            -- print("Rescan wifi failed error code: ", failure.code)
            self:emit_signal("wireless::scan_ap::failed", tostring(failure), tostring(failure.code))
            self._private.access_points.scanning = nil
            return
        end

        local access_points = self._private.wireless_proxy:GetAllAccessPoints()
        for _, access_point_path in ipairs(access_points) do
            local access_point_proxy = dbus_proxy.Proxy:new {
                bus       = dbus_proxy.Bus.SYSTEM,
                name      = "org.freedesktop.NetworkManager",
                interface = "org.freedesktop.NetworkManager.AccessPoint",
                path      = access_point_path,
            }

            if access_point_proxy.Ssid then
                local ssid = NM.utils_ssid_to_utf8(access_point_proxy.Ssid)
                local security = flags_to_security (
                    access_point_proxy.Flags, access_point_proxy.WpaFlags, access_point_proxy.RsnFlags
                )

                table.insert(self._private.access_points, access_point_path)
                self._private.access_points[access_point_path] = {
                    ssid              = ssid,
                    security          = security,
                    -- password          = password,
                    raw_ssid          = access_point_proxy.Ssid,
                    strength          = access_point_proxy.Strength,
                    hwaddress         = access_point_proxy.HwAddress,
                    object_path       = access_point_path,
                }

                if not self._private.access_points_properties[access_point_path] then
                    local ap_properties_proxy = dbus_proxy.Proxy:new {
                        bus       = dbus_proxy.Bus.SYSTEM,
                        name      = "org.freedesktop.NetworkManager",
                        interface = "org.freedesktop.DBus.Properties",
                        path      = access_point_path,
                    }
                    ap_properties_proxy:connect_signal(scan_active_access_point, "PropertiesChanged")
                    scan_active_access_point(access_point_proxy)
                    self._private.access_points_properties[access_point_path] = ap_properties_proxy
                end
            end
        end

        table.sort(self._private.access_points, function (a, b)
            return self._private.access_points[a].strength > self._private.access_points[b].strength
        end)
        self:emit_signal("wireless::scan_ap::success", self._private.access_points)

        self._private.access_points.scanning = nil
    end, { call_id = "my-id" }, {})
end
function network:toggle_wireless()
    local enable = not self._private.client_proxy.WirelessEnabled
    if enable then
        self._private.client_proxy:Enable(true)
    end

    self._private.client_proxy:Set("org.freedesktop.NetworkManager", "WirelessEnabled", lgi.GLib.Variant("b", enable))
    self._private.client_proxy.WirelessEnabled = { signature = "b", value = enable }
end
-- function network:connect_to_wireless_ap(access_point)
    -- local connections = get_access_point_connections(access_point)
    -- self._private.client_proxy.ActivateConnectionAsync()
-- end
function network:disconnect_from_wireless_ap()
    if not self._private.wireless_device_proxy then return end
    self._private.client_proxy:DeactivateConnectionAsync(self._private.wireless_device_proxy.ActiveConnection)
end

function network:get_primary_type()
    return self._private.client_proxy.PrimaryConnectionType
end
function network:get_active_access_point()
    return self._private.wireless_proxy.ActiveAccessPoint
end

function network:init()
    if self._private and self._private.client_proxy then return end

    self._private = self._private or {}

    -- Connection manager
    self._private.client_proxy = dbus_proxy.Proxy:new {
        bus       = dbus_proxy.Bus.SYSTEM,
        name      = "org.freedesktop.NetworkManager",
        interface = "org.freedesktop.NetworkManager",
        path      = "/org/freedesktop/NetworkManager",
    }
    -- Settings
    self._private.settings_proxy = dbus_proxy.Proxy:new {
        bus       = dbus_proxy.Bus.SYSTEM,
        name      = "org.freedesktop.NetworkManager",
        interface = "org.freedesktop.NetworkManager.Settings",
        path      = "/org/freedesktop/NetworkManager/Settings",
    }
    -- Properties
    local client_properties_proxy = dbus_proxy.Proxy:new {
        bus       = dbus_proxy.Bus.SYSTEM,
        name      = "org.freedesktop.NetworkManager",
        interface = "org.freedesktop.DBus.Properties",
        path      = "/org/freedesktop/NetworkManager",
    }

    self._private.client_proxy:connect_signal(function (_, state)
        self:emit_signal("network::state", state)
    end, "StateChanged")

    self:emit_signal("network::state", self._private.client_proxy.State)
    client_properties_proxy:connect_signal(function (_, _, data)
        if data.PrimaryConnectionType then
            self:emit_signal("network::type", data.PrimaryConnectionType)
        end
    end, "PropertiesChanged")
    self:emit_signal("network::type", self._private.client_proxy.PrimaryConnectionType)

    local devices = self._private.client_proxy:GetDevices()
    for _, device_path in ipairs(devices) do
        local device_proxy = dbus_proxy.Proxy:new {
            bus       = dbus_proxy.Bus.SYSTEM,
            name      = "org.freedesktop.NetworkManager",
            interface = "org.freedesktop.NetworkManager.Device",
            path      = device_path,
        }

        if device_proxy.DeviceType == self.DeviceType.WIFI then
            self._private.wireless_device_proxy = device_proxy
            self._private.wireless_proxy = dbus_proxy.Proxy:new {
                bus       = dbus_proxy.Bus.SYSTEM,
                name      = "org.freedesktop.NetworkManager",
                interface = "org.freedesktop.NetworkManager.Device.Wireless",
                path      = device_path,
            }

            self._private.wireless_device_proxy:connect_signal(function (_, new_state, old_state)
                self:emit_signal("wireless::state", new_state, old_state)
            end, "StateChanged")

            self:emit_signal("wireless::state", device_proxy.State)

            self._private.wireless_proxy:connect_signal(function ()
                self:scan_access_points()
            end, "AccessPointAdded")
            self._private.wireless_proxy:connect_signal(function (_, access_point_path)
                self._private.access_points_properties[access_point_path] = nil

                local index = gears.table.hasitem(self._private.access_points, access_point_path)
                self._private.access_points[index] = nil
                self._private.access_points[access_point_path] = nil
            end, "AccessPointRemoved")

            self:scan_access_points()
            break
        end
    end
end

return network
