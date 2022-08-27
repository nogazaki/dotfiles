-- Standard awesome library
local gears = require("gears")

local GLib = require("lgi").GLib

--------------------------------------------------

local ANIMATION_FPS = 60

local tween = require(... .. ".tween")

local _animation = {}
_animation.manager = {}

local function copy_target(destination, keys_table, values_table)
    if not keys_table then return values_table end

    for k, v in pairs(keys_table) do
        if type(v) == 'table' then
            destination[k] = copy_target({}, v, values_table[k])
        else
            destination[k] = values_table[k] or v
        end
    end
    return destination
end
local Animate = {}
function Animate:set(target)
    if not target then return end
    self.target = self.target or target

    self.tween = nil
    self:start(target)
end
function Animate:start(target)
    if type(target) == "table" then
        target = copy_target({}, self.pos or self.initial, target)
    end

    if not self.tween then
        self.tween = tween {
            initial  = self.pos or self.initial,
            target   = target or self.target,
            duration = self.duration and self.duration * 1000000,
            easing   = self.easing,
        }
    end

    self.state = true
    self.last_updated = GLib.get_monotonic_time()

    if not gears.table.hasitem(_animation.manager, self) then
        table.insert(_animation.manager, self)
    end

    self:emit_signal("started", self.tween.initial)
    self:emit_signal("updated", self.tween.initial)
end
function Animate:stop()
    self.state = nil

    self:emit_signal("stopped", self.pos)
end
function Animate:restart()
    self:stop()

    self.pos = self.initial
    self:set(self.target)
end

function _animation.new(_, args)
    args = args or {}

    local ret = gears.object()
    gears.table.crush(ret, args, true)
    gears.table.crush(ret, Animate, true)

    if type(args.update) == "function" then ret:connect_signal("updated", args.update) end

    if args.loop then
        ret:connect_signal("ended", ret.restart)
    end

    return ret
end

function _animation:init()
    if self.event_source then return end

    self.event_source = GLib.timeout_add (
        GLib.PRIORITY_DEFAULT,
        math.floor(1000 / ANIMATION_FPS),
        function ()
            for index, animation in ipairs(self.manager) do
                animation.state = (animation.duration and animation.duration > 0) and animation.state or nil

                if animation.state then
                    -- Animation in progress
                    local time = GLib.get_monotonic_time()
                    local delta = time - animation.last_updated
                    animation.last_updated = time

                    local pos = animation.tween:progress(delta)
                    if pos then
                        -- Tweening
                        animation.pos = pos
                        animation:emit_signal("updated", pos)
                    else
                        -- Ended

                        -- Snap to the end position
                        animation.pos = animation.tween.target
                        animation:emit_signal("updated", animation.tween.target)

                        animation.state = nil
                        table.remove(self.manager, index)
                        animation:emit_signal("ended", animation.tween.target)
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
