RGBShift = GameObject:extend()

function RGBShift:new(area, x, y, opts)
    RGBShift.super.new(self, area, x, y, opts)

    self.graphics_types = {'rgb'}
    self.dead = false

    self.type = table.random({'horizontal_bar_shift', 'rectangular_block_shift'})
    if self.type == 'horizontal_bar_shift' then
        self.x, self.y = love.math.random(0, gw), love.math.random(0, gh)
        self.w, self.h = 2*gw, love.math.random(8, 16)
        local r = 127 + love.math.random(-4, 4)*(glitch/10)
        self.color = {r, r, r}
        self.timer:tween(random(0.05, 0.4), self, {color = {127, 127, 127}}, 'in-out-cubic', function() self.dead = true end)
    elseif self.type == 'rectangular_block_shift' then
        self.x, self.y = love.math.random(0, gw), love.math.random(0, gh)
        self.w, self.h = love.math.random(16, 48), love.math.random(8, 16)
        local r = 127 + love.math.random(-4, 4)*(glitch/10)
        self.color = {r, r, r}
        self.timer:tween(random(0.05, 0.4), self, {color = {127, 127, 127}}, 'in-out-cubic', function() self.dead = true end)
    end
end

function RGBShift:update(dt)
    RGBShift.super.update(self, dt)
end

function RGBShift:draw()
    love.graphics.setColor(self.color)
    love.graphics.rectangle('fill', self.x - self.w/2, self.y - self.h/2, self.w, self.h)
    love.graphics.setColor(255, 255, 255, 255)
end

function RGBShift:destroy()
    RGBShift.super.destroy(self)
end
