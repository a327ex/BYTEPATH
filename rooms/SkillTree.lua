SkillTree = Object:extend()

function SkillTree:new()
    self.timer = Timer()
    self.area = Area(self)

    self.font = fonts.Anonymous_8
    self.main_canvas = love.graphics.newCanvas(gw, gh)
    self.final_canvas = love.graphics.newCanvas(gw, gh)
    self.temp_canvas = love.graphics.newCanvas(gw, gh)
    self.glitch_canvas = love.graphics.newCanvas(gw, gh)
    self.rgb_canvas = love.graphics.newCanvas(gw, gh)
    self.rgb_shift_mag = 0

    self.nodes = {}
    self.lines = {}
    self.tree = table.copy(tree)

    camera:lookAt(32, 96)

    -- Create nodes and links
    for id, node in pairs(self.tree) do self.nodes[id] = Node(id, node.x, node.y, node.size) end
    for id, node in pairs(self.tree) do 
        for _, linked_node_id in ipairs(node.links or {}) do
            table.insert(self.lines, Line(self.nodes, id, linked_node_id))
        end
    end

    -- Keyboard tree movement
    for id, current_node in pairs(self.tree) do
        for _, linked_node_id in ipairs(current_node.links or {}) do
            if not self.nodes[id].link_directions then self.nodes[id].link_directions = {} end
            local current_node = self.nodes[id]
            local other_node = self.nodes[linked_node_id]
            local dx, dy = current_node.x - other_node.x, current_node.y - other_node.y
            local direction
            if math.abs(dx) <= 0.01 and dy > 0 then direction = 'up' end
            if math.abs(dx) <= 0.01 and dy < 0 then direction = 'down' end
            if math.abs(dy) <= 0.01 and dx > 0 then direction = 'left' end
            if math.abs(dy) <= 0.01 and dx < 0 then direction = 'right' end
            if dx > 0 and dy > 0 then direction = 'left-up' end
            if dx < 0 and dy > 0 then direction = 'right-up' end
            if dx > 0 and dy < 0 then direction = 'left-down' end
            if dx < 0 and dy < 0 then direction = 'right-down' end
            if direction then self.nodes[id].link_directions[direction] = linked_node_id end
        end
    end

    self.moving_with_kb = true
    self.selected_kb_node_id = 1
    self.keys_alpha = 255
    self.timer:after(10, function() self.timer:tween(5, self, {keys_alpha = 0}, 'in-out-cubic') end)

    self:updateCanBeBoughtNodes()
    self.buying = false
    self.refunding = false
    self.skill_points_to_buy = 0
    self.temporary_bought_node_indexes = {}

    input:unbindAll()
    input:bind('a', 'left')
    input:bind('d', 'right')
    input:bind('w', 'up')
    input:bind('s', 'down')
    input:bind('left', 'left')
    input:bind('right', 'right')
    input:bind('up', 'up')
    input:bind('down', 'down')
    input:bind('mouse1', 'left_click')
    input:bind('wheelup', 'zoom_in')
    input:bind('wheeldown', 'zoom_out')
    input:bind('r1', 'zoom_in')
    input:bind('l1', 'zoom_out')
    input:bind('q', 'kb_zoom_in')
    input:bind('e', 'kb_zoom_out')
    input:bind('return', 'return')
    input:bind('backspace', 'backspace')
    input:bind('escape', 'escape')
    input:bind('dpleft', 'left')
    input:bind('dpright', 'right')
    input:bind('dpup', 'up')
    input:bind('dpdown', 'down')
    input:bind('start', 'return')
    input:bind('fright', 'escape')
    input:bind('fdown', 'return')
    input:bind('fleft', 'return')
    input:bind('fup', 'escape')
    input:bind('select', 'escape')
    input:bind('tab', 'tab')

    input:bind('fleft', 'kb_enter')
    input:bind('return', 'kb_enter')
    input:bind('fdown', 'kb_cancel')
    input:bind('c', 'kb_cancel')
    input:bind('start', 'kb_apply')
    input:bind('k', 'kb_apply')

    self.timer:every(0.2, function() 
        self.area:addGameObject('GlitchDisplacement') 
        self.area:addGameObject('RGBShift') 
    end)

    self.stats_rectangle_sx, self.stats_rectangle_sy = 0, 0
