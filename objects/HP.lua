HP = GameObject:extend()

function HP:new(area, x, y, opts)
    HP.super.new(self, area, x, y, opts)

    local direction = table.random({-1, 1})
    self.x = gw/2 + direction*(gw/2 + 48)
    self.y = random(16, gh - 16)

    self.w, self.h = 12, 12
    self.shape = HC.rectangle(self.x, self.y, self.w, self.h)
    self.shape.object = self
    self.shape.id = self.id
    self.shape.tag = 'Collectable'

    self.v = -direction*random(20, 40)
    self.vx = self.v
    self.dr = random(-10, 10)
end

function HP:update(dt)
    HP.super.update(self, dt)

    self.shape:move(self.vx*dt, 0)
    self.shape:rotate(self.dr*dt)
    self.x, self.y = self.shape:center()
end

function HP:draw()
    love.graphics.setColor(hp_color)
    love.graphics.rectangle('fill', self.x - self.w/2, self.y - 2, self.w, 4)
    love.graphics.rectangle('fill', self.x - 2, self.y - self.h/2, 4, self.h)
    love.graphics.setColor(default_color)
    love.graphics.circle('line', self.x, self.y, self.w)
    love.graphics.setColor(255, 255, 255)
end

function HP:destroy()
    HP.super.destroy(self)
end

function HP:die()
    self.dead = true
    self.area:addGameObject('InfoText', self.x + table.random({-1, 1})*self.w, self.y + table.random({-1, 1})*self.h, {color = hp_color, text = '+HP'})
    self.area:addGameObject('ShapeEffect', self.x, self.y, {color = default_color, w = math.floor(self.w/3), shape = 'circle'})
    self.area:addGameObject('ShapeEffect2', self.x, self.y, {color = hp_color, w = self.w/2, shape = 'health'})

end
