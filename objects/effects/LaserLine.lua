LaserLine = GameObject:extend()

function LaserLine:new(area, x, y, opts)
    LaserLine.super.new(self, area, x, y, opts)

    self.line_width = 8*opts.wm
    self.s = 4*opts.wm
    self.b = 0
    self.side_line_width = 1*opts.wm
    self.timer:tween(0.2, self, {line_width = 1, s = 8, b = 16}, 'in-out-cubic', function() self.dead = true end)
    self.timer:after(0.1, function() self.timer:tween(0.1, self, {side_line_width = 0}, 'in-out-cubic') end)
end

function LaserLine:update(dt)
    LaserLine.super.update(self, dt)
end

function LaserLine:draw()
    love.graphics.setLineWidth(self.line_width)
    love.graphics.setColor(default_color)
    love.graphics.line(self.x1, self.y1, self.x2, self.y2)
    love.graphics.setLineWidth(1)

    love.graphics.setLineWidth(self.side_line_width)
    love.graphics.setColor(hp_color)
    local x1u, y1u = self.x1 + self.s*math.cos(self.angle - math.pi/2), self.y1 + self.s*math.sin(self.angle - math.pi/2)
    local x1d, y1d = self.x1 + self.s*math.cos(self.angle + math.pi/2), self.y1 + self.s*math.sin(self.angle + math.pi/2)
    local x2u, y2u = self.x2 + self.s*math.cos(self.angle - math.pi/2), self.y2 + self.s*math.sin(self.angle - math.pi/2)
    local x2d, y2d = self.x2 + self.s*math.cos(self.angle + math.pi/2), self.y2 + self.s*math.sin(self.angle + math.pi/2)
    love.graphics.line(x1u, y1u, x2u, y2u)
    love.graphics.line(x1d, y1d, x2d, y2d)
    love.graphics.setLineWidth(1)
end

function LaserLine:destroy()
    LaserLine.super.destroy(self)
end
