ShockwaveDisplacement = GameObject:extend()

function ShockwaveDisplacement:new(area, x, y, opts)
    ShockwaveDisplacement.super.new(self, area, x, y, opts)

    self.graphics_types = {'shockwave'}
    self.sx, self.sy = 0.05, 0.05
    self.alpha = 255
    self.timer:tween(0.5, self, {sx = 0.75*(opts.wm or 1), sy = 0.75*(opts.wm or 1), alpha = 0}, 'linear', function() self.dead = true end)
end

function ShockwaveDisplacement:update(dt)
    ShockwaveDisplacement.super.update(self, dt)
end

function ShockwaveDisplacement:draw()
    love.graphics.setColor(255, 255, 255, self.alpha)
    love.graphics.draw(assets.shockwave_displacement, self.x, self.y, 0, self.sx, self.sy, assets.shockwave_displacement:getWidth()/2, assets.shockwave_displacement:getHeight()/2)
    love.graphics.setColor(255, 255, 255, 255)
end

function ShockwaveDisplacement:destroy()
    ShockwaveDisplacement.super.destroy(self)
end
