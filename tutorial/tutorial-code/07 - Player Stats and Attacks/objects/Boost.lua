Boost = GameObject:extend()

function Boost:new(area, x, y, opts)
    Boost.super.new(self, area, x, y, opts)

    local direction = table.random({-1, 1})
    self.x = gw/2 + direction*(gw/2 + 48)
    self.y = random(48, gh - 48)

    self.w, self.h = 12, 12
    self.collider = self.area.world:newRectangleCollider(self.x, self.y, self.w, self.h)
    self.collider:setObject(self)
    self.collider:setCollisionClass('Collectable')
    self.collider:setFixedRotation(false)
    self.v = -direction*random(20, 40)
    self.collider:setLinearVelocity(self.v, 0)
    self.collider:applyAngularImpulse(random(-24, 24))
end

function Boost:update(dt)
    Boost.super.update(self, dt)

    self.collider:setLinearVelocity(self.v, 0) 
end

function Boost:draw()
    love.graphics.setColor(boost_color)
    pushRotate(self.x, self.y, self.collider:getAngle())
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
