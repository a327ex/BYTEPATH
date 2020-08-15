GlitchBlockDisplacement = GameObject:extend()

function GlitchBlockDisplacement:new(area, x, y, opts)
    GlitchBlockDisplacement.super.new(self, area, x, y, opts)

    self.graphics_types = {'glitch_block'}
    self.dead = false

    -- 0-32 -- inverse
    -- 32-64
    -- 64-96
    -- 96-128
    -- 128-160
    -- 160-192
    -- 192-224
    -- 224-255

    local r = 48
    self.color = {r, r, r}

    self.type = 'rectangular_block_shift'
    self.x, self.y = love.math.random(0, gw), love.math.random(0, gh)
    self.w, self.h = love.math.random(16, 48), love.math.random(8, 16)
    self.timer:after(random(0.05, 0.4), function() self.dead = true end)
end

function GlitchBlockDisplacement:update(dt)
    GlitchBlockDisplacement.super.update(self, dt)
end

function GlitchBlockDisplacement:draw()
    love.graphics.setColor(self.color)
    love.graphics.rectangle('fill', self.x - self.w/2, self.y - self.h/2, self.w, self.h)
    love.graphics.setColor(255, 255, 255, 255)
end

function GlitchBlockDisplacement:destroy()
    GlitchBlockDisplacement.super.destroy(self)
end
