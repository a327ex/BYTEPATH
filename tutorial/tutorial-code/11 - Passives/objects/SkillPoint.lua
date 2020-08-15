SkillPoint = GameObject:extend()

function SkillPoint:new(area, x, y, opts)
    SkillPoint.super.new(self, area, x, y, opts)

    local direction = table.random({-1, 1})
    self.x = gw/2 + direction*(gw/2 + 48)
    self.y = random(16, gh - 16)

    self.w, self.h = 12, 12
    self.collider = self.area.world:newRectangleCollider(self.x, self.y, self.w, self.h)
    self.collider:setObject(self)
    self.collider:setCollisionClass('Collectable')
    self.collider:setFixedRotation(false)
    self.v = -direction*random(20, 40)
    self.collider:setLinearVelocity(self.v, 0)
    self.collider:applyAngularImpulse(random(-24, 24))
end

function SkillPoint:update(dt)
    SkillPoint.super.update(self, dt)

    self.collider:setLinearVelocity(self.v, 0) 
end

function SkillPoint:draw()
    love.graphics.setColor(skill_point_color)
    pushRotate(self.x, self.y, self.collider:getAngle())
    draft:rhombus(self.x, self.y, 1.5*self.w, 1.5*self.h, 'line')
    draft:rhombus(self.x, self.y, 0.5*self.w, 0.5*self.h, 'fill')
    love.graphics.pop()
    love.graphics.setColor(default_color)
end

function SkillPoint:destroy()
    SkillPoint.super.destroy(self)
end

function SkillPoint:die()
    self.dead = true
    self.area:addGameObject('BoostEffect', self.x, self.y, {color = skill_point_color, w = self.w, h = self.h})
    self.area:addGameObject('InfoText', self.x + table.random({-1, 1})*self.w, self.y + table.random({-1, 1})*self.h, {color = skill_point_color, text = '+1 SP'})
end
