Node = Object:extend()

function Node:new(id, x, y)
    self.id = id
    self.x, self.y = x, y
    self.w, self.h = 12, 12
    self.hot = false
    self.bought = false
end

function Node:update(dt)
    local mx, my = camera:getMousePosition(sx*camera.scale, sy*camera.scale, 0, 0, sx*gw, sy*gh)
    if mx >= self.x - self.w and mx <= self.x + self.w and my >= self.y - self.h and my <= self.y + self.h then self.hot = true
    else self.hot = false end

    if self.hot and input:pressed('left_click') then
        if current_room:canNodeBeBought(self.id) then
            if not fn.any(bought_node_indexes, self.id) then
                table.insert(bought_node_indexes, self.id)
            end
        end
    end

    if fn.any(bought_node_indexes, self.id) then self.bought = true
    else self.bought = false end
end

function Node:draw()
    local r, g, b = unpack(default_color)
    love.graphics.setColor(background_color)
    love.graphics.circle('fill', self.x, self.y, self.w)
    if self.bought then love.graphics.setColor(r, g, b, 255)
    else love.graphics.setColor(r, g, b, 32) end
    love.graphics.circle('line', self.x, self.y, self.w)
    love.graphics.setColor(r, g, b, 255)
end
