-- Standard awesome library
local awful = require("awful")
local gears = require("gears")

local helpers = require("helpers")

local JSON = require("JSON")

--------------------------------------------------

local pactl = gears.object {
    enable_properties   = true,
    enable_auto_signals = true,
}

function pactl.sink_set_default(_, id)
    awful.spawn(string.format("pactl set-default-sink %d", id), false)
end
function pactl.sink_toggle_mute(_, id)
    id = (id and id ~= 0) and tostring(id) or "@DEFAULT_SINK@"
    awful.spawn(string.format("pactl set-sink-mute %s toggle", id), false)
end
function pactl.sink_set_volume(_, volume, id)
    id = (id and id ~= 0) and tostring(id) or "@DEFAULT_SINK@"
    awful.spawn(string.format("pactl set-sink-volume %s %d%%", id, volume), false)
end
function pactl.sink_volume_up(_, step, id)
    id = (id and id ~= 0) and tostring(id) or "@DEFAULT_SINK@"
    awful.spawn(string.format("pactl set-sink-volume %s +%d%%", id, step), false)
end
function pactl.sink_volume_down(_, step, id)
    id = (id and id ~= 0) and tostring(id) or "@DEFAULT_SINK@"
    awful.spawn(string.format("pactl set-sink-volume %s -%d%%", id, step), false)
end

function pactl.source_set_default(_, id)
    awful.spawn(string.format("pactl set-default-source %d", id), false)
end
function pactl.source_toggle_mute(_, id)
    id = (id and id ~= 0) and tostring(id) or "@DEFAULT_SOURCE@"
    awful.spawn(string.format("pactl set-source-mute %s toggle", id), false)
end
function pactl.source_set_volume(_, volume, id)
    id = (id and id ~= 0) and tostring(id) or "@DEFAULT_SOURCE@"
    awful.spawn(string.format("pactl set-source-volume %s %d%%", id, volume), false)
end
function pactl.source_volume_up(_, step, id)
    id = (id and id ~= 0) and tostring(id) or "@DEFAULT_SOURCE@"
    awful.spawn(string.format("pactl set-source-volume %s +%d%%", id, step), false)
end
function pactl.source_volume_down(_, step, id)
    id = (id and id ~= 0) and tostring(id) or "@DEFAULT_SOURCE@"
    awful.spawn(string.format("pactl set-source-volume %s -%d%%", id, step), false)
end

function pactl.sink_input_toggle_mute(_, id)
    awful.spawn(string.format("pactl set-sink-input-mute %d toggle", id), false)
end
function pactl.sink_input_set_volume(_, volume, id)
    awful.spawn(string.format("pactl set-sink-input-volume %d %d%%", id, volume), false)
end

function pactl.source_output_toggle_mute(_, id)
    awful.spawn(string.format("pactl set-source-output-mute %d toggle", id), false)
end
function pactl.source_output_set_volume(_, volume, id)
    awful.spawn(string.format("pactl set-source-output-volume %d %d%%", id, volume), false)
end

function pactl:get_sink()
    return self._private.sink
end
function pactl:get_source()
    return self._private.source
end

local function change_default_device(object)
    awful.spawn.easy_async("pactl get-default-" .. object, function (stdout)
        stdout = helpers.string.trim(stdout)
        for _, device in pairs(pactl._private[object]) do
            if device.name == stdout:match("[^\r\n]+") then
                if not device.default then
                    device.default = true
                    pactl:emit_signal(object .. "::default", device)
                end
            else
                device.default = nil
            end
            pactl:emit_signal(object .. "::updated", device)
        end
    end)
end
local function get_devices(object)
    awful.spawn.easy_async("pactl -f json list " .. object .. "s", function (stdout)
        local devices = JSON:decode(stdout)
        for _, device in ipairs(devices) do
            if not pactl._private[object][device.index] then
                pactl:emit_signal(object .. "::added", device)
            end
            pactl._private[object][device.index] = device
        end

        change_default_device(object)
    end)
end
local function remove_entry(object, id)
    if not pactl._private[object] then return end
    pactl:emit_signal(object .. "::removed", pactl._private[object][id])
    pactl._private[object][id] = nil
end

local on_event = {}

on_event.server = {}
on_event.server.change = function ()
    change_default_device("sink")
    change_default_device("source")
end

on_event.sink = {}
on_event.sink.new = get_devices
on_event.sink.change = get_devices
on_event.sink.remove = remove_entry

on_event.source = {}
on_event.source.new = get_devices
on_event.source.change = get_devices
on_event.source.remove = remove_entry

function pactl:init()
    if self.subscribe_id then return end

    self._private = self._private or {}
    self._private.sink = {}
    self._private.source = {}

    get_devices("sink"); get_devices("source")

    awful.spawn.easy_async("pkill -f 'pactl subscribe'", function ()
        self.subscribe_id = awful.spawn.with_line_callback("pactl subscribe", {
            stdout = function (line)
                local event, object, id = line:match("^Event '(.-)' on (.-) #(.-)$")
                object = object:gsub("-", "_"); id = tonumber(id)

                if on_event[object] and on_event[object][event] then
                    on_event[object][event](object, id)
                end
            end,
            exit = function ()
                self.subscribe_id = nil
                self:init()
            end
        })
    end)

    self.initializing = nil
end

return pactl
