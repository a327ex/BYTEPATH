--[[
Copyright (c) 2018 SSYGEN

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]--

local Timer = {}
Timer.__index = Timer

function Timer.new()
    local self = {}
    self.timers = {}
    return setmetatable(self, Timer)
end

function Timer:update(dt)
    for tag, timer in pairs(self.timers) do
        timer.time = timer.time + dt

        if timer.type == 'after' then
            if timer.time >= timer.delay then
                timer.action()
                self.timers[tag] = nil
            end

        elseif timer.type == 'every' then
            if timer.time >= timer.delay then
                timer.action()
                timer.time = 0
                timer.delay = self:__getResolvedDelay(timer.any_delay)
                if timer.count > 0 then
                    timer.counter = timer.counter + 1
                    if timer.counter >= timer.count then
                        timer.after()
                        self.timers[tag] = nil
                    end
                end
            end

        elseif timer.type == 'during' then
            timer.action()
            if timer.time >= timer.delay then
                timer.after()
                self.timers[tag] = nil
            end

        elseif timer.type == 'tween' then
            local s = self:__tween(timer.method, math.min(1, timer.time/timer.delay), unpack(timer.args or {}))
            local ds = s - timer.last_s
            timer.last_s = s
            for _, info in ipairs(timer.payload) do
                local ref, key, delta = unpack(info)
                ref[key] = ref[key] + delta*ds
            end
            if timer.time >= timer.delay then
                timer.after()
                self.timers[tag] = nil
            end
        end
    end
end

local function UUID()
    local fn = function(x)
        local r = love.math.random(16) - 1
        r = (x == "x") and (r + 1) or (r % 4) + 9
        return ("0123456789abcdef"):sub(r, r)
    end
    return (("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"):gsub("[xy]", fn))
end

local function random(min, max)
    local min, max = min or 0, max or 1
    return (min > max and (love.math.random()*(min - max) + max)) or (love.math.random()*(max - min) + min)
end

function Timer:after(delay, action, tag)
    tag = tag or UUID()
    self:cancel(tag)
    self.timers[tag] = {type = 'after', time = 0, delay = self:__getResolvedDelay(delay), action = action}
    return tag
end

function Timer:every(delay, action, count, after, tag)
    if type(count) == 'string' then tag, count = count, 0
    elseif type(count) == 'number' and type(after) == 'string' then tag = after
    else tag = tag or UUID() end
    self:cancel(tag)
    self.timers[tag] = {type = 'every', time = 0, any_delay = delay, delay = self:__getResolvedDelay(delay), action = action, counter = 0, count = count or 0, after = after or function() end}
    return tag
end

function Timer:during(delay, action, after, tag)
    if type(after) == 'string' then tag, after = after, nil
    elseif type(after) == 'function' then tag = UUID()
    else tag = tag or UUID() end
    self:cancel(tag)
    self.timers[tag] = {type = 'during', time = 0, delay = self:__getResolvedDelay(delay), action = action, after = after or function() end}
    return tag
end

function Timer:script(f)
    local co = coroutine.wrap(f)
    co(function(t)
        self:after(t, co)
        coroutine.yield()
    end)
end

function Timer:tween(delay, subject, target, method, after, tag, ...)
    if type(after) == 'string' then tag, after = after, nil
    elseif type(after) == 'function' then tag = UUID()
    else tag = tag or UUID() end
    self:cancel(tag)
    self.timers[tag] = {type = 'tween', time = 0, delay = self:__getResolvedDelay(delay), subject = subject, target = target, method = method, after = after or function() end, 
                        args = {...}, last_s = 0, payload = self:__tweenCollectPayload(subject, target, {})}
    return tag
end

function Timer:cancel(tag)
    self.timers[tag] = nil
end

function Timer:destroy()
    self.timers = {}
end

function Timer:getTime(tag)
    return self.timers[tag].time, self.timers[tag].delay
end

function Timer:__getResolvedDelay(delay)
    if type(delay) == 'number' then return delay
    elseif type(delay) == 'table' then return random(delay[1], delay[2]) end
end

local t = {}
t.out = function(f) return function(s, ...) return 1 - f(1-s, ...) end end
t.chain = function(f1, f2) return function(s, ...) return (s < 0.5 and f1(2*s, ...) or 1 + f2(2*s-1, ...))*0.5 end end
t.linear = function(s) return s end
t.quad = function(s) return s*s end
t.cubic = function(s) return s*s*s end
t.quart = function(s) return s*s*s*s end
t.quint = function(s) return s*s*s*s*s end
t.sine = function(s) return 1-math.cos(s*math.pi/2) end
t.expo = function(s) return 2^(10*(s-1)) end
t.circ = function(s) return 1-math.sqrt(1-s*s) end
t.back = function(s, bounciness) bounciness = bounciness or 1.70158; return s*s*((bounciness+1)*s - bounciness) end
t.bounce = function(s) local a, b = 7.5625, 1/2.75; return math.min(a*s^2, a*(s-1.5*b)^2 + 0.75, a*(s-2.25*b)^2 + 0.9375, a*(s-2.625*b)^2 + 0.984375) end
t.elastic = function(s, amp, period) amp, period = amp and math.max(1, amp) or 1, period or 0.3; return (-amp*math.sin(2*math.pi/period*(s-1) - math.asin(1/amp)))*2^(10*(s-1)) end

function Timer:__tween(method, ...)
    if method == 'linear' then return t.linear(...)
    elseif method:find('in%-out%-') then return t.chain(t[method:sub(8, -1)], t.out(t[method:sub(8, -1)]))(...)
    elseif method:find('out%-in%-') then return t.chain(t.out(t[method:sub(8, -1)]), t[method:sub(8, -1)])(...)
    elseif method:find('out-') then return t.out(t[method:sub(5, -1)])(...)
    elseif method:find('in-') then return t[method:sub(4, -1)](...) end
end

function Timer:__tweenCollectPayload(subject, target, out)
    for k, v in pairs(target) do
        local ref = subject[k]
        assert(type(v) == type(ref), 'Type mismatch in field "' .. k .. '".')
        if type(v) == 'table' then self:__tweenCollectPayload(ref, v, out)
        else
            local ok, delta = pcall(function() return (v-ref)*1 end)
            assert(ok, 'Field "' .. k .. '" does not support arithmetic operations.')
            out[#out+1] = {subject, k, delta}
        end
    end
    return out
end

return setmetatable({}, {__call = function(_, ...) return Timer.new(...) end})
