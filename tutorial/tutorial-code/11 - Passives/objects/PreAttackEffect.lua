PreAttackEffect = GameObject:extend()

function PreAttackEffect:new(area, x, y, opts)
    PreAttackEffect.super.new(self, area, x, y, opts)

    self.timer:every(0.02, function()
        self.area:addGameObject('TargetParticle', self.x + random(-20, 20), self.y + random(-20, 20), {target_x = self.x, target_y = self.y, color = self.color})
    end)
    self.timer:after(self.duration - self.duration/4, function() self.dead = true end)
end

function PreAttackEffect:update(dt)
    PreAttackEffect.super.update(self, dt)

    if self.shooter and not self.shooter.dead then
        self.x, self.y = self.shooter.x + 1.4*self.shooter.w*math.cos(self.shooter.collider:getAngle()), self.shooter.y + 1.4*self.shooter.w*math.sin(self.shooter.collider:getAngle())
    end
end

function PreAttackEffect:draw()

end

function PreAttackEffect:destroy()
    PreAttackEffect.super.destroy(self)
end
