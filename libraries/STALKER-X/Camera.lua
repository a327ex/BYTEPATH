--[[
MIT License

Copyright (c) 2017 SSYGEN

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]--

local function lerp(a, b, x) return a + (b - a)*x end
local function csnap(v, x) return math.ceil(v/x)*x - x/2 end

-- Shake according to https://jonny.morrill.me/en/blog/gamedev-how-to-implement-a-camera-shake-effect/
local function newShake(amplitude, duration, frequency)
    local self = {
        amplitude = amplitude or 0,
        duration = duration or 0,
        frequency = frequency or 60,
        samples = {},
        start_time = love.timer.getTime()*1000,
        t = 0,
        shaking = true,
    }

    local sample_count = (self.duration/1000)*self.frequency
    for i = 1, sample_count do self.samples[i] = 2*love.math.random()-1 end

    return self
end

local function updateShake(self, dt)
    self.t = love.timer.getTime()*1000 - self.start_time
    if self.t > self.duration then self.shaking = false end
end

local function shakeNoise(self, s)
    if s >= #self.samples then return 0 end
    return self.samples[s] or 0
end

local function shakeDecay(self, t)
    if t > self.duration then return 0 end
    return (self.duration - t)/self.duration
end

local function getShakeAmplitude(self, t)
    if not t then
        if not self.shaking then return 0 end
        t = self.t
    end

    local s = (t/1000)*self.frequency
    local s0 = math.floor(s)
    local s1 = s0 + 1
    local k = shakeDecay(self, t)
    return self.amplitude*(shakeNoise(self, s0) + (s - s0)*(shakeNoise(self, s1) - shakeNoise(self, s0)))*k
end

-- Camera
local Camera = {}
Camera.__index = Camera

local function new(x, y, w, h, scale, rotation)
    return setmetatable({
        x = x or (w or love.graphics.getWidth())/2, y = y or (h or love.graphics.getHeight())/2,
        mx = x or (w or love.graphics.getWidth())/2, my = y or (h or love.graphics.getHeight())/2,
        screen_x = x or (w or love.graphics.getWidth())/2, screen_y = y or (h or love.graphics.getHeight())/2,
        w = w or love.graphics.getWidth(), h = h or love.graphics.getHeight(),
        scale = scale or 1,
        rotation = rotation or 0,
        horizontal_shakes = {}, vertical_shakes = {},
        target_x = nil, target_y = nil,
        scroll_x = 0, scroll_y = 0,
        last_target_x = nil, last_target_y = nil,
        follow_lerp_x = 1, follow_lerp_y = 1,
        follow_lead_x = 0, follow_lead_y = 0,
        deadzone = nil, bound = nil,
        draw_deadzone = false,
        flash_duration = 1, flash_timer = 0, flash_color = {0, 0, 0, 255},
        fade_duration = 1, fade_timer = 0, fade_color = {0, 0, 0, 0},
    }, Camera)
end

function Camera:attach()
    love.graphics.push()
    love.graphics.translate(self.w/2, self.h/2)
    love.graphics.scale(self.scale)
    love.graphics.rotate(self.rotation)
    love.graphics.translate(-self.x, -self.y)
end

function Camera:detach()
    love.graphics.pop()
end

function Camera:move(dx, dy)
    self.x, self.y = self.x + dx, self.y + dy
end

function Camera:toWorldCoords(x, y)
    local c, s = math.cos(self.rotation), math.sin(self.rotation)
    x, y = (x - self.w/2)/self.scale, (y - self.h/2)/self.scale
    x, y = c*x - s*y, s*x + c*y
    return x + self.x, y + self.y
end

function Camera:toCameraCoords(x, y)
    local c, s = math.cos(self.rotation), math.sin(self.rotation)
    x, y = x - self.x, y - self.y
    x, y = c*x - s*y, s*x + c*y
    return x*self.scale + self.w/2, y*self.scale + self.h/2
end

function Camera:getMousePosition()
    return self:toWorldCoords(love.mouse.getPosition())
end

function Camera:shake(intensity, duration, frequency, axes)
    if not axes then axes = 'XY' end
    axes = string.upper(axes)

    if string.find(axes, 'X') then table.insert(self.horizontal_shakes, newShake(intensity, duration*1000, frequency)) end
    if string.find(axes, 'Y') then table.insert(self.vertical_shakes, newShake(intensity, duration*1000, frequency)) end
end

function Camera:update(dt)
    self.mx, self.my = self:toWorldCoords(love.mouse.getPosition())

    -- Flash --
    if self.flashing then
        self.flash_timer = self.flash_timer + dt
        if self.flash_timer > self.flash_duration then
            self.flash_timer = 0
            self.flashing = false
        end
    end

    -- Fade --
    if self.fading then
        self.fade_timer = self.fade_timer + dt
        self.fade_color = {
            lerp(self.base_fade_color[1], self.target_fade_color[1], self.fade_timer/self.fade_duration),
            lerp(self.base_fade_color[2], self.target_fade_color[2], self.fade_timer/self.fade_duration),
            lerp(self.base_fade_color[3], self.target_fade_color[3], self.fade_timer/self.fade_duration),
            lerp(self.base_fade_color[4], self.target_fade_color[4], self.fade_timer/self.fade_duration),
        }
        if self.fade_timer > self.fade_duration then
            self.fade_timer = 0
            self.fading = false
        end
    end

    -- Shake --
    local horizontal_shake_amount, vertical_shake_amount = 0, 0
    for i = #self.horizontal_shakes, 1, -1 do
        updateShake(self.horizontal_shakes[i], dt)
        horizontal_shake_amount = horizontal_shake_amount + getShakeAmplitude(self.horizontal_shakes[i])
        if not self.horizontal_shakes[i].shaking then table.remove(self.horizontal_shakes, i) end
    end
    for i = #self.vertical_shakes, 1, -1 do
        updateShake(self.vertical_shakes[i], dt)
        vertical_shake_amount = vertical_shake_amount + getShakeAmplitude(self.vertical_shakes[i])
        if not self.vertical_shakes[i].shaking then table.remove(self.vertical_shakes, i) end
    end
    self:move(horizontal_shake_amount, vertical_shake_amount)

    -- Follow -- 
    if not self.target_x and not self.target_y then return end

    -- Set follow style deadzones
    if self.follow_style == 'LOCKON' then
        local w, h = self.w/16, self.w/16
        self:setDeadzone((self.w - w)/2, (self.h - h)/2, w, h)

    elseif self.follow_style == 'PLATFORMER' then
        local w, h = self.w/8, self.h/3
        self:setDeadzone((self.w - w)/2, (self.h - h)/2 - h*0.25, w, h)

    elseif self.follow_style == 'TOPDOWN' then
        local s = math.max(self.w, self.h)/4
        self:setDeadzone((self.w - s)/2, (self.h - s)/2, s, s)

    elseif self.follow_style == 'TOPDOWN_TIGHT' then
        local s = math.max(self.w, self.h)/8
        self:setDeadzone((self.w - s)/2, (self.h - s)/2, s, s)

    elseif self.follow_style == 'SCREEN_BY_SCREEN' then
        self:setDeadzone(0, 0, 0, 0)

    elseif self.follow_style == 'NO_DEADZONE' then
        self.deadzone = nil
    end

    -- No deadzone means we just track the target with no lerp
    if not self.deadzone then 
        self.x, self.y = self.target_x, self.target_y 
        if self.bound then
            self.x = math.min(math.max(self.x, self.bounds_min_x + self.w/2), self.bounds_max_x - self.w/2)
            self.y = math.min(math.max(self.y, self.bounds_min_y + self.h/2), self.bounds_max_y - self.h/2)
        end
        return
    end

    -- Convert appropriate variables to camera coordinates since the deadzone is applied in terms of the camera and not the world
    local dx1, dy1, dx2, dy2 = self.deadzone_x, self.deadzone_y, self.deadzone_x + self.deadzone_w, self.deadzone_y + self.deadzone_h
    local scroll_x, scroll_y = 0, 0
    local target_x, target_y = self:toCameraCoords(self.target_x, self.target_y)
    local x, y = self:toCameraCoords(self.x, self.y)

    -- Screen by screen follow mode needs to be handled a bit differently
    if self.follow_style == 'SCREEN_BY_SCREEN' then
        -- Don't change self.screen_x/y if already at the boundaries
        if self.bound then
            if self.x > self.bounds_min_x + self.w/2 and target_x < 0 then self.screen_x = csnap(self.screen_x - self.w/self.scale, self.w/self.scale) end
            if self.x < self.bounds_max_x - self.w/2 and target_x >= self.w then self.screen_x = csnap(self.screen_x + self.w/self.scale, self.w/self.scale) end
            if self.y > self.bounds_min_y + self.h/2 and target_y < 0 then self.screen_y = csnap(self.screen_y - self.h/self.scale, self.h/self.scale) end
            if self.y < self.bounds_max_y - self.h/2 and target_y >= self.h then self.screen_y = csnap(self.screen_y + self.h/self.scale, self.h/self.scale) end
        -- Move to the next screen if the target is outside the screen boundaries
        else
            if target_x < 0 then self.screen_x = csnap(self.screen_x - self.w/self.scale, self.w/self.scale) end
            if target_x >= self.w then self.screen_x = csnap(self.screen_x + self.w/self.scale, self.w/self.scale) end
            if target_y < 0 then self.screen_y = csnap(self.screen_y - self.h/self.scale, self.h/self.scale) end
            if target_y >= self.h then self.screen_y = csnap(self.screen_y + self.h/self.scale, self.h/self.scale) end
        end
        self.x = lerp(self.x, self.screen_x, self.follow_lerp_x)
        self.y = lerp(self.y, self.screen_y, self.follow_lerp_y)

        -- Apply bounds
        if self.bound then
            self.x = math.min(math.max(self.x, self.bounds_min_x + self.w/2), self.bounds_max_x - self.w/2)
            self.y = math.min(math.max(self.y, self.bounds_min_y + self.h/2), self.bounds_max_y - self.h/2)
        end

    -- All other follow modes
    else
        -- Figure out how much the camera needs to scroll
        if target_x < x then
            local d = target_x - dx1
            if d < 0 then scroll_x = d end
        end
        if target_x > x then
            local d = target_x - dx2
            if d > 0 then scroll_x = d end
        end
        if target_y < y then
            local d = target_y - dy1
            if d < 0 then scroll_y = d end
        end
        if target_y > y then
            local d = target_y - dy2
            if d > 0 then scroll_y = d end
        end

        -- Apply lead
        if not self.last_target_x and not self.last_target_y then self.last_target_x, self.last_target_y = self.target_x, self.target_y end
        scroll_x = scroll_x + (self.target_x - self.last_target_x)*self.follow_lead_x
        scroll_y = scroll_y + (self.target_y - self.last_target_y)*self.follow_lead_y
        self.last_target_x, self.last_target_y = self.target_x, self.target_y

        -- Scroll towards target with lerp
        self.x = lerp(self.x, self.x + scroll_x, self.follow_lerp_x)
        self.y = lerp(self.y, self.y + scroll_y, self.follow_lerp_y)

        -- Apply bounds
        if self.bound then
            self.x = math.min(math.max(self.x, self.bounds_min_x + self.w/2), self.bounds_max_x - self.w/2)
            self.y = math.min(math.max(self.y, self.bounds_min_y + self.h/2), self.bounds_max_y - self.h/2)
        end
    end
end

function Camera:draw()
    if self.draw_deadzone and self.deadzone then
        local n = love.graphics.getLineWidth()
        love.graphics.setLineWidth(2)
        love.graphics.line(self.deadzone_x - 1, self.deadzone_y, self.deadzone_x + 6, self.deadzone_y)
        love.graphics.line(self.deadzone_x, self.deadzone_y, self.deadzone_x, self.deadzone_y + 6)
        love.graphics.line(self.deadzone_x - 1, self.deadzone_y + self.deadzone_h, self.deadzone_x + 6, self.deadzone_y + self.deadzone_h)
        love.graphics.line(self.deadzone_x, self.deadzone_y + self.deadzone_h, self.deadzone_x, self.deadzone_y + self.deadzone_h - 6)
        love.graphics.line(self.deadzone_x + self.deadzone_w + 1, self.deadzone_y + self.deadzone_h, self.deadzone_x + self.deadzone_w - 6, self.deadzone_y + self.deadzone_h)
        love.graphics.line(self.deadzone_x + self.deadzone_w, self.deadzone_y + self.deadzone_h, self.deadzone_x + self.deadzone_w, self.deadzone_y + self.deadzone_h - 6)
        love.graphics.line(self.deadzone_x + self.deadzone_w + 1, self.deadzone_y, self.deadzone_x + self.deadzone_w - 6, self.deadzone_y)
        love.graphics.line(self.deadzone_x + self.deadzone_w, self.deadzone_y, self.deadzone_x + self.deadzone_w, self.deadzone_y + 6)
        love.graphics.setLineWidth(n)
    end

    if self.flashing then
        local r, g, b, a = love.graphics.getColor()
        love.graphics.setColor(self.flash_color)
        love.graphics.rectangle('fill', 0, 0, self.w, self.h)
        love.graphics.setColor(r, g, b, a)
    end

    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(self.fade_color)
    love.graphics.rectangle('fill', 0, 0, self.w, self.h)
    love.graphics.setColor(r, g, b, a)
end

function Camera:follow(x, y)
    self.target_x, self.target_y = x, y
end

function Camera:setDeadzone(x, y, w, h)
    self.deadzone = true
    self.deadzone_x = x
    self.deadzone_y = y
    self.deadzone_w = w
    self.deadzone_h = h
end

function Camera:setBounds(x, y, w, h)
    self.bound = true
    self.bounds_min_x = x
    self.bounds_min_y = y
    self.bounds_max_x = x + w
    self.bounds_max_y = y + h
end

function Camera:setFollowStyle(follow_style)
    self.follow_style = follow_style
end

function Camera:setFollowLerp(x, y)
    self.follow_lerp_x = x
    self.follow_lerp_y = y or x
end

function Camera:setFollowLead(x, y)
    self.follow_lead_x = x
    self.follow_lead_y = y or x
end

function Camera:flash(duration, color)
    self.flash_duration = duration
    self.flash_color = color or self.flash_color
    self.flash_timer = 0
    self.flashing = true
end

function Camera:fade(duration, color)
    self.fade_duration = duration
    self.base_fade_color = self.fade_color
    self.target_fade_color = color 
    self.fade_timer = 0
    self.fading = true
end

return setmetatable({new = new}, {__call = function(_, ...) return new(...) end})
