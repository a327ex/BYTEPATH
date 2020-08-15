Item = GameObject:extend()

function Item:new(area, x, y, opts)
    Item.super.new(self, area, x, y, opts)
    
    local direction = table.random({-1, 1})
    self.x = gw/2 + direction*(gw/2 + 48)
    self.y = random(48, gh - 48)

    self.w, self.h = 10, 10
    self.shape = HC.rectangle(self.x, self.y, self.w, self.h)
    self.shape.object = self
    self.shape.id = self.id
    self.shape.tag = 'Collectable'

    self.v = -direction*random(20, 40)
    self.vx = self.v
    self.dr = random(-10, 10)

    self.font = fonts.m5x7_16
end

function Item:update(dt)
    Item.super.update(self, dt)

    self.shape:move(self.vx*dt, 0)
    self.shape:rotate(self.dr*dt)
    self.x, self.y = self.shape:center()
end

function Item:draw()
    pushRotateScale(self.x, self.y, 0, random(0.95, 1.05), random(0.95, 1.05))
    love.graphics.setColor(default_color)
    love.graphics.print('I', self.x, self.y, 0, 1, 1, math.floor(self.font:getWidth('I')/2), math.floor(self.font:getHeight()/2))
    draft:rhombus(self.x, self.y, 3*self.w, 3*self.w, 'line')
    love.graphics.setColor(default_color)
    draft:rhombus(self.x, self.y, 2.5*self.w, 2.5*self.w, 'line')
    love.graphics.pop()

end

function Item:destroy()
    Item.super.destroy(self)
end

function Item:die()
    self.dead = true
    self.area:addGameObject('AttackEffect', self.x, self.y, {color = default_color, w = 1.1*self.w, h = 1.1*self.h}) 
    self.area:addGameObject('AttackEffect', self.x, self.y, {color = default_color, w = 1.3*self.w, h = 1.3*self.h})
end
