Node = Object:extend()

function Node:new(id, x, y, size)
    self.id = id
    self.x, self.y = x, y
    self.size = size or 1
    self.timer = Timer()

    self.font = fonts.Anonymous_8
    self.hot = false
    self.previous_hot = false
    self.enter_hot = false
    self.exit_hot = false
    self.bought = false
    self.can_be_bought = false
    self.selected = false
    local r, g, b = unpack(default_color)
    self.color = {r, g, b, 32}
    self.types = tree[self.id].types
    self.colors = {}
    for _, t in ipairs(self.types) do table.insert(self.colors, types[t][2]) end
    local text = ''
    for _, t in ipairs(self.types) do text = text .. types[t][1] end
    self.tw = self.font:getWidth(text)
    local text = {}
    for _, t in ipairs(self.types) do table.insert(text, types[t][2]); table.insert(text, types[t][1]) end
    self.text = love.graphics.newText(self.font, text)

    self.cost = {1, 3, 6}
    self:updateStatus()
    self.stats_rectangle_sx, self.stats_rectangle_sy = 0, 0
end

function Node:update(dt)
    local cx, cy = camera:getCameraCoords(self.x, self.y, 0, 0, gw, gh)
    if cx < -40 or cx > gw + 40 then return end
    if cy < -40 or cy > gh + 40 then return end

    self.timer:update(dt)

    local mx, my = camera:getMousePosition(sx*camera.scale, sy*camera.scale, 0, 0, sx*gw, sy*gh)
    if self.size == 1 then
        if mx >= self.x - 8 and mx <= self.x + 8 and my >= self.y - 8 and my <= self.y + 8 then self.hot = true
        else self.hot = false end
    elseif self.size == 2 then
        if mx >= self.x - 16 and mx <= self.x + 16 and my >= self.y - 16 and my <= self.y + 16 then self.hot = true
        else self.hot = false end
    elseif self.size == 3 then
        if mx >= self.x - 24 and mx <= self.x + 24 and my >= self.y - 24 and my <= self.y + 24 then self.hot = true
        else self.hot = false end
    end

    if self.hot and not self.previous_hot then self.enter_hot = true
    else self.enter_hot = false end
    if not self.hot and self.previous_hot then self.exit_hot = true
    else self.exit_hot = false end

    if self.enter_hot then self:enterHot() end
    if self.exit_hot then self:exitHot() end

    if ((self.hot and input:pressed('left_click')) or (self.id == current_room.selected_kb_node_id and input:pressed('kb_enter'))) and not current_room.bought_nodes_this_frame then
        if current_room.temporary_bought_node_indexes and fn.any(current_room.temporary_bought_node_indexes, self.id) then
            current_room:glitch(self.x, self.y)
            local index = table.find(bought_node_indexes, self.id)
            for i = #bought_node_indexes, index, -1 do 
                local id = bought_node_indexes[i]
                table.remove(bought_node_indexes, i) 
                current_room.nodes[id]:updateStatus()
            end
            -- table.remove(bought_node_indexes, table.find(bought_node_indexes, self.id))
            local index = table.find(current_room.temporary_bought_node_indexes, self.id)
            for i = #current_room.temporary_bought_node_indexes, index, -1 do 
                local id = current_room.temporary_bought_node_indexes[i]
                table.remove(current_room.temporary_bought_node_indexes, i) 
                current_room.nodes[id]:updateStatus()
                current_room.skill_points_to_buy = current_room.skill_points_to_buy - self.cost[current_room.nodes[id].size]
            end
            -- table.remove(current_room.temporary_bought_node_indexes, table.find(current_room.temporary_bought_node_indexes, self.id))
            self:updateStatus()
            current_room:updateCanBeBoughtNodes()
            -- current_room.skill_points_to_buy = current_room.skill_points_to_buy - self.cost[self.size]
            if #current_room.temporary_bought_node_indexes <= 0 then current_room.buying = false end
            playMenuBack()
        else
            if current_room.canNodeBeBought and current_room:canNodeBeBought(self.id) then
                -- Add node
                if not fn.any(bought_node_indexes, self.id) then
                    current_room:rgbShift()
                    table.insert(bought_node_indexes, self.id)
                    table.insert(current_room.temporary_bought_node_indexes, self.id)
                    self:updateStatus()
                    current_room:updateCanBeBoughtNodes()
                    current_room.buying = true
                    current_room.skill_points_to_buy = current_room.skill_points_to_buy + self.cost[self.size]
                    playMenuClick()

                -- Remove node
                elseif not current_room.buying then
                    local bought_neighbors = current_room:getBoughtNeighbors(self.id)
                    local cant_be_removed = false
                    for _, bought_neighbor_id in ipairs(bought_neighbors) do
                        if not current_room:isNodeReachableWithout(bought_neighbor_id, self.id) then
                            cant_be_removed = true
                            break
                        end
                    end

                    if not cant_be_removed and self.id ~= 1 then
                        current_room:glitch(self.x, self.y)
                        table.remove(bought_node_indexes, table.find(bought_node_indexes, self.id))
                        self:updateStatus()
                        current_room:updateCanBeBoughtNodes()
                        playMenuBack()
                    end
                    -- if current_room:getNumberOfBoughtNeighbors(self.id) <= 1 and self.id ~= 1 then
                end
            end
        end
    end

    local r, g, b = unpack(default_color)
    if self.bought then self.color = {r, g, b, 255}
    elseif self.selected then self.color = {r/1.5, g/1.5, b/1.5, 255}
    else self.color = {r/2, g/2, b/2, 255} end
    self.previous_hot = self.hot
