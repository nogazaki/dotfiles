-- Standard awesome library
local gears = require("gears")

local GLib = require("lgi").GLib

--------------------------------------------------

local ANIMATION_FPS = 60

local tween = require(... .. ".tween")

local _animation = {}
_animation.manager = {}

local function copy_tables(destination, keys_table, values_table)
    if not keys_table then return values_table end
    values_table = values_table or keys_table

    for k, v in pairs(keys_table) do
        if type(v) == 'table' then
            destination[k] = copy_tables({}, v, values_table[k])
        else
            destination[k] = values_table[k] or v
        end
    end
    return destination
end

local Animate = {}
function Animate:set_update(func)
    if type(func) ~= "function" then return end
    self:connect_signal("updated", func)
end
function Animate:set_loop(value)
    if value then
        self:connect_signal("ended", self.restart)
    else
        self:disconnect_signal("ended", self.restart)
    end
end

function Animate:set_duration(duration)
    if type(duration) ~= "number" then return end
    self._private.duration = duration
    rawset(self, "duration", duration)
end
function Animate:set_initial(initial)
    if self._private.initial then return end
    self._private.initial = initial
end
function Animate:get_initial()
    return self._private.initial
end
function Animate:set_target(target)
    if not target then return end
    self._private.target = self._private.target or target

    self._private.tween = nil
    self:start(target)
end
function Animate:get_target()
    return self._private.tween and self._private.tween.target
end

function Animate:start(target)
    if type(target) == "table" then
        target = copy_tables({}, self._private.pos or self._private.initial, target)
    end

    if not self._private.tween then
        self._private.tween = tween {
            initial  = self._private.pos or self._private.initial,
            target   = target or self._private.target,
            duration = self.duration and self.duration * 1000000,
            easing   = self.easing,
        }
    end

    self._private.state = true
    self._private.last_updated = GLib.get_monotonic_time()

    if not gears.table.hasitem(_animation.manager, self) then
        table.insert(_animation.manager, self)
    end

    self:emit_signal("started", self._private.tween.initial)
    self:emit_signal("updated", self._private.tween.initial)
end
function Animate:stop()
    self._private.state = nil

    self:emit_signal("stopped", self._private.pos)
end
function Animate:restart()
   self:stop()

   self._private.pos = self._private.tween and self._private.tween.initial
   self.target = self._private.tween and self._private.tween.target or self._private.target
end

function Animate:get_pos()
    if type(self._private.pos) == "table" then
        return copy_tables({}, self._private.pos)
    end
    return self._private.pos
end
function Animate:get_state()
    return self._private.state
end

function _animation.new(_, args)
    args = args or {}

    local ret = gears.object {
        enable_properties = true,
        enable_auto_signals = true,
    }
    gears.table.crush(ret, Animate, true)

    ret._private = ret._private or {}
    ret._private.target = args.target; args.target = nil
    gears.table.crush(ret, args)

    return ret
end

function _animation:init()
    if self.event_source then return end

    self.event_source = GLib.timeout_add (
        GLib.PRIORITY_DEFAULT,
        math.floor(1000 / ANIMATION_FPS),
        function ()
            for index, animation in ipairs(self.manager) do
                if animation._private.state then
                    -- Animation in progress
                    local time = GLib.get_monotonic_time()
                    local delta = time - animation._private.last_updated
                    animation._private.last_updated = time

                    local pos = animation._private.tween:progress(delta)
                    if pos then
                        -- Tweening
                        animation._private.pos = pos
                        animation:emit_signal("updated", pos)
                    else
                        -- Ended

                        -- Snap to the end position
                        animation._private.pos = animation._private.tween.target
                        animation:emit_signal("updated", animation._private.tween.target)

                        animation._private.state = nil
                        table.remove(self.manager, index)
                        animation:emit_signal("ended", animation._private.tween.target)
                    end
                else
                    table.remove(self.manager, index)
                end
            end

            return true
        end
    )

    return true
end

return setmetatable(_animation, { __call = _animation.new })