end

function SkillTree:update(dt)
    self.timer:update(dt)
    self.area:update(dt)
    camera.smoother = Camera.smooth.damped(10)

    if self.moving_with_kb then
        local node = self.nodes[self.selected_kb_node_id]
        camera:lockPosition(dt, node.x, node.y)

        local changeSelectedNode = function(linked_node_id)
            self.selected_kb_node_id = linked_node_id
            self.nodes[self.selected_kb_node_id]:enterHot()
        end

        local delay = 0.040
        for direction, linked_node_id in pairs(node.link_directions) do 
            if direction == 'left-up' and ((input:pressed('left') and input:pressed('up')) or (input:sequence('left', delay, 'up') or input:sequence('up', delay, 'left'))) then 
                self.timer:cancel('kb_left')
                self.timer:cancel('kb_up')
                changeSelectedNode(linked_node_id)
                goto continue
            elseif direction == 'left-down' and ((input:pressed('left') and input:pressed('down')) or (input:sequence('left', delay, 'down') or input:sequence('down', delay, 'left'))) then 
                self.timer:cancel('kb_left')
                self.timer:cancel('kb_down')
                changeSelectedNode(linked_node_id)
                goto continue
            elseif direction == 'right-up' and ((input:pressed('right') and input:pressed('up')) or (input:sequence('right', delay, 'up') or input:sequence('up', delay, 'right'))) then 
                self.timer:cancel('kb_right')
                self.timer:cancel('kb_up')
                changeSelectedNode(linked_node_id)
                goto continue
            elseif direction == 'right-down' and ((input:pressed('right') and input:pressed('down')) or (input:sequence('right', delay, 'down') or input:sequence('down', delay, 'right'))) then 
                self.timer:cancel('kb_right')
                self.timer:cancel('kb_down')
                changeSelectedNode(linked_node_id)
                goto continue
            end
        end

        for direction, linked_node_id in pairs(node.link_directions) do 
            if direction == 'left' and input:pressed('left') then self.timer:after('kb_left', delay, function() changeSelectedNode(linked_node_id) end); goto continue
            elseif direction == 'right' and input:pressed('right') then self.timer:after('kb_right', delay, function() changeSelectedNode(linked_node_id) end); goto continue
            elseif direction == 'up' and input:pressed('up') then self.timer:after('kb_up', delay, function() changeSelectedNode(linked_node_id) end); goto continue
            elseif direction == 'down' and input:pressed('down') then self.timer:after('kb_down', delay, function() changeSelectedNode(linked_node_id) end); goto continue end
        end
        
        for direction, linked_node_id in pairs(node.link_directions) do 
            if direction == 'left-up' and input:pressed('left') then self.timer:after('kb_left', delay, function() changeSelectedNode(linked_node_id) end)
            elseif direction == 'left-up' and input:pressed('up') then self.timer:after('kb_up', delay, function() changeSelectedNode(linked_node_id) end)
            elseif direction == 'left-down' and input:pressed('left') then self.timer:after('kb_left', delay, function() changeSelectedNode(linked_node_id) end)
            elseif direction == 'left-down' and input:pressed('down') then self.timer:after('kb_down', delay, function() changeSelectedNode(linked_node_id) end)
            elseif direction == 'right-up' and input:pressed('right') then self.timer:after('kb_right', delay, function() changeSelectedNode(linked_node_id) end)
            elseif direction == 'right-up' and input:pressed('up') then self.timer:after('kb_up', delay, function() changeSelectedNode(linked_node_id) end)
            elseif direction == 'right-down' and input:pressed('right') then self.timer:after('kb_right', delay, function() changeSelectedNode(linked_node_id) end)
            elseif direction == 'right-down' and input:pressed('down') then self.timer:after('kb_down', delay, function() changeSelectedNode(linked_node_id) end) end
        end

        ::continue::
    end

    if input:pressed('left') or input:pressed('right') or input:pressed('up') or input:pressed('down') or input:pressed('kb_zoom_in') or input:pressed('kb_zoom_out') or input:pressed('kb_enter') or input:pressed('kb_apply') or input:pressed('kb_cancel') then
        self.moving_with_kb = true
    end

    if input:down('left_click') then
        self.moving_with_kb = false
        local mx, my = camera:getMousePosition(sx, sy, 0, 0, sx*gw, sy*gh)
        local dx, dy = mx - self.previous_mx, my - self.previous_my
        camera:move(-dx/camera.scale, -dy/camera.scale)
        camera.x, camera.y = math.floor(camera.x), math.floor(camera.y)
    end
    self.previous_mx, self.previous_my = camera:getMousePosition(sx, sy, 0, 0, sx*gw, sy*gh)

    if input:pressed('zoom_in') or input:pressed('kb_zoom_in') then self.timer:tween('zoom', 0.2, camera, {scale = camera.scale + 0.1}, 'in-out-cubic') end
    if input:pressed('zoom_out') or input:pressed('kb_zoom_out') then self.timer:tween('zoom', 0.2, camera, {scale = camera.scale - 0.1}, 'in-out-cubic') end
    camera.scale = math.max(0.2, camera.scale) 

    -- Console
    local pmx, pmy = love.mouse.getPosition()
    local text = 'CONSOLE'
    local w = self.font:getWidth(text)
    local x, y = gw - w - 15, 5
    if (pmx >= sx*x and pmx <= sx*(x + w + 10) and pmy >= sy*y and pmy <= sy*(y + 16) and input:pressed('left_click')) or input:pressed('escape') then
        self:cancel()
        playMenuBack()
        gotoRoom('Console')
    end

    -- Apply, cancel buttons
    self.bought_nodes_this_frame = false
    if self.buying then
        local pmx, pmy = love.mouse.getPosition()
        -- Apply
        local text = 'Apply ' .. self.skill_points_to_buy .. ' Skill Points'
        local w = self.font:getWidth(text)
        local x, y = 5, gh - 20
        if (pmx >= sx*x and pmx <= sx*(x + w + 10) and pmy >= sy*y and pmy <= sy*(y + 16) and input:pressed('left_click')) or input:pressed('kb_apply') then
            if self.skill_points_to_buy <= skill_points and #bought_node_indexes <= max_tree_nodes then
                skill_points = skill_points - self.skill_points_to_buy
                spent_sp = spent_sp + self.skill_points_to_buy
                self.skill_points_to_buy = 0
                self.buying = false
                self.temporary_bought_node_indexes = {}
                playMenuSelect()
                self:rgbShift()
                self.bought_nodes_this_frame = true
            else
                if #bought_node_indexes > max_tree_nodes then
                    self.cant_buy_error = 'CANT HAVE MORE THAN ' .. max_tree_nodes .. ' NODES'
                    self.timer:after(0.5, function() self.cant_buy_error = false end)
                    self:cancel()
                    playMenuError()
                    self:glitchError()
                else
                    self.cant_buy_error = 'NOT ENOUGH SKILL POINTS'
                    self.timer:after(0.5, function() self.cant_buy_error = false end)
                    self:cancel()
                    playMenuError()
                    self:glitchError()
                end
            end
        end

        -- Cancel
        local x = x + w + 10 + 5
        local text = 'Cancel'
        local w = self.font:getWidth(text)
        if (pmx >= sx*x and pmx <= sx*(x + w + 10) and pmy >= sy*y and pmy <= sy*(y + 16) and input:pressed('left_click')) or input:pressed('kb_cancel') then 
            playMenuBack()
            self:cancel()
        end
    end

    for _, node in pairs(self.nodes) do node:update(dt) end
    for _, line in pairs(self.lines) do line:update(dt) end
