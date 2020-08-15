RollerPool = GameObject:extend()

function RollerPool:new(area, x, y, opts)
    RollerPool.super.new(self, area, x, y, opts)

    self.graphics_types = {'rgb_shift'}

    self.w, self.h = 0, 0
    self.r = 0
    self.timer:tween(random(0.5, 1), self, {w = 18, h = 18, r = random(0, 2*math.pi)}, 'in-out-cubic') 
    self.timer:after(6, function()
        self.timer:tween(random(0.5, 1), self, {w = 0, h = 0, r = 0}, 'in-out-cubic', function() self.dead = true end)
    end)
end

function RollerPool:update(dt)
    RollerPool.super.update(self, dt)

    local player = current_room.player
    if player.x >= self.x - self.w/2 and player.x <= self.x + self.w/2 and player.y >= self.y - self.h/2 and player.y <= self.y + self.h/2 then player.inside_roller_pool = true end
end

function RollerPool:draw()
    pushRotate(self.x, self.y, self.r)
    love.graphics.setColor(hp_color)
    love.graphics.rectangle('line', self.x - self.w/2, self.y - self.h/2, self.w, self.h)
    love.graphics.setColor(255, 255, 255)
    love.graphics.pop()
end
