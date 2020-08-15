GlitcherShootEffect = GameObject:extend()

function GlitcherShootEffect:new(area, x, y, opts)
    GlitcherShootEffect.super.new(self, area, x, y, opts)
    self.depth = 75

    self.w = 8
    self.timer:tween(0.1, self, {w = 0}, 'in-out-cubic', function() self.dead = true end)
end

function GlitcherShootEffect:update(dt)
    GlitcherShootEffect.super.update(self, dt)
    if self.parent then self.x, self.y = self.parent.x + self.dx, self.parent.y + self.dy end
end

function GlitcherShootEffect:draw()
    love.graphics.setColor(default_color)
    love.graphics.rectangle('fill', self.x - self.w/2, self.y - self.w/2, self.w, self.w)
end

function GlitcherShootEffect:destroy()
    GlitcherShootEffect.super.destroy(self)
end
