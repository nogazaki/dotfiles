-- Standard awesome library
local awful = require("awful")
local gears = require("gears")

local helpers = require("helpers")

local lgi = require("lgi")

--------------------------------------------------

local clock = require("evil.clock")

local PRIORITY = { "spotify", "mpd", "%any" }
local IGNORE = {}

local playerctl = gears.object {
    enable_properties   = true,
    enable_auto_signals = true,
}

playerctl._private = playerctl._private or {}
-- The manager
playerctl._private.manager = nil
-- Art url and colors
playerctl._private.extra_metadata = setmetatable({}, {
    __index = function (self, name)
        return rawset(self, name, {})[name]
    end
})

function playerctl:play(player)
    player = player or self.active_player
    if not player then return end
    player:play()
end
function playerctl:pause(player)
    player = player or self.active_player
    if not player then return end
    player:pause()
end
function playerctl:play_pause(player)
    player = player or self.active_player
    if not player then return end
    player:play_pause()
end
function playerctl:stop(player)
    player = player or self.active_player
    if not player then return end
    player:stop()
end
function playerctl:next(player)
    player = player or self.active_player
    if not player then return end
    player:next()
end
function playerctl:previous(player)
    player = player or self.active_player
    if not player then return end
    player:previous()
end

function playerctl:get_player_index(player)
    if not player then return end
    for index, player_ in ipairs(self._private.manager.players) do
        if player_ == player then
            return index, index == #self._private.manager.players or nil
        end
    end
end

function playerctl:set_active_player(player)
    if self._private.inactive_timer then
        self._private.inactive_timer:stop()
        self._private.inactive_timer = nil
    end
    self._private.active_player = player
end
function playerctl:get_active_player()
    return self._private.active_player or self._private.manager.players[1]
end
function playerctl.set_players()
    return
end
function playerctl:get_players()
    return self._private.manager.players
end
function playerctl:get_extra_metadata()
    return self._private.extra_metadata
end

local function update_position() playerctl:emit_signal("position") end

local function update_playback_status(player, status)
    local overall_status = nil
    for _, Player in ipairs(playerctl._private.manager.players) do
        overall_status = overall_status or (Player.playback_status == "PLAYING")
    end
    if overall_status then
        clock:connect_signal("updated", update_position)
    else
        clock:disconnect_signal("updated", update_position)
    end

    -- Reported as PLAYING, PAUSED, or STOPPED
    if status == "PLAYING" then
        playerctl:emit_signal("playback_status", player, true)
        playerctl.active_player = player
        return
    end

    playerctl:emit_signal("playback_status", player, false)

    if playerctl._private.inactive_timer or not playerctl._private.active_player then return end
    playerctl._private.inactive_timer = gears.timer.start_new(300, function ()
        playerctl._private.inactive_timer = nil
        playerctl.active_player = nil
    end)
end

local function get_art_color_and_emit(path, player, metadata)
    if not path then
        playerctl:emit_signal("metadata", player, metadata, playerctl._private.extra_metadata[player])
        return
    end

    awful.spawn.easy_async (
        "colorz -n 1 --no-preview " .. path,
        function (out, err)
            local color
            local name = player.player_name
            if err == "" then
                color = out:match("%S+%s+(%S+)")
            end
            playerctl._private.extra_metadata[name].color = color
            playerctl:emit_signal("metadata", player, metadata, playerctl._private.extra_metadata[name])
        end
    )
end
local function update_metadata(player, metadata)
    local name = player.player_name
    local art_url = helpers.string.blank_to_nil(player:print_metadata_prop("mpris:artUrl"))

    if art_url and art_url:match("^file://") then
        art_url = art_url:match("file://(.+)")
        playerctl._private.extra_metadata[name].art_path = art_url
        get_art_color_and_emit(art_url, player, metadata)
        return
    end

    if art_url and art_url:match("^http") then
        local art_path = art_url:reverse():match(".-/")
        art_path = os.getenv("HOME") .. "/.cache/awesome/album_art/" .. name .. art_path:reverse()
        -- File downloaded
        if gears.filesystem.file_readable(art_path) then
            playerctl._private.extra_metadata[name].art_path = art_path
            get_art_color_and_emit(art_path, player, metadata)
            return
        end
        -- File not downloaded
        gears.filesystem.make_parent_directories(art_path)
        awful.spawn.easy_async (
            string.format("curl -L -s %s -o %s", art_url, art_path),
            function (_, error)
                if error ~= "" then art_path = nil end
                playerctl._private.extra_metadata[name].art_path = art_path
                get_art_color_and_emit(art_path, player, metadata)
            end
        )
        return
    end

    get_art_color_and_emit(art_url, player, metadata)
end

function playerctl:init_player(name)
    if gears.table.hasitem(IGNORE or {}, name.name) then return end

    local new_player = lgi.Playerctl.Player.new_from_name(name)
    self._private.manager:manage_player(new_player)

    -- Connect signals
    new_player.on_metadata = update_metadata
    new_player.on_playback_status = update_playback_status

    update_metadata(new_player, new_player.metadata)
    update_playback_status(new_player, new_player.playback_status)
    self:emit_signal("playerctl::player::added")
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

function playerctl:init()
    if self._private.manager then return end

    self._private.manager = lgi.Playerctl.PlayerManager.new()
    if PRIORITY and #PRIORITY > 0 then
        self._private.manager:set_sort_func(player_compare)
    end

    -- Callback on new players
    self._private.manager.on_name_appeared = function (_, name)
        self:init_player(name)
    end

    self._private.manager.on_player_vanished = function (manager, player)
        if player == self.active_player then
            for _, Player in ipairs(self._private.manager.players) do
                if Player ~= player then self.active_player = Player break end
            end
        end

        self._private.extra_metadata[player.player_name] = nil

        self:emit_signal("playerctl::player::removed", player)
        if #manager.players == 0 then
            -- No more player being managed
            self:emit_signal("playerctl::player::no_player")
        end
    end

    -- Manage existing players on startup
    for _, name in ipairs(self._private.manager.player_names) do
        self:init_player(name)
    end

    self:emit_signal("playerctl::initialized")
end

return playerctl
