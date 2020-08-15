WaverPreAttackEffect = GameObject:extend()

function WaverPreAttackEffect:new(area, x, y, opts)
    WaverPreAttackEffect.super.new(self, area, x, y, opts)

    self.w, self.h = 12, 6
    self.s = 1
    self.alpha = 255
    self.timer:tween(0.35, self, {alpha = 0, s = 4}, 'in-out-cubic', function() self.dead = true end)
end

function WaverPreAttackEffect:update(dt)
    WaverPreAttackEffect.super.update(self, dt)
    if self.waver and not self.waver.dead then self.x, self.y = self.waver.x, self.waver.y end
end

function WaverPreAttackEffect:draw()
    if not self.waver or self.waver.dead then return end
    local r, g, b = unpack(hp_color)
    love.graphics.setColor(r, g, b, self.alpha)
    pushRotateScale(self.x, self.y, self.waver.r, self.s, self.s)
    love.graphics.polygon('line', self.x + self.w, self.y, self.x, self.y + self.h, self.x - self.w, self.y, self.x, self.y - self.h)
    love.graphics.pop()
    love.graphics.setColor(255, 255, 255, 255)
end

function WaverPreAttackEffect:destroy()
    WaverPreAttackEffect.super.destroy(self)
end
