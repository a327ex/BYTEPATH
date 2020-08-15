Stage = Object:extend()

function Stage:new()
    self.area = Area()
end

function Stage:update(dt)
    self.area:update(dt)
end

function Stage:draw()
    self.area:draw()
end
