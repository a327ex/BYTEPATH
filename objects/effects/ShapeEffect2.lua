ShapeEffect2 = GameObject:extend()

function ShapeEffect2:new(area, x, y, opts)
    ShapeEffect2.super.new(self, area, x, y, opts)

    self.w = 3*self.w
    self.h = self.w
    self.first = true
    self.second = false
    self.shape = nil
    self.sp = opts.shape

    self.timer:after(0.2, function()
        self.first = false
        self.second = true
        self.timer:after(0.35, function()
            self.second = false
        end)
    end)

    self.timer:after(0.2, function()
        self.timer:every(0.05, function() self.disappear = not self.disappear end, 6)
        self.timer:after(0.35, function() self.disappear = false end)
    end)
end

function ShapeEffect2:update(dt)
    ShapeEffect2.super.update(self, dt)
end

function ShapeEffect2:draw()
    if self.disappear then return end

    if self.first then
        love.graphics.setColor(default_color)
        self:drawShape()
    elseif self.second then
        love.graphics.setColor(self.color)
        self:drawShape()
    end
end

function ShapeEffect2:destroy()
    ShapeEffect2.super.destroy(self)
end

function ShapeEffect2:drawShape()
    if self.sp == 'rhombus' then
        draft:rhombus(self.x, self.y, self.w, self.h, 'fill')

    elseif self.sp == 'bsgrectangle' then
        BSGRectangle('fill', self.x - self.w/2, self.y - self.h/2, self.w, self.h, self.w/3, self.h/3)

    elseif self.sp == 'health' then
        love.graphics.rectangle('fill', self.x - self.w/2, self.y - self.h/6, self.w, 2*self.h/6)
        love.graphics.rectangle('fill', self.x - self.w/6, self.y - self.h/2, 2*self.w/6, self.h)
    end
end
