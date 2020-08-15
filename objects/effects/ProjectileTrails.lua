ProjectileTrails = Object:extend()

function ProjectileTrails:new()
    self.timer = Timer()

    self.xs = {}
    self.ys = {}
    self.ss = {}
    self.alphas = {}
    self.durations = {}
    self.rs = {}
    self.colors = {}
    self.tweens = {}
    self.creation_times = {}
    self.active = {}

    for i = 1, 2000 do
        self.xs[i] = 0
        self.ys[i] = 0
        self.ss[i] = 0
        self.alphas[i] = 0
        self.durations[i] = 0
        self.rs[i] = 0
        self.colors[i] = default_color
        self.tweens[i] = 0
        self.creation_times[i] = 0
        self.active[i] = false
    end
end

function ProjectileTrails:update(dt)
    self.timer:update(dt)
    for i = 1, 2000 do
        if self.active[i] and love.timer.getTime() > (self.creation_times[i] + self.durations[i]) then
            self:remove(i)
        end
    end
end

function ProjectileTrails:draw()
    for i = 1, 2000 do
        if self.active[i] then
            pushRotate(self.xs[i], self.ys[i], self.rs[i])
            local r, g, b = unpack(self.colors[i])
            love.graphics.setColor(r, g, b, self.alphas[i])
            love.graphics.setLineWidth(2)
            love.graphics.line(self.xs[i] - 2*self.ss[i], self.ys[i], self.xs[i] + 2*self.ss[i], self.ys[i])
            love.graphics.setLineWidth(1)
            love.graphics.setColor(255, 255, 255, 255)
            love.graphics.pop()
        end
    end
end


function ProjectileTrails:add(x, y, r, s, color)
    local i = self:getFreeIndex()
    if not i then return end
    self.xs[i] = x
    self.ys[i] = y
    self.rs[i] = r
    self.ss[i] = s
    self.colors[i] = color
    self.alphas[i] = 128
    self.durations[i] = random(0.2, 0.3)
    self.tweens[i] = self.timer:tween(self.durations[i], self.alphas, {[i] = 0}, 'in-out-cubic')
    self.creation_times[i] = love.timer.getTime()
    self.active[i] = true
end

function ProjectileTrails:remove(i)
    self.xs[i] = nil
    self.ys[i] = nil
    self.rs[i] = nil
    self.ss[i] = nil
    self.alphas[i] = nil
    self.colors[i] = nil
    self.durations[i] = nil
    self.timer:cancel(self.tweens[i])
    self.tweens[i] = nil
    self.creation_times[i] = nil
    self.active[i] = false
end

function ProjectileTrails:getFreeIndex()
    for i = 1, 2000 do
        if not self.active[i] then return i end
    end
end
