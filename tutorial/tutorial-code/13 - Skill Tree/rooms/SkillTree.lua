SkillTree = Object:extend()

function SkillTree:new()
    self.timer = Timer()

    self.font = fonts.m5x7_16
    self.main_canvas = love.graphics.newCanvas(gw, gh)

    self.nodes = {}
    self.lines = {}

    -- Bi-directional links
    self.tree = table.copy(tree)
    for id, node in ipairs(self.tree) do
        for _, linked_node_id in ipairs(node.links or {}) do
            table.insert(self.tree[linked_node_id], id)
        end
    end
    for id, node in ipairs(self.tree) do
        if node.links then
            node.links = fn.unique(node.links)
        end
    end

    -- Create nodes and links
    for id, node in ipairs(self.tree) do table.insert(self.nodes, Node(id, node.x, node.y)) end
    for id, node in ipairs(self.tree) do 
        for _, linked_node_id in ipairs(node.links or {}) do
            table.insert(self.lines, Line(self.tree, id, linked_node_id))
        end
    end

    bought_node_indexes = {1}
end

function SkillTree:update(dt)
    self.timer:update(dt)
    camera.smoother = Camera.smooth.damped(5)

    if input:down('left_click') then
        local mx, my = camera:getMousePosition(sx, sy, 0, 0, sx*gw, sy*gh)
        local dx, dy = mx - self.previous_mx, my - self.previous_my
        camera:move(-dx, -dy)
    end
    self.previous_mx, self.previous_my = camera:getMousePosition(sx, sy, 0, 0, sx*gw, sy*gh)

    if input:pressed('zoom_in') then self.timer:tween('zoom', 0.2, camera, {scale = camera.scale + 0.4}, 'in-out-cubic') end
    if input:pressed('zoom_out') then self.timer:tween('zoom', 0.2, camera, {scale = camera.scale - 0.4}, 'in-out-cubic') end

    for _, node in ipairs(self.nodes) do node:update(dt) end
    for _, line in ipairs(self.lines) do line:update(dt) end
end

function SkillTree:draw()
    love.graphics.setCanvas(self.main_canvas)
    love.graphics.clear()
        love.graphics.setColor(background_color)
        love.graphics.rectangle('fill', 0, 0, gw, gh)
        camera:attach(0, 0, gw, gh)
        love.graphics.setLineWidth(1/camera.scale)
        for _, line in ipairs(self.lines) do line:draw() end
        for _, node in ipairs(self.nodes) do node:draw() end
        love.graphics.setLineWidth(1)
        camera:detach()

        -- Stats rectangle
        local font = fonts.m5x7_16
        love.graphics.setFont(font)
        for _, node in ipairs(self.nodes) do
            if node.hot then
                local stats = self.tree[node.id].stats or {}
                -- Figure out max_text_width to be able to set the proper rectangle width
                local max_text_width = 0
                for i = 1, #stats, 3 do
                    if font:getWidth(stats[i]) > max_text_width then
                        max_text_width = font:getWidth(stats[i])
                    end
                end
                -- Draw rectangle
                local mx, my = love.mouse.getPosition() 
                mx, my = mx/sx, my/sy
                love.graphics.setColor(0, 0, 0, 222)
                love.graphics.rectangle('fill', mx, my, 16 + max_text_width, font:getHeight() + (#stats/3)*font:getHeight())
                -- Draw text
                love.graphics.setColor(default_color)
                for i = 1, #stats, 3 do
                    love.graphics.print(stats[i], math.floor(mx + 8), math.floor(my + font:getHeight()/2 + math.floor(i/3)*font:getHeight()))
                end
            end
        end
        love.graphics.setColor(default_color)
    love.graphics.setCanvas()

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.draw(self.main_canvas, 0, 0, 0, sx, sy)
    love.graphics.setBlendMode('alpha')
end

function SkillTree:destroy()
    
end

function SkillTree:canNodeBeBought(id)
    for _, linked_node_id in ipairs(self.tree[id]) do
        if fn.any(bought_node_indexes, linked_node_id) then return true end
    end
end
