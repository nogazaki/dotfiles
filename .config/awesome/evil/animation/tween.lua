-- URL         = 'https://github.com/kikito/tween.lua'
-- LICENSE     = [[
--     MIT LICENSE
--     Copyright (c) 2014 Enrique García Cota, Yuichi Tateno, Emmanuel Oga
--     Permission is hereby granted, free of charge, to any person obtaining a
--     copy of this software and associated documentation files (the
--     "Software"), to deal in the Software without restriction, including
--     without limitation the rights to use, copy, modify, merge, publish,
--     distribute, sublicense, and/or sell copies of the Software, and to
--     permit persons to whom the Software is furnished to do so, subject to
--     the following conditions:
--     The above copyright notice and this permission notice shall be included
--     in all copies or substantial portions of the Software.
--     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
--     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
--     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
--     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
--     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
--     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
--     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
-- ]]

--------------------------------------------------

local _tween = {}

local sin, cos, pi, sqrt, abs, asin = math.sin, math.cos, math.pi, math.sqrt, math.abs, math.asin

-- For all easing functions:
-- t = elapsed time
-- b = beginning
-- c = change == ending - beginning
-- d = total time

-- Linear
local function linear(t, b, c, d)
    return c * t / d + b
end
-- Quad
local function in_quad(t, b, c, d)
    t = t / d
    return c * t ^ 2 + b
end
local function out_quad(t, b, c, d)
    t = t / d
    return - c * t * (t - 2) + b
end
local function in_out_quad(t, b, c, d)
    t = t / d * 2
    if t < 1 then
        return c / 2 * t ^ 2 + b
    else
        return - c / 2 * ((t - 1) * (t - 3) - 1) + b
    end
end
local function out_in_quad(t, b, c, d)
    if t < d / 2 then
        return out_quad (t * 2, b, c / 2, d)
    else
        return in_quad((t * 2) - d, b + c / 2, c / 2, d)
    end
end
-- Cubic
local function in_cubic (t, b, c, d)
    t = t / d
    return c * t ^ 3 + b
end
local function out_cubic(t, b, c, d)
    t = t / d - 1
    return c * (t ^ 3 + 1) + b
end
local function in_out_cubic(t, b, c, d)
    t = t / d * 2
    if t < 1 then
        return c / 2 * t ^ 3 + b
    else
    t = t - 2
        return c / 2 * (t ^ 3 + 2) + b
    end
end
local function out_in_cubic(t, b, c, d)
    if t < d / 2 then
        return out_cubic(t * 2, b, c / 2, d)
    else
        return in_cubic((t * 2) - d, b + c / 2, c / 2, d)
    end
end
-- Quart
local function in_quart(t, b, c, d)
    t = t / d
    return c * t ^ 4 + b
end
local function out_quart(t, b, c, d)
    t = t / d - 1
    return - c * (t ^ 4 - 1) + b
end
local function in_out_quart(t, b, c, d)
    t = t / d * 2
    if t < 1 then
        return c / 2 * t ^ 4 + b
    else
        t = t - 2
        return - c / 2 * (t ^ 4 - 2) + b
    end
end
local function out_in_quart(t, b, c, d)
    if t < d / 2 then
        return out_quart(t * 2, b, c / 2, d)
    else
        return in_quart((t * 2) - d, b + c / 2, c / 2, d)
    end
end
-- Quint
local function in_quint(t, b, c, d)
    t = t / d
    return c * t ^ 5 + b
end
local function out_quint(t, b, c, d)
    t = t / d - 1
    return c * (t ^ 5 + 1) + b
end
local function in_out_quint(t, b, c, d)
    t = t / d * 2
    if t < 1 then
        return c / 2 * t ^ 5 + b
    else
        t = t - 2
        return c / 2 * (t ^ 5 + 2) + b
    end
end
local function out_in_quint(t, b, c, d)
    if t < d / 2 then
        return out_quint(t * 2, b, c / 2, d)
    else
        return in_quint((t * 2) - d, b + c / 2, c / 2, d)
    end
end
-- Sine
local function in_sine(t, b, c, d)
    return - c * cos(t / d * (pi / 2)) + c + b
end
local function out_sine(t, b, c, d)
    return c * sin(t / d * (pi / 2)) + b
end
local function in_out_sine(t, b, c, d)
    return - c / 2 * (cos(pi * t / d) - 1) + b
