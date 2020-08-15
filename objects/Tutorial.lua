Tutorial = Object:extend()

function Tutorial:new(x, y)
    self.x, self.y = x, y
    self.timer = Timer()
    self.alpha = 255
    self.timer:after(20, function()
        self.timer:tween(5, self, {alpha = 0}, 'in-out-cubic')
    end)
end

function Tutorial:update(dt)
    self.timer:update(dt)
end

function Tutorial:draw()
    local r, g, b = unpack(background_color)
    love.graphics.setColor(r, g, b, self.alpha)
    love.graphics.rectangle('fill', 10, gh - 20 - 4 - 24, 24, 24)
    love.graphics.rectangle('fill', 10 + 24 + 4, gh - 20 - 4 - 24, 24, 24)
    love.graphics.rectangle('fill', 10 + 48 + 8, gh - 20 - 4 - 24, 24, 24)
    love.graphics.rectangle('fill', 10 + 24 + 4, gh - 20 - 8 - 48, 24, 24)

    local r, g, b = unpack(default_color)
    love.graphics.setColor(r, g, b, self.alpha)
    love.graphics.rectangle('line', 10, gh - 20 - 4 - 24, 24, 24)
    love.graphics.rectangle('line', 10 + 24 + 4, gh - 20 - 4 - 24, 24, 24)
    love.graphics.rectangle('line', 10 + 48 + 8, gh - 20 - 4 - 24, 24, 24)
    love.graphics.rectangle('line', 10 + 24 + 4, gh - 20 - 8 - 48, 24, 24)

    pushRotate(10 + 12, gh - 20 - 4 - 12, -math.pi/2)
    draft:triangleEquilateral(10 + 12, gh - 20 - 4 - 12, 12, 'fill')
    love.graphics.pop()
    pushRotate(10 + 12 + 4 + 24, gh - 20 - 4 - 12, math.pi)
    draft:triangleEquilateral(10 + 12 + 4 + 24, gh - 20 - 4 - 12, 12, 'fill')
    love.graphics.pop()
    pushRotate(10 + 12 + 4 + 24 + 4 + 24, gh - 20 - 4 - 12, math.pi/2)
    draft:triangleEquilateral(10 + 12 + 4 + 24 + 4 + 24, gh - 20 - 4 - 12, 12, 'fill')
    love.graphics.pop()
    draft:triangleEquilateral(10 + 12 + 4 + 24, gh - 20 - 4 - 12 - 24 - 4, 12, 'fill')

    local font = love.graphics.getFont()
    love.graphics.print('BOOST UP', 10 + 12 + 4 + 24, gh - 20 - 4 - 24 - 4 - 24 - 8, 0, 1, 1, math.floor(font:getWidth('BOOST UP')/2), math.floor(font:getHeight()/2))
    love.graphics.print('BOOST DOWN', 10 + 12 + 4 + 24, gh - 20 + 4, 0, 1, 1, math.floor(font:getWidth('BOOST DOWN')/2), math.floor(font:getHeight()/2))

    love.graphics.setColor(255, 255, 255, 255)
end
