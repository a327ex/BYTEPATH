Line = Object:extend()

function Line:new(nodes, node_1_id, node_2_id)
    self.node_1_id, self.node_2_id = node_1_id, node_2_id
    local findNode = function(nodes, id)
        for _, node in pairs(nodes) do
            if node.id == id then return node end
        end
    end
    self.node_1, self.node_2 = findNode(nodes, node_1_id), findNode(nodes, node_2_id)
    self.selected = false
    self.color = {128, 128, 128, 64}

    self.points = getPointsAlongLine(10, self.node_1.x, self.node_1.y, self.node_2.x, self.node_2.y)
end

function Line:update(dt)
    local cx, cy = camera:getCameraCoords((self.node_1.x + self.node_2.x)/2, (self.node_1.y + self.node_2.y)/2, 0, 0, gw, gh)
    if cx < -40 or cx > gw + 40 then return end
    if cy < -40 or cy > gh + 40 then return end

    if self.node_1.bought and self.node_2.bought then self.selected = true else self.selected = false end
    if self.selected then self.color = {255, 255, 255, 255}
    else self.color = {128, 128, 128, 64} end
end

function Line:draw()
    local cx, cy = camera:getCameraCoords((self.node_1.x + self.node_2.x)/2, (self.node_1.y + self.node_2.y)/2, 0, 0, gw, gh)
    if cx < -40 or cx > gw + 40 then return end
    if cy < -40 or cy > gh + 40 then return end

    love.graphics.setLineWidth(1/camera.scale)
    love.graphics.setColor(self.color)
    if self.node_1.bought and self.node_2.bought then love.graphics.setLineWidth(2.5/camera.scale) end
    for i = 1, #self.points do
        local point = self.points[i]
        local next_point = self.points[i+1]
        if next_point then love.graphics.line(point.x, point.y, next_point.x, next_point.y) end
    end
    -- love.graphics.line(self.node_1.x, self.node_1.y, self.node_2.x, self.node_2.y)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setLineWidth(1)
end
