ShapeEffect = GameObject:extend()

function ShapeEffect:new(area, x, y, opts)
    ShapeEffect.super.new(self, area, x, y, opts)

    self.x, self.y = math.floor(self.x), math.floor(self.y)
    self.w = 3*self.w
    self.h = self.w
    self.first = true
    self.second = false
    self.default_colors = {default_color, hp_color, ammo_color, boost_color, skill_point_color}
    self.shape = nil
    self.sp = opts.shape

    self.timer:after(0.15, function()
        self.first = false
        self.second = true
        self.timer:after(0.4, function()
            self.second = false
        end)
    end)

    self.sx, self.sy = 1, 1
    self.timer:tween(0.35, self, {sx = 2, sy = 2}, 'in-out-cubic')
    self.timer:after(0.2, function()
        self.timer:every(0.05, function() self.disappear = not self.disappear end, 6)
        self.timer:after(0.35, function() self.disappear = false end)
    end)
end

function ShapeEffect:update(dt)
    ShapeEffect.super.update(self, dt)
end

function ShapeEffect:draw()
    if self.disappear then return end
    if self.first then
        love.graphics.setColor(default_color)
        self:drawShape()
    elseif self.second then
        if self.color == 'random' then love.graphics.setColor(table.random(self.default_colors))
        else love.graphics.setColor(self.color) end
        self:drawShape()
    end
end

function ShapeEffect:destroy()
    ShapeEffect.super.destroy(self)
end

function ShapeEffect:drawShape()
    if self.sp == 'rhombus' then
        draft:rhombus(self.x, self.y, self.sx*self.w, self.sy*self.h, 'line')

    elseif self.sp == 'bsgrectangle' then
        BSGRectangle('line', self.x - self.sx*self.w/2, self.y - self.sy*self.h/2, self.sx*self.w, self.sy*self.h, self.w/3, self.h/3)

    elseif self.sp == 'circle' then
        love.graphics.circle('line', self.x, self.y, self.sx*self.w)
    end
end
