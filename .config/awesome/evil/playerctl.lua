-- Standard awesome library
local awful = require("awful")
local gears = require("gears")

local lgi = require("lgi")

local helpers = require("helpers")

--------------------------------------------------

local clock = require("evil.clock")

local PRIORITY = { "spotify", "%any" }
local IGNORE = {}

local Playerctl = {}

function Playerctl:play(player)
    player = player or self.active_player
    if not player then return end
    player:play()
end
function Playerctl:pause(player)
    player = player or self.active_player
    if not player then return end
    player:pause()
end
function Playerctl:play_pause(player)
    player = player or self.active_player
    if not player then return end
    player:play_pause()
end
function Playerctl:stop(player)
    player = player or self.active_player
    if not player then return end
    player:stop()
end
function Playerctl:next(player)
    player = player or self.active_player
    if not player then return end
    player:next()
end
function Playerctl:previous(player)
    player = player or self.active_player
    if not player then return end
    player:previous()
end

function Playerctl:get_player_index(player)
    if not player then return end
    for index, player_ in ipairs(self._private.manager.players) do
        if player_ == player then
            return index, index == #self._private.manager.players or nil
        end
    end
end

function Playerctl:set_active_player(player)
    if self._private.inactive_timer then
        self._private.inactive_timer:stop()
        self._private.inactive_timer = nil
    end
    self._private.active_player = player
end
function Playerctl:get_active_player()
    return self._private.active_player or self._private.manager.players[1]
end

local function toggle_position_update(self, player, playing)
    if playing then
        clock:connect_signal("property::sec", self._private.position_updater[player])
    else
        clock:disconnect_signal("property::sec", self._private.position_updater[player])
    end
end

local function update_playback_status(self, player, status)
    -- Reported as PLAYING, PAUSED, or STOPPED
    if status == "PLAYING" then
        toggle_position_update(self, player, true)
        self.active_player = player
        self:emit_signal("playback_status", player, true)
    else
        toggle_position_update(self, player, false)
        self:emit_signal("playback_status", player, false)

        for _, Player in ipairs(self._private.manager.players) do
            if Player.playback_status == "PLAYING" then
                self:emit_all_info(Player)
                return
            end
        end
        if self._private.inactive_timer or not self._private.active_player then return end
        self._private.inactive_timer = gears.timer.start_new(300, function ()
            self._private.inactive_timer = nil
            self.active_player = nil
        end)
    end
end

local function update_metadata(self, player, metadata)
    local data = metadata.value
    local title = data["xesam:title"] or ""
    local artist = ""
    for index, name in ipairs(data["xesam:artist"] or {}) do
        artist = artist .. name .. (index == #data["xesam:artist"] and "" or ",")
    end
    local album = data["xesam:album"] or ""
    local art_url = data["mpris:artUrl"] or ""

    if title == "" and artist == "" and album == "" then return end

    title = gears.string.xml_escape(title)
    title = helpers.string.blank_to_nil(title)

    artist = gears.string.xml_escape(artist)
    artist = helpers.string.blank_to_nil(artist)

    album = gears.string.xml_escape(album)
    album = helpers.string.blank_to_nil(album)

    self:emit_signal("metadata", player, title, artist, album)

    -- No album art
    if art_url == "" then
        self:emit_signal("metadata::art")
    end

    local art_path = art_url:reverse():match(".-/")

    art_path = art_path and ("/tmp" .. art_path:reverse()) or nil
    -- Album art downloaded
    if art_path and gears.filesystem.file_readable(art_path) then
        self:emit_signal("metadata::art", player, art_path)
        return
    end

    -- Album art not downloaded or have no name to cache
    art_path = art_path or os.tmpname()
    awful.spawn.easy_async (
        string.format("curl -L -s %s -o %s", art_url, art_path),
        function (_, error)
            if error ~= "" then art_path = nil end
            self:emit_signal("metadata::art", player, art_path)
        end
    )
end

function Playerctl:emit_all_info(player)
    update_playback_status(self, player, player.playback_status)
    update_metadata(self, player, player.metadata)
    self._private.position_updater[player]()
end
function Playerctl:init_player(name)
    if gears.table.hasitem(IGNORE or {}, name.name) then return end

    local new_player = lgi.Playerctl.Player.new_from_name(name)
    self._private.manager:manage_player(new_player)

    -- Connect signals
    new_player.on_playback_status = function (player, status)
        update_playback_status(self, player, status)
    end
    new_player.on_metadata = function (player, metadata)
        update_metadata(self, player, metadata)
    end

    return new_player
end

local function player_compare(player_a, player_b)
    local a = lgi.Playerctl.Player(player_a).player_name
    local b = lgi.Playerctl.Player(player_b).player_name

    local any_order, a_order, b_order = math.huge, nil, nil

    if a == b then
        return 0
    end

    for order, name in ipairs(PRIORITY) do
        if name == "%any" then
            any_order = (any_order == math.huge) and order or any_order
        elseif name == a then
            a_order = a_order or order
        elseif name == b then
            b_order = b_order or order
        end
    end

    if not a_order and not b_order then
        return 0
    elseif not a_order then
        return (b_order < any_order) and 1 or -1
    elseif not b_order then
        return (a_order < any_order) and -1 or 1
    elseif a_order == b_order then
        return 0
    else
        return (a_order < b_order) and -1 or 1
    end
end

function Playerctl:init()
    if self._private.manager then return end

    self._private.manager = lgi.Playerctl.PlayerManager.new()
    if PRIORITY and #PRIORITY > 0 then
        self._private.manager:set_sort_func(player_compare)
    end

    -- Callback on new players
    self._private.manager.on_name_appeared = function (_, name)
        local new_player = self:init_player(name)
        self:emit_signal("new_player", new_player)
        self:emit_all_info(new_player)
    end

    self._private.manager.on_player_vanished = function (manager, player)
        self:emit_signal("player_vanished", player)
        if #manager.players == 0 then
            -- No more player being managed
            self:emit_signal("no_players")
        end
    end

    -- Manage existing players on startup
    for _, name in ipairs(self._private.manager.player_names) do
        self:init_player(name)
    end

    self:emit_signal("initialized")

    for _, player in ipairs(self._private.manager.players) do
        self:emit_all_info(player)
    end
end

local playerctl = gears.object {
    enable_properties   = true,
    enable_auto_signals = true,
}
gears.table.crush(playerctl, Playerctl, true)

playerctl._private = playerctl._private or {}
-- The manager
playerctl._private.manager = nil

playerctl._private.position_updater = setmetatable({}, {
    __mode = "kv",
    __index = function (self, player)
        local ret = function ()
            playerctl:emit_signal (
                "position",
                player, player:get_position(), player:print_metadata_prop("mpris:length")
            )
        end
        rawset(self, player, ret)
        return ret
    end,
})

return playerctl