end
local function out_in_sine(t, b, c, d)
    if t < d / 2 then
        return out_sine(t * 2, b, c / 2, d)
    else
        return in_sine((t * 2) - d, b + c / 2, c / 2, d)
    end
end
-- Exponetial
local function in_expo(t, b, c, d)
    if t == 0 then
        return b
    else
        return c * 2 ^ (10 * (t / d - 1)) + b - c * 0.001
    end
end
local function out_expo(t, b, c, d)
    if t == d then
        return b + c
    else
        return c * 1.001 * (- 2 ^ (- 10 * t / d) + 1) + b
    end
end
local function in_out_expo(t, b, c, d)
    if t == 0 then return b end
    if t == d then return b + c end
    t = t / d * 2
    if t < 1 then
        return c / 2 * 2 ^ (10 * (t - 1)) + b - c * 0.0005
    else
    t = t - 1
        return c / 2 * 1.0005 * (- 2 ^ (- 10 * t) + 2) + b
    end
end
local function out_in_expo(t, b, c, d)
    if t < d / 2 then
        return out_expo(t * 2, b, c / 2, d)
    else
        return in_expo((t * 2) - d, b + c / 2, c / 2, d)
    end
end
-- Circle
local function in_circ(t, b, c, d)
    t = t / d
    return(- c * (sqrt(1 - t ^ 2) - 1) + b)
end

local function out_circ(t, b, c, d)
    t = t / d - 1
    return(c * sqrt(1 - t ^ 2) + b)
end
local function in_out_circ(t, b, c, d)
    t = t / d * 2
    if t < 1 then
        return -c / 2 * (sqrt(1 - t * t) - 1) + b
    else
        t = t - 2
        return c / 2 * (sqrt(1 - t * t) + 1) + b
    end
end
local function out_in_circ(t, b, c, d)
    if t < d / 2 then
        return out_circ(t * 2, b, c / 2, d)
    else
        return in_circ((t * 2) - d, b + c / 2, c / 2, d)
    end
end
-- Back
local function in_back(t, b, c, d, s)
    s = s or 1.70158
    t = t / d
    return c * t * t * ((s + 1) * t - s) + b
end
local function out_back(t, b, c, d, s)
    s = s or 1.70158
    t = t / d - 1
    return c * (t * t * ((s + 1) * t + s) + 1) + b
end
local function in_out_back(t, b, c, d, s)
    s = s or 1.70158
    s = s * 1.525
    t = t / d * 2
    if t < 1 then
        return c / 2 * (t * t * ((s + 1) * t - s)) + b
    else
        t = t - 2
        return c / 2 * (t * t * ((s + 1) * t + s) + 2) + b
    end
end
local function out_in_back(t, b, c, d, s)
    if t < d / 2 then
        return out_back(t * 2, b, c / 2, d, s)
    else
        return in_back((t * 2) - d, b + c / 2, c / 2, d, s)
    end
end
-- Bounce
local function out_bounce(t, b, c, d)
    t = t / d
    if t < 1 / 2.75 then
        return c * (7.5625 * t * t) + b
    elseif t < 2 / 2.75 then
        t = t - (1.5 / 2.75)
        return c * (7.5625 * t * t + 0.75) + b
    elseif t < 2.5 / 2.75 then
        t = t - (2.25 / 2.75)
        return c * (7.5625 * t * t + 0.9375) + b
    else
        t = t - (2.625 / 2.75)
        return c * (7.5625 * t * t + 0.984375) + b
    end
end
local function in_bounce(t, b, c, d)
    return c - out_bounce(d - t, 0, c, d) + b
end
local function in_out_bounce(t, b, c, d)
    if t < d / 2 then
        return in_bounce(t * 2, 0, c, d) * 0.5 + b
    else
        return out_bounce(t * 2 - d, 0, c, d) * 0.5 + c * .5 + b
    end
end
local function out_in_bounce(t, b, c, d)
    if t < d / 2 then
        return out_bounce(t * 2, b, c / 2, d)
    else
        return in_bounce((t * 2) - d, b + c / 2, c / 2, d)
    end
end
-- Elastic
local function in_elast(t, b, c, d, a, p)
    if t == 0 then return b end

    t = t / d

    if t == 1  then return b + c end

    p = p or d * 0.3

    local s

    if not a or a < abs(c) then
        a = c
        s = p / 4
    else
        s = p / (2 * pi) * asin(c/a)
    end

    t = t - 1

    return - (a * 2 ^ (10 * t) * sin((t * d - s) * (2 * pi) / p)) + b
