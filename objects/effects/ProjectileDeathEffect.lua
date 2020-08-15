ProjectileDeathEffect = GameObject:extend()

function ProjectileDeathEffect:new(area, x, y, opts)
    ProjectileDeathEffect.super.new(self, area, x, y, opts)
    self.depth = 75

    if self.attack == 'Laser' then 
        self.w = 3*self.w
        self.h = self.w
    end

    self.current_color = default_color
    self.timer:after(0.1, function() 
        self.current_color = self.color 
        self.timer:after(0.15, function()
            self.dead = true
        end)
    end)
end

function ProjectileDeathEffect:update(dt)
    ProjectileDeathEffect.super.update(self, dt)
end

function ProjectileDeathEffect:draw()
    pushRotate(self.x, self.y, self.r or 0)
    love.graphics.setColor(self.current_color)
    love.graphics.rectangle('fill', self.x - self.w/2, self.y - self.w/2, self.w, self.w)
    love.graphics.setColor(default_color)
    love.graphics.pop()
end

function ProjectileDeathEffect:destroy()
    ProjectileDeathEffect.super.destroy(self)
end
