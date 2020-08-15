TrailParticles = Object:extend()

function TrailParticles:new()
    self.timer = Timer()
    self.xs = {}
    self.ys = {}
    self.rs = {}
    self.colors = {}
    self.durations = {}
    self.tweens = {}
    self.creation_times = {}
    self.active = {}

    for i = 1, 2000 do
        self.xs[i] = 0
        self.ys[i] = 0
        self.rs[i] = 0
        self.colors[i] = default_color
        self.durations[i] = 0
        self.tweens[i] = 0
        self.creation_times[i] = 0
        self.active[i] = false
    end
end

function TrailParticles:update(dt)
    self.timer:update(dt)
    for i = 1, 2000 do
        if self.active[i] and love.timer.getTime() > (self.creation_times[i] + self.durations[i]) then
            self:remove(i)
        end
    end
end

function TrailParticles:draw()
    for i = 1, 2000 do
        if self.active[i] then
            love.graphics.setColor(self.colors[i])
            love.graphics.circle('fill', self.xs[i], self.ys[i], self.rs[i])
            love.graphics.setColor(255, 255, 255)
        end
    end
end

function TrailParticles:add(x, y, r, color, d)
    local i = self:getFreeIndex()
    if not i then return end
    self.xs[i] = x
    self.ys[i] = y
    self.rs[i] = r or random(4, 6)
    self.colors[i] = color
    self.durations[i] = d or random(0.3, 0.5)
    self.tweens[i] = self.timer:tween(self.durations[i], self.rs, {[i] = 0}, 'linear')
    self.creation_times[i] = love.timer.getTime()
    self.active[i] = true
end

function TrailParticles:remove(i)
    self.xs[i] = nil
    self.ys[i] = nil
    self.rs[i] = nil
    self.durations[i] = nil
    self.timer:cancel(self.tweens[i])
    self.tweens[i] = nil
    self.creation_times[i] = nil
    self.active[i] = false
end

function TrailParticles:getFreeIndex()
    for i = 1, 2000 do
        if not self.active[i] then return i end
    end
end
