Boost = GameObject:extend()

function Boost:new(area, x, y, opts)
    Boost.super.new(self, area, x, y, opts)

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

function Boost:update(dt)
    Boost.super.update(self, dt)

    self.shape:move(self.vx*dt, 0)
    self.shape:rotate(self.dr*dt)
    self.x, self.y = self.shape:center()
end

function Boost:draw()
    love.graphics.setColor(boost_color)
    pushRotate(self.x, self.y, self.shape._rotation)
    draft:rhombus(self.x, self.y, 1.5*self.w, 1.5*self.h, 'line')
    draft:rhombus(self.x, self.y, 0.5*self.w, 0.5*self.h, 'fill')
    love.graphics.pop()
    love.graphics.setColor(default_color)
end

function Boost:destroy()
    Boost.super.destroy(self)
end

function Boost:die()
    self.dead = true
    self.area:addGameObject('BoostEffect', self.x, self.y, {color = boost_color, w = self.w, h = self.h})
    self.area:addGameObject('InfoText', self.x + table.random({-1, 1})*self.w, self.y + table.random({-1, 1})*self.h, {color = boost_color, text = '+BOOST'})
end