end
local function out_elast(t, b, c, d, a, p)
    if t == 0 then return b end

    t = t / d

    if t == 1 then return b + c end

    p = p or d * 0.3

    local s

    if not a or a < abs(c) then
        a = c
        s = p / 4
    else
        s = p / (2 * pi) * asin(c/a)
    end

    return a * 2 ^ (- 10 * t) * sin((t * d - s) * (2 * pi) / p) + c + b
end
local function in_out_elast(t, b, c, d, a, p)
    if t == 0 then return b end

    t = t / d * 2

    if t == 2 then return b + c end

    p = p or d * (0.3 * 1.5)

    local s

    if not a or a < abs(c) then
        a = c
        s = p / 4
    else
        s = p / (2 * pi) * asin(c / a)
    end

    if t < 1 then
        t = t - 1
        return - 0.5 * (a * 2 ^ (10 * t) * sin((t * d - s) * (2 * pi) / p)) + b
    else
        t = t - 1
        return a * 2 ^ (- 10 * t) * sin((t * d - s) * (2 * pi) / p) * 0.5 + c + b
    end
end
local function out_in_elast(t, b, c, d, a, p)
    if t < d / 2 then
        return out_elast(t * 2, b, c / 2, d, a, p)
    else
        return in_elast((t * 2) - d, b + c / 2, c / 2, d, a, p)
    end
end

_tween.easing = {
    linear = linear,

    in_quad   = in_quad,   out_quad   = out_quad,   in_out_quad   = in_out_quad,   out_in_quad   = out_in_quad,
    in_cubic  = in_cubic,  out_cubic  = out_cubic,  in_out_cubic  = in_out_cubic,  out_in_cubic  = out_in_cubic,
    in_quart  = in_quart,  out_quart  = out_quart,  in_out_quart  = in_out_quart,  out_in_quart  = out_in_quart,
    in_quint  = in_quint,  out_quint  = out_quint,  in_out_quint  = in_out_quint,  out_in_quint  = out_in_quint,
    in_sine   = in_sine,   out_sine   = out_sine,   in_out_sine   = in_out_sine,   out_in_sine   = out_in_sine,
    in_expo   = in_expo,   out_expo   = out_expo,   in_out_expo   = in_out_expo,   out_in_expo   = out_in_expo,
    in_circ   = in_circ,   out_circ   = out_circ,   in_out_circ   = in_out_circ,   out_in_circ   = out_in_circ,

    in_back   = in_back,   out_back   = out_back,   in_out_back   = in_out_back,   out_in_back   = out_in_back,
    in_bounce = in_bounce, out_bounce = out_bounce, in_out_bounce = in_out_bounce, out_in_bounce = out_in_bounce,
    in_elast  = in_elast,  out_elast  = out_elast,  in_out_elast  = in_out_elast,  out_in_elast  = out_in_elast,
}

-- Private interface
local function get_easing_function(easing)
    easing = easing or "linear"
    if type(easing) == "string" then
        local name = easing
        easing = _tween.easing[name] or linear
    end
    return easing
end
local function apply_easing(initial, target, elapsed, duration, easing_function)
    if type(target) ~= "table" then
        initial = initial or 0
        target = target or initial
        return easing_function(elapsed, initial or 0, target - initial, duration or 0)
    end

    initial = initial or {}
    local ret = {}
    for key, value in pairs(target) do
        ret[key] = apply_easing(initial[key], value, elapsed, duration, easing_function)
    end

    return ret
end

-- Tween methods
local Tween = {}
local function update(self, elapsed)
    if elapsed <= 0 then
        self.elapsed = 0

        self.pos = self.initial
    elseif elapsed >= self.duration then
        -- Tween completed
        self.elapsed = self.duration

        self.pos = self.target
    else
        -- Tweening
        self.elapsed = elapsed

        self.pos = apply_easing(self.initial, self.target, self.elapsed, self.duration, self.easing)

        return self.pos
    end
end
function Tween:progress(delta)
    return update(self, self.elapsed + delta)
end
function Tween:reset()
    return update(self, 0)
end

function _tween.new(args)
    args = args or {}

    args.elapsed = 0
    args.easing = get_easing_function(args.easing)

    return setmetatable(args, { __index = Tween })
end

return setmetatable(_tween, { __call = function (_, ...) return _tween.new(...) end })
