AttackEffect = GameObject:extend()

function AttackEffect:new(area, x, y, opts)
    AttackEffect.super.new(self, area, x, y, opts)
    self.depth = 75

    self.x, self.y = math.floor(self.x), math.floor(self.y)

    self.current_color = default_color
    self.timer:after(0.2, function() 
        self.current_color = self.color 
        self.timer:after(0.35, function()
            self.dead = true
        end)
    end)

    self.visible = true
    self.timer:after(0.2, function()
        self.timer:every(0.05, function() self.visible = not self.visible end, 6)
        self.timer:after(0.35, function() self.visible = true end)
    end)

    self.sx, self.sy = 1, 1
    self.timer:tween(0.35, self, {sx = 2, sy = 2}, 'in-out-cubic')
end

function AttackEffect:update(dt)
    AttackEffect.super.update(self, dt)
end

function AttackEffect:draw()
    if not self.visible then return end

    love.graphics.setColor(self.current_color)
    draft:rhombus(self.x, self.y, self.sx*2*self.w, self.sy*2*self.h, 'line')
    love.graphics.setColor(default_color)
end

function AttackEffect:destroy()
    AttackEffect.super.destroy(self)
end
