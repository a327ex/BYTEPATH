AmmoEffect = GameObject:extend()

function AmmoEffect:new(area, x, y, opts)
    AmmoEffect.super.new(self, area, x, y, opts)
    self.depth = 75

    self.w = 1.5*self.w
    self.h = self.w

    self.current_color = default_color
    self.timer:after(0.1, function() 
        self.current_color = self.color 
        self.timer:after(0.15, function()
            self.dead = true
        end)
    end)
end

function AmmoEffect:update(dt)
    AmmoEffect.super.update(self, dt)
end

function AmmoEffect:draw()
    love.graphics.setColor(self.current_color)
    draft:rhombus(self.x, self.y, self.w, self.h, 'fill')
    love.graphics.setColor(default_color)
end

function AmmoEffect:destroy()
    AmmoEffect.super.destroy(self)
end
