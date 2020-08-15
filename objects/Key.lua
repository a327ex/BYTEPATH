Key = GameObject:extend()

function Key:new(area, x, y, opts)
    Key.super.new(self, area, x, y, opts)

    playGameKey()

    local direction = table.random({-1, 1})
    self.x = gw/2 + direction*(gw/2 + 48)
    self.y = random(48, gh - 48)

    self.w, self.h = 12, 12
    self.shape = HC.rectangle(self.x, self.y, self.w, self.h)
    self.shape.object = self
    self.shape.id = self.id
    self.shape.tag = 'Collectable'

    self.v = -direction*random(10, 20)
    self.vx = self.v
    self.dr = random(-10, 10)

    self.sx, self.sy = 1, 1
    self.alpha = 255
    self.timer:every(1, function()
        self.timer:tween(1, self, {alpha = 0, sx = 2, sy = 2}, 'in-out-cubic', function()
            self.sx, self.sy = 1, 1
            self.alpha = 255
        end)
    end)
end

function Key:update(dt)
    Key.super.update(self, dt)

    self.shape:move(self.vx*dt, 0)
    self.shape:rotate(self.dr*dt)
    self.x, self.y = self.shape:center()
end

function Key:draw()
    pushRotateScale(self.x, self.y, 0, random(0.95, 1.05), random(0.95, 1.05))
    love.graphics.setColor(default_color)
    draft:rhombus(self.x, self.y, 1.5*self.w, 1.5*self.h, 'line')
    draft:rhombus(self.x, self.y, 0.5*self.w, 0.5*self.h, 'fill')
    draft:rhombus(self.x, self.y, 2*self.w, 2*self.h, 'line')
    draft:rhombus(self.x, self.y, 2.5*self.w, 2.5*self.h, 'line')
    love.graphics.pop()
    love.graphics.setColor(222, 222, 222, self.alpha)
    draft:rhombus(self.x, self.y, self.sx*3*self.w, self.sy*3*self.h, 'line')
    love.graphics.setColor(255, 255, 255)
end

function Key:die()
    self.dead = true
    self.area:addGameObject('BoostEffect', self.x, self.y, {color = default_color, w = 2*self.w, h = 2*self.h})
    self.area:addGameObject('InfoText', self.x + table.random({-1, 1})*self.w, self.y + table.random({-1, 1})*self.h, {color = default_color, text = '+KEY'})
end
