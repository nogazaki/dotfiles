-- Standard awesome library
local gears = require("gears")

local lgi = require("lgi")

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
function Playerctl.set_players()
    return
end
function Playerctl:get_players()
    return self._private.manager.players
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
        self:emit_signal("playback_status", player, true)
        self.active_player = player
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
    self:emit_signal("metadata", player, metadata)
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

    self:emit_all_info(new_player)
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
        self:init_player(name)
    end

    self._private.manager.on_player_vanished = function (manager)
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
        return rawset(self, player, function ()
            playerctl:emit_signal("position", player)
        end)[player]
    end,
})

return playerctl
