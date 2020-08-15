GlitchDisplacement = GameObject:extend()

function GlitchDisplacement:new(area, x, y, opts)
    GlitchDisplacement.super.new(self, area, x, y, opts)

    self.graphics_types = {'glitch'}
    self.dead = false

    self.type = opts.type or table.random({'horizontal_bar_shift', 'rectangular_block_shift'})
    if self.type == 'horizontal_bar_shift' then
        self.x, self.y = opts.x or love.math.random(0, gw), opts.y or love.math.random(0, gh)
        self.w, self.h = opts.w or 2*gw, opts.h or love.math.random(8, 16)
        local r = 127 + love.math.random(-4, 4)*(glitch/10)
        self.color = {r, r, r}
        self.timer:tween(random(0.05, 0.4), self, {color = {127, 127, 127}}, 'in-out-cubic', function() self.dead = true end)
    elseif self.type == 'rectangular_block_shift' then
        self.x, self.y = opts.x or love.math.random(0, gw), opts.y or love.math.random(0, gh)
        self.w, self.h = opts.w or love.math.random(16, 48), opts.h or love.math.random(8, 16)
        local r = 127 + love.math.random(-4, 4)*(glitch/10)
        self.color = {r, r, r}
        self.timer:tween(random(0.05, 0.4), self, {color = {127, 127, 127}}, 'in-out-cubic', function() self.dead = true end)
    end
end

function GlitchDisplacement:update(dt)
    GlitchDisplacement.super.update(self, dt)
end

function GlitchDisplacement:draw()
    love.graphics.setColor(self.color)
    love.graphics.rectangle('fill', self.x - self.w/2, self.y - self.h/2, self.w, self.h)
    love.graphics.setColor(255, 255, 255, 255)
end

function GlitchDisplacement:destroy()
    GlitchDisplacement.super.destroy(self)
end