end

function Node:draw()
    local cx, cy = camera:getCameraCoords(self.x, self.y, 0, 0, gw, gh)
    if cx < -40 or cx > gw + 40 then return end
    if cy < -40 or cy > gh + 40 then return end

    if self.size == 1 then
        love.graphics.setColor(background_color)
        love.graphics.rectangle('fill', self.x - 8, self.y - 8, 16, 16)
        love.graphics.setLineWidth(1/camera.scale)
        love.graphics.setColor(self.color)
        love.graphics.rectangle('line', self.x - 8, self.y - 8, 16, 16)
        local r, g, b = unpack(default_color)
        love.graphics.setColor(r, g, b, 48)
        if self.can_be_bought then love.graphics.rectangle('line', self.x - 6, self.y - 6, 12, 12) end
        love.graphics.setColor(r, g, b, 255)
        love.graphics.setLineWidth(1)
        love.graphics.draw(self.text, math.floor(self.x - self.tw/2), math.floor(self.y), 0, 1, 1, 0, math.floor(self.font:getHeight()/2))
        -- love.graphics.print(self.id, self.x + 8, self.y - 16)
    elseif self.size == 2 then
        love.graphics.setColor(background_color)
        love.graphics.rectangle('fill', self.x - 16, self.y - 16, 32, 32)
        love.graphics.setColor(self.color)
        love.graphics.setLineWidth(2/camera.scale)
        love.graphics.rectangle('line', self.x - 16, self.y - 16, 32, 32)
        love.graphics.setLineWidth(1/camera.scale)
        local r, g, b = unpack(default_color)
        love.graphics.setColor(r, g, b, 48)
        if self.can_be_bought then love.graphics.rectangle('line', self.x - 12, self.y - 12, 25, 25) end
        love.graphics.setColor(r, g, b, 255)
        love.graphics.setLineWidth(1)
        love.graphics.draw(self.text, math.floor(self.x - self.tw/2), math.floor(self.y), 0, 1, 1, 0, math.floor(self.font:getHeight()/2))
        -- love.graphics.print(self.id, self.x + 16, self.y - 16)
    elseif self.size == 3 then
        love.graphics.setColor(background_color)
        love.graphics.rectangle('fill', self.x - 24, self.y - 24, 48, 48)
        love.graphics.setColor(self.color)
        love.graphics.setLineWidth(2.5/camera.scale)
        love.graphics.rectangle('line', self.x - 24, self.y - 24, 48, 48)
        love.graphics.setLineWidth(1/camera.scale)
        love.graphics.setColor(default_color)
        local r, g, b = unpack(default_color)
        love.graphics.setColor(r, g, b, 48)
        if self.can_be_bought then love.graphics.rectangle('line', self.x - 20, self.y - 20, 41, 41) end
        love.graphics.setColor(r, g, b, 255)
        love.graphics.setLineWidth(1)
        love.graphics.draw(self.text, math.floor(self.x - self.tw/2), math.floor(self.y), 0, 1, 1, 0, math.floor(self.font:getHeight()/2))
        -- love.graphics.print(self.id, self.x + 24, self.y - 16)
    end
    love.graphics.setColor(255, 255, 255, 255)
end

function Node:updateStatus()
    if fn.any(bought_node_indexes, self.id) then self.bought = true
    else self.bought = false end
end

function Node:enterHot()
    self.timer:tween('stats', 0.075, self, {stats_rectangle_sx = 1, stats_rectangle_sy = 1}, 'in-out-cubic', function() self.exiting_hot = false end)
    self.timer:every('blink', 0.035, function() self.visible = not self.visible end, 3)
    self.timer:after('visible', 0.035*3 + 0.02, function() self.visible = true end)
end

function Node:exitHot()
    self.timer:cancel('blink')
    self.timer:cancel('visible')
    self.exiting_hot = true
    self.visible = true
    self.timer:tween('stats', 0.075, self, {stats_rectangle_sx = 0, stats_rectangle_sy = 0}, 'in-out-cubic', function() self.exiting_hot = false end)
end

