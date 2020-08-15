LightningLine = GameObject:extend()

function LightningLine:new(area, x, y, opts)
    LightningLine.super.new(self, area, x, y, opts)

    self.lines = {}
    self.x, self.y = (self.x1+self.x2)/2, (self.y1+self.y2)/2
    table.insert(self.lines, {x1 = self.x1, y1 = self.y1, x2 = self.x2, y2 = self.y2})
    self.generations = opts.generations or 4
    self.max_offset = opts.max_offset or 8
    self:generate()
    self.duration = opts.duration or 0.15
    self.alpha = 255
    self.timer:tween(self.duration, self, {alpha = 0}, 'in-out-cubic', function() self.dead = true end)
end

function LightningLine:update(dt)
    LightningLine.super.update(self, dt)
end

function LightningLine:generate()
    local offset_amount = self.max_offset
    local lines = self.lines

    for j = 1, self.generations do
        for i = #lines, 1, -1 do
            local start_point_x, start_point_y = lines[i].x1, lines[i].y1
            local end_point_x, end_point_y = lines[i].x2, lines[i].y2
            table.remove(lines, i)

            local mid_point_x, mid_point_y = (start_point_x + end_point_x)/2, (start_point_y + end_point_y)/2
            local pnx, pny = Vector.perpendicular(Vector.normalize(end_point_x - start_point_x, end_point_y - start_point_y))
            mid_point_x = mid_point_x + pnx*random(-offset_amount, offset_amount)
            mid_point_y = mid_point_y + pny*random(-offset_amount, offset_amount)
            table.insert(lines, {x1 = start_point_x, y1 = start_point_y, x2 = mid_point_x, y2 = mid_point_y})
            table.insert(lines, {x1 = mid_point_x, y1 = mid_point_y, x2 = end_point_x, y2 = end_point_y})
        end
        offset_amount = offset_amount/2
    end
end

function LightningLine:draw()
    for i, line in ipairs(self.lines) do 
        local r, g, b = unpack(self.color or boost_color)
        love.graphics.setColor(r, g, b, self.alpha)
        love.graphics.setLineWidth(2.5)
        love.graphics.line(line.x1, line.y1, line.x2, line.y2) 

        local r, g, b = unpack(default_color)
        love.graphics.setColor(r, g, b, self.alpha)
        love.graphics.setLineWidth(1.5)
        love.graphics.line(line.x1, line.y1, line.x2, line.y2) 
    end
    love.graphics.setLineWidth(1)
    love.graphics.setColor(255, 255, 255, 255)
end

function LightningLine:destroy()
    LightningLine.super.destroy(self)
end