end

function SkillTree:draw()
    love.graphics.setCanvas(self.glitch_canvas)
    love.graphics.clear()
        love.graphics.setColor(127, 127, 127)
        love.graphics.rectangle('fill', 0, 0, gw, gh)
        love.graphics.setColor(255, 255, 255)
        self.area:drawOnly({'glitch'})
    love.graphics.setCanvas()

    love.graphics.setCanvas(self.main_canvas)
    love.graphics.clear()
        camera:attach(0, 0, gw, gh)

        -- Draw grid
        local grid_w, grid_h = 18000, 18000
        local grid_node_w, grid_node_h = 12, 12
        local grid_cluster_size = 5
        love.graphics.setColor(255, 255, 255, 4)
        love.graphics.line(0, -grid_h/2, 0, grid_h/2)
        local n_grid_w, n_grid_h = (grid_w/2)/grid_node_w, (grid_h/2)/grid_node_h
        local n_big_grid_w, n_big_grid_h = (grid_w/2)/(grid_cluster_size*grid_node_w), (grid_h/2)/(grid_cluster_size*grid_node_h)
        for i = 1, n_big_grid_w do
            love.graphics.line(0 - grid_cluster_size*grid_node_w*i, -grid_h/2, 0 - grid_cluster_size*grid_node_w*i, grid_h/2)
            love.graphics.line(0 + grid_cluster_size*grid_node_w*i, -grid_h/2, 0 + grid_cluster_size*grid_node_w*i, grid_h/2)
        end
        love.graphics.setColor(255, 255, 255, 2)
        for i = 1, n_grid_w do
            love.graphics.line(0 - grid_node_w*i, -grid_h/2, 0 - grid_node_w*i, grid_h/2)
            love.graphics.line(0 + grid_node_w*i, -grid_h/2, 0 + grid_node_w*i, grid_h/2)
        end
        love.graphics.setColor(255, 255, 255, 4)
        love.graphics.line(-grid_w/2, 0, grid_w/2, 0)
        for i = 1, n_big_grid_h do
            love.graphics.line(-grid_w/2, 0 - grid_cluster_size*grid_node_h*i, grid_w/2, 0 - grid_cluster_size*grid_node_h*i)
            love.graphics.line(-grid_w/2, 0 + grid_cluster_size*grid_node_h*i, grid_w/2, 0 + grid_cluster_size*grid_node_h*i)
        end
        love.graphics.setColor(255, 255, 255, 2)
        for i = 1, n_grid_h do
            love.graphics.line(-grid_w/2, 0 - grid_node_h*i, grid_w/2, 0 - grid_node_h*i)
            love.graphics.line(-grid_w/2, 0 + grid_node_h*i, grid_w/2, 0 + grid_node_h*i)
        end

        -- Draw nodes and lines
        love.graphics.setLineWidth(1/camera.scale)
        for _, line in pairs(self.lines) do line:draw() end
        for _, node in pairs(self.nodes) do node:draw() end
        love.graphics.setLineWidth(1)
        camera:detach()

        -- Skill points
        love.graphics.setColor(skill_point_color)
        love.graphics.print(skill_points .. 'SP', gw - 20, 28, 0, 1, 1, math.floor(self.font:getWidth(skill_points .. 'SP')/2), math.floor(self.font:getHeight()/2))

        -- Nodes
        if #bought_node_indexes > max_tree_nodes then love.graphics.setColor(hp_color)
        else love.graphics.setColor(default_color) end
        love.graphics.print(#bought_node_indexes .. '/' .. max_tree_nodes .. ' NODES BOUGHT', 10, 20, 0, 1, 1, 0, math.floor(self.font:getHeight()/2))

        -- Keys
        local r, g, b = unpack(background_color)
        love.graphics.setColor(r, g, b, self.keys_alpha)
        love.graphics.rectangle('fill', 10, gh - 15 - 3 - 18, 18, 18)
        love.graphics.rectangle('fill', 10 + 18 + 3, gh - 15 - 3 - 18, 18, 18)
        love.graphics.rectangle('fill', 10 + 36 + 6, gh - 15 - 3 - 18, 18, 18)
        love.graphics.rectangle('fill', 10 + 18 + 3, gh - 15 - 6 - 36, 18, 18)
        love.graphics.rectangle('fill', 10 + 36 + 6, gh - 15 - 6 - 36, 18, 18)
        love.graphics.rectangle('fill', 10, gh - 15 - 6 - 36, 18, 18)
        love.graphics.rectangle('fill', 10 + 36 + 6 + 18 + 3, gh - 15 - 3 - 18, 32, 18)

        local r, g, b = unpack(default_color)
        love.graphics.setColor(r, g, b, self.keys_alpha)
        love.graphics.rectangle('line', 10, gh - 15 - 3 - 18, 18, 18)
        love.graphics.rectangle('line', 10 + 18 + 3, gh - 15 - 3 - 18, 18, 18)
        love.graphics.rectangle('line', 10 + 36 + 6, gh - 15 - 3 - 18, 18, 18)
        love.graphics.rectangle('line', 10 + 18 + 3, gh - 15 - 6 - 36, 18, 18)
        love.graphics.rectangle('line', 10 + 36 + 6, gh - 15 - 6 - 36, 18, 18)
        love.graphics.rectangle('line', 10, gh - 15 - 6 - 36, 18, 18)
        love.graphics.rectangle('line', 10 + 36 + 6 + 18 + 3, gh - 15 - 3 - 18, 32, 18)

        pushRotate(10 + 9, gh - 15 - 3 - 9, -math.pi/2)
        draft:triangleEquilateral(10 + 9, gh - 15 - 3 - 9, 9, 'fill')
        love.graphics.pop()
        pushRotate(10 + 9 + 3 + 18, gh - 15 - 3 - 9, math.pi)
        draft:triangleEquilateral(10 + 9 + 3 + 18, gh - 15 - 3 - 9, 9, 'fill')
        love.graphics.pop()
        pushRotate(10 + 9 + 3 + 18 + 3 + 18, gh - 15 - 3 - 9, math.pi/2)
        draft:triangleEquilateral(10 + 9 + 3 + 18 + 3 + 18, gh - 15 - 3 - 9, 9, 'fill')
        love.graphics.pop()
        draft:triangleEquilateral(10 + 9 + 3 + 18, gh - 15 - 3 - 9 - 18 - 3, 9, 'fill')

        local font = love.graphics.getFont()
        love.graphics.print('Q', 10 + 9, gh - 15 - 6 - 36 + 9, 0, 1, 1, math.floor(font:getWidth('Q')/2), math.floor(font:getHeight()/2))
        love.graphics.print('E', 10 + 36 + 6 + 9, gh - 15 - 6 - 36 + 9, 0, 1, 1, math.floor(font:getWidth('E')/2), math.floor(font:getHeight()/2))
        love.graphics.print('ENTER', 10 + 36 + 6 + 18 + 3 + 16, gh - 15 - 6 - 18 + 9 + 3, 0, 1, 1, math.floor(font:getWidth('ENTER')/2), math.floor(font:getHeight()/2))
        love.graphics.print('ZOOMIN', 10 + 9, gh - 15 - 6 - 36 - 9, 0, 1, 1, math.floor(font:getWidth('ZOOMIN')/2), math.floor(font:getHeight()/2))
        love.graphics.print('ZOOMOUT', 10 + 36 + 6 + 9, gh - 15 - 6 - 36 - 9, 0, 1, 1, math.floor(font:getWidth('ZOOMOUT')/2), math.floor(font:getHeight()/2))

        love.graphics.setColor(255, 255, 255, 255)

        -- Can't buy
        if self.cant_buy_error then
            local text = self.cant_buy_error
            local w = self.font:getWidth(text)
            local x, y = gw/2 - w/2 - 5, gh/2 - 12
            love.graphics.setColor(hp_color)
            love.graphics.rectangle('fill', x, y, w + 10, 24)
            love.graphics.setColor(background_color)
            love.graphics.print(text, math.floor(x + 5), math.floor(y + 8))
        end

        -- Console button
        local pmx, pmy = love.mouse.getPosition()
        local text = 'CONSOLE'
        local w = self.font:getWidth(text)
        local x, y = gw - w - 15, 5
        love.graphics.setColor(0, 0, 0, 222)
        love.graphics.rectangle('fill', x, y, w + 10, 16) 
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.print(text, x + 5, y + 3)
        if pmx >= sx*x and pmx <= sx*(x + w + 10) and pmy >= sy*y and pmy <= sy*(y + 16) then love.graphics.rectangle('line', x, y, w + 10, 16) end

        -- Confirm/cancel buttons
        if self.buying then
            local pmx, pmy = love.mouse.getPosition()
            local text = 'Apply ' .. self.skill_points_to_buy .. ' Skill Points'
            local w = self.font:getWidth(text)

            local x, y = 5, gh - 20
            love.graphics.setColor(0, 0, 0, 222)
            love.graphics.rectangle('fill', x, y, w + 10, 16) 
            love.graphics.setColor(255, 255, 255, 255)
            love.graphics.print(text, x + 5, y + 3)
            if pmx >= sx*x and pmx <= sx*(x + w + 10) and pmy >= sy*y and pmy <= sy*(y + 16) then love.graphics.rectangle('line', x, y, w + 10, 16) end

            local x = x + w + 10 + 5
            local text = 'Cancel'
            local w = self.font:getWidth(text)
            love.graphics.setColor(0, 0, 0, 222)
            love.graphics.rectangle('fill', x, y, w + 10, 16) 
            love.graphics.setColor(255, 255, 255, 255)
            love.graphics.print(text, x + 5, y + 3)
            if pmx >= sx*x and pmx <= sx*(x + w + 10) and pmy >= sy*y and pmy <= sy*(y + 16) then love.graphics.rectangle('line', x, y, w + 10, 16) end

            love.graphics.line(x - 65, y + 13, x - 65 + 5, y + 13) -- K
            love.graphics.line(x + 5, y + 13, x + 5 + 5, y + 13) -- C
        end

        -- Stats rectangle
        local font = self.font
        love.graphics.setFont(font)
        for id, node in pairs(self.nodes) do
            if ((node.hot or node.exiting_hot) and node.visible) or (self.moving_with_kb and id == self.selected_kb_node_id) then
                local stats = self.tree[node.id].stats or {}
                -- Figure out max_text_width to be able to set the proper rectangle width
                local max_text_width = 0
                for i = 1, #stats, 3 do
                    if font:getWidth(stats[i]) > max_text_width then
                        max_text_width = font:getWidth(stats[i])
                    end
                end
                max_text_width = max_text_width + 24
                -- Draw rectangle
                local mx, my = love.mouse.getPosition() 
                if self.moving_with_kb then 
                    mx, my = camera:getCameraCoords(node.x, node.y) 
                    mx = mx - 1.5*max_text_width
                    my = my + 48
                end

                mx, my = mx/sx, my/sy
                pushRotateScale(mx + (16 + max_text_width)/2, my + (font:getHeight() + (#stats/3)*font:getHeight())/2, 0, node.stats_rectangle_sx, node.stats_rectangle_sy)
                love.graphics.setColor(0, 0, 0, 222)
                love.graphics.rectangle('fill', mx, my, 16 + max_text_width, font:getHeight() + (#stats/3)*font:getHeight())
                love.graphics.setColor(skill_point_color)
                love.graphics.print(node.cost[node.size] .. 'SP', math.floor(mx + 16 + max_text_width - 16), math.floor(my + font:getHeight()), 
                0, 1, 1, math.floor(self.font:getWidth(node.cost[node.size] .. 'SP')/2), math.floor(self.font:getHeight()/2))
                -- Draw text
                love.graphics.setColor(default_color)
                for i = 1, #stats, 3 do
                    love.graphics.print(stats[i], math.floor(mx + 8), math.floor(my + font:getHeight()/2 + math.floor(i/3)*font:getHeight()))
                end
                love.graphics.pop()
            end
        end
        love.graphics.setColor(default_color)
    love.graphics.setCanvas()

    love.graphics.setCanvas(self.temp_canvas)
    love.graphics.clear()
        love.graphics.setColor(255, 255, 255)
        love.graphics.setBlendMode("alpha", "premultiplied")
        love.graphics.setShader(shaders.glitch)
        shaders.glitch:send('glitch_map', self.glitch_canvas)
        love.graphics.draw(self.main_canvas, 0, 0, 0, 1, 1)
        love.graphics.setShader()
  		love.graphics.setBlendMode("alpha")
    love.graphics.setCanvas()

    love.graphics.setCanvas(self.final_canvas)
    love.graphics.clear()
        love.graphics.setColor(255, 255, 255)
        love.graphics.setBlendMode("alpha", "premultiplied")
        love.graphics.setShader(shaders.rgb_shift)
        shaders.rgb_shift:send('amount', {random(-self.rgb_shift_mag, self.rgb_shift_mag)/gw, random(-self.rgb_shift_mag, self.rgb_shift_mag)/gh})
        love.graphics.draw(self.temp_canvas, 0, 0, 0, 1, 1)
        love.graphics.setShader()
  		love.graphics.setBlendMode("alpha")
    love.graphics.setCanvas()

    if not disable_expensive_shaders then
        love.graphics.setShader(shaders.distort)
        shaders.distort:send('time', time)
        shaders.distort:send('horizontal_fuzz', 0.2*(distortion/10))
        shaders.distort:send('rgb_offset', 0.2*(distortion/10))
    end
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.draw(self.final_canvas, 0, 0, 0, sx, sy)
    love.graphics.setBlendMode('alpha')
    love.graphics.setShader()
end

function SkillTree:destroy()
    
end

function SkillTree:canNodeBeBought(id)
    for _, linked_node_id in ipairs(self.tree[id].links) do
        if fn.any(bought_node_indexes, linked_node_id) then return true end
    end
end

function SkillTree:updateCanBeBoughtNodes()
    for _, node in pairs(self.nodes) do node.can_be_bought = false end

    for _, bought_node_index in ipairs(bought_node_indexes) do
        for _, linked_node_id in ipairs(self.tree[bought_node_index].links) do
            self.nodes[linked_node_id].can_be_bought = true
        end
    end

    for _, node in pairs(self.nodes) do 
        if node.bought then node.can_be_bought = false end
    end
end

function SkillTree:cancel()
    self.skill_points_to_buy = 0
    self.buying = false
    bought_node_indexes = fn.difference(bought_node_indexes, self.temporary_bought_node_indexes)
    self.temporary_bought_node_indexes = {} 
    for _, node in pairs(self.nodes) do node:updateStatus() end
    self:updateCanBeBoughtNodes()
end

function SkillTree:getNumberOfBoughtNeighbors(id)
    local n = 0
    for _, linked_node_id in ipairs(self.tree[id].links) do
        if fn.any(bought_node_indexes, linked_node_id) then
            n = n + 1
        end
    end
    return n
end

function SkillTree:getBoughtNeighbors(id)
    local bought_neighbors = {}
    for _, linked_node_id in ipairs(self.tree[id].links) do
        if fn.any(bought_node_indexes, linked_node_id) then
            table.insert(bought_neighbors, linked_node_id)
        end
    end
    return bought_neighbors
end

function SkillTree:isBoughtNeighbor(id, neighbor_id)
    for _, linked_node_id in ipairs(self.tree[id].links) do
        if fn.any(bought_node_indexes, linked_node_id) and linked_node_id == neighbor_id then
            return true
        end
    end
end

function SkillTree:isNodeReachableWithout(id, without_id)
    local bought_nodes_without_id = fn.select(bought_node_indexes, function(_, value) return value ~= without_id end)
    local result = self:reachNodeFrom(1, id, {}, table.copy(bought_nodes_without_id))
    return result
end

function SkillTree:reachNodeFrom(start_id, target_id, explored_nodes, node_pool)
    local stack = {}
    table.insert(stack, 1, start_id)
    local current_node = nil
    repeat
        current_node = table.remove(stack, 1)
        if not fn.any(explored_nodes, current_node) then
            table.insert(explored_nodes, current_node)
            for _, linked_node_id in ipairs(self.tree[current_node].links) do
                if fn.any(node_pool, linked_node_id) then
                    table.insert(stack, 1, linked_node_id)
                end
            end
        end
    until current_node == target_id or #stack == 0 
    if current_node == target_id then return true end
end

function SkillTree:rgbShift()
    self.rgb_shift_mag = random(2, 4)
    self.timer:tween('rgb_shift', 0.25, self, {rgb_shift_mag = 0}, 'in-out-cubic')
end

function SkillTree:glitch(x, y)
    for i = 1, 6 do
        self.timer:after(0.1*i, function()
            self.area:addGameObject('GlitchDisplacement', x + random(-32, 32), y + random(-32, 32)) 
        end)
    end
end

function SkillTree:glitchError()
    for i = 1, 10 do self.timer:after(0.1*i, function() self.area:addGameObject('GlitchDisplacement') end) end
    self.rgb_shift_mag = random(4, 8)
    self.timer:tween('rgb_shift', 1, self, {rgb_shift_mag = 0}, 'in-out-cubic')
end
