GlitchDisplacementC = Object:extend()

function GlitchDisplacementC:new(x, y, w, h, color)
    self.timer = Timer()
    self.x, self.y = x, y
    self.w, self.h = w, h
    self.color = color
    self.dead = false
    self.timer:after(random(0.05, 0.4), function() self.dead = true end)
end

function GlitchDisplacementC:update(dt)
    self.timer:update(dt)
end

function GlitchDisplacementC:draw()
    love.graphics.setColor(self.color)
    love.graphics.rectangle('fill', self.x - self.w/2, self.y - self.h/2, self.w, self.h)
    love.graphics.setColor(255, 255, 255, 255)
end
