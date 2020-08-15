TrailerShootEffect = GameObject:extend()

function TrailerShootEffect:new(area, x, y, opts)
    TrailerShootEffect.super.new(self, area, x, y, opts)
    self.depth = 75

    self.w = 8
    self.timer:tween(0.1, self, {w = 0}, 'in-out-cubic', function() self.dead = true end)
end

function TrailerShootEffect:update(dt)
    TrailerShootEffect.super.update(self, dt)
    if self.parent then self.x, self.y = self.parent.x + self.d*math.cos(self.parent.r - math.pi), self.parent.y + self.d*math.sin(self.parent.r - math.pi) end
end

function TrailerShootEffect:draw()
    pushRotate(self.x, self.y, ((self.parent and self.parent.r) or 0) + math.pi/4)
    love.graphics.setColor(hp_color)
    love.graphics.rectangle('fill', self.x - self.w/2, self.y - self.w/2, self.w, self.w)
    love.graphics.pop()
end

function TrailerShootEffect:destroy()
    TrailerShootEffect.super.destroy(self)
end
