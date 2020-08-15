ExplodeParticles = Object:extend()

function ExplodeParticles:new()
    self.timer = Timer()
    self.xs = {}
    self.ys = {}
    self.ss = {}
    self.vs = {}
    self.rs = {}
    self.colors = {}
    self.line_widths = {}
    self.tweens_ss = {}
    self.tweens_vs = {}
    self.tweens_ls = {}
    self.durations = {}
    self.creation_times = {}
    self.active = {}

    for i = 1, 2000 do
        self.xs[i] = 0
        self.ys[i] = 0
        self.ss[i] = 0
        self.vs[i] = 0
        self.rs[i] = 0
        self.colors[i] = default_color
        self.line_widths[i] = 0
        self.tweens_ss[i] = 0
        self.tweens_vs[i] = 0
        self.tweens_ls[i] = 0
        self.durations[i] = 0
        self.creation_times[i] = 0
        self.active[i] = false
    end
end

function ExplodeParticles:update(dt)
    self.timer:update(dt)
    for i = 1, 2000 do
        if self.active[i] then
            self.xs[i] = self.xs[i] + self.vs[i]*math.cos(self.rs[i])*dt
            self.ys[i] = self.ys[i] + self.vs[i]*math.sin(self.rs[i])*dt
            if love.timer.getTime() > (self.creation_times[i] + self.durations[i]) then
                self:remove(i)
            end
        end
    end
end

function ExplodeParticles:draw()
    for i = 1, 2000 do
        if self.active[i] then
            pushRotate(self.xs[i], self.ys[i], self.rs[i])
            love.graphics.setLineWidth(self.line_widths[i])
            love.graphics.setColor(self.colors[i])
            love.graphics.line(self.xs[i] - self.ss[i], self.ys[i], self.xs[i] + self.ss[i], self.ys[i])
            love.graphics.setColor(255, 255, 255)
            love.graphics.setLineWidth(1)
            love.graphics.pop()
        end
    end
end

function ExplodeParticles:add(x, y, v, s, color)
    local i = self:getFreeIndex()
    if not i then return end
    self.xs[i] = x
    self.ys[i] = y
    self.rs[i] = random(0, 2*math.pi)
    self.ss[i] = s or random(2, 3)
    self.vs[i] = v or random(75, 150)
    self.colors[i] = color or default_color
    self.line_widths[i] = 2
    self.creation_times[i] = love.timer.getTime()
    self.durations[i] = random(0.3, 0.5)
    self.tweens_ss[i] = self.timer:tween(self.durations[i], self.ss, {[i] = 0}, 'linear')
    self.tweens_vs[i] = self.timer:tween(self.durations[i], self.vs, {[i] = 0}, 'linear')
    self.tweens_ls[i] = self.timer:tween(self.durations[i], self.line_widths, {[i] = 0}, 'linear')
    self.active[i] = true
end

function ExplodeParticles:remove(i)
    self.xs[i] = nil
    self.ys[i] = nil
    self.rs[i] = nil
    self.ss[i] = nil
    self.vs[i] = nil
    self.colors[i] = nil
    self.line_widths[i] = nil
    self.creation_times[i] = nil
    self.durations[i] = nil
    self.timer:cancel(self.tweens_ss[i])
    self.timer:cancel(self.tweens_vs[i])
    self.timer:cancel(self.tweens_ls[i])
    self.tweens_ss[i] = nil
    self.tweens_vs[i] = nil
    self.tweens_ls[i] = nil
    self.active[i] = false
end

function ExplodeParticles:getFreeIndex()
    for i = 1, 2000 do
        if not self.active[i] then return i end
    end
end
