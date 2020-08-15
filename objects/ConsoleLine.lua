ConsoleLine = Object:extend()

function ConsoleLine:new(x, y, opts)
    self.x, self.y = x, y
    self.text = opts.text
    self.duration = opts.duration
    self.swaps = opts.swaps
    self.timer = Tim()

    self:setCharacters()
    self:setGlitch()

    if self.duration then
        self.timer:after(self.duration, function()
            for _, swap in ipairs(self.swaps) do self.text = self.text:gsub(swap[1], swap[2]) end
            self:setCharacters()
            self:setGlitch()
        end)
    end
end

function ConsoleLine:update(dt)
    local cx, cy = camera:getCameraCoords(self.x, self.y)
    if cy < 0 then return end

    self.timer:update(dt)
end

function ConsoleLine:replace(a, b)
    self.text = self.text:gsub(a, b)
    self:setCharacters()
end

function ConsoleLine:setCharacters()
    self.characters = {}
    self.base_characters = {}
    local language = 'normal'
    for i = 1, #self.text do 
        local c = self.text:utf8sub(i, i)
        local c2 = self.text:utf8sub(i+1, i+1)
        local marker = false
        if c == '{' or c == '}' or c == '(' or c == ')' or c == '<' or c == '>' or c == ';' or c == ',' or c == '@' or c == '#' or c == '$' or c == '%' then marker = true end
        if c == ']' then language = 'normal' end
        if c == ')' then language = 'normal' end
        table.insert(self.characters, {c = c, language = language, visible = false, marker = marker}) 
        if c == '[' and c2 ~= ' ' then language = 'arch' end
        if c == '(' then language = 'arch' end
    end

    local normal_font = fonts.Anonymous_8
    local arch_font = fonts.Arch_16
    for i = 1, #self.characters do
        local width = 0
        if i > 1 then
            for j = 1, i-1 do
                if self.characters[j] and not self.characters[j].marker then
                    if self.characters[j].language == 'normal' then width = width + normal_font:getWidth(self.characters[j].c)
                    elseif self.characters[j].language == 'arch' then width = width + arch_font:getWidth(self.characters[j].c) end
                end
            end
        end
        self.characters[i].width = width
    end

    self.base_characters = table.copy(self.characters)
    self.background_colors = {}
    self.foreground_colors = {}

    for i, _ in ipairs(self.characters) do
        self.timer:after(0.0025*i, function()
            if self.characters and self.characters[i] then self.characters[i].visible = true end
            if self.base_characters and self.base_characters[i] then self.base_characters[i].visible = true end
        end)
    end
end

function ConsoleLine:print(t)
    local str = ''
    for _, c in ipairs(t) do str = str .. c.c end
    print(str)
end

function ConsoleLine:setGlitch()
    --[[
    self.timer:every(0.05, function() self.visible = not self.visible end, 6)
    self.timer:after(0.35, function() self.visible = true end)
    ]]--

    self.timer:every({0.2, 2}, function()
        if glitch == 0 then return end
        if #self.characters == 0 then return end
        local random_characters = '0123456789!@#$%¨&*()-=+[]^~/;?><.,|abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWYXZ'
        local i = love.math.random(1, #self.characters)

        if not self.characters[i].marker then

            if love.math.random(1, 20) <= 1 then
                local r = love.math.random(1, #random_characters)
                self.characters[i].c = random_characters:utf8sub(r, r)
            else self.characters[i].c = (self.base_characters[i] and self.base_characters[i].c) or '' end

            if love.math.random(1, 10) <= 1 then self.background_colors[i] = table.random(all_colors)
            else self.background_colors[i] = nil end

            if love.math.random(1, 10) <= 2 then self.foreground_colors[i] = table.random(all_colors)
            else self.foreground_colors[i] = nil end

            self.timer:after(0.1, function()
                self.characters[i].c = (self.base_characters[i] and self.base_characters[i].c) or ''
                self.background_colors[i] = nil
                self.foreground_colors[i] = nil
            end)
        end
    end, 'glitch')
end

function ConsoleLine:draw()
    local cx, cy = camera:getCameraCoords(self.x, self.y)
    if cy < 0 then return end
    -- if not self.visible then return end

    local normal_font = fonts.Anonymous_8
    local arch_font = fonts.Arch_16
    for i = 1, #self.characters do 
        if not self.characters[i].visible then return end

        if self.characters[i].language == 'normal' then love.graphics.setFont(normal_font)
        elseif self.characters[i].language == 'arch' then love.graphics.setFont(arch_font) end

        if self.characters[i].c == '{' then love.graphics.setColor(skill_point_color) end
        if self.characters[i].c == '}' then love.graphics.setColor(default_color) end
        if self.characters[i].c == '<' then love.graphics.setColor(ammo_color) end
        if self.characters[i].c == '>' then love.graphics.setColor(default_color) end
        if self.characters[i].c == ';' then love.graphics.setColor(skill_point_color) end
        if self.characters[i].c == ',' then love.graphics.setColor(default_color) end
        if self.characters[i].c == '@' then love.graphics.setColor(hp_color) end
        if self.characters[i].c == '#' then love.graphics.setColor(default_color) end
        if self.characters[i].c == '$' then love.graphics.setColor(boost_color) end
        if self.characters[i].c == '%' then love.graphics.setColor(default_color) end
        if not self.characters[i].marker then
            local r, g, b = love.graphics.getColor()
            if self.background_colors[i] then
                love.graphics.setColor(self.background_colors[i])
                love.graphics.rectangle('fill', self.x + self.characters[i].width, self.y + math.floor(normal_font:getHeight()/2), normal_font:getWidth(self.characters[i].c), normal_font:getHeight())
            end
            love.graphics.setColor(self.foreground_colors[i] or {r, g, b} or self.color or default_color)
            if self.characters[i].language == 'normal' then love.graphics.print(self.characters[i].c, self.x + self.characters[i].width, self.y + math.floor(normal_font:getHeight()/2), 0, 1, 1, 0, 0)
            else love.graphics.print(self.characters[i].c, self.x + self.characters[i].width, self.y, 0, 1, 1, 0, 0) end
        end
    end
    love.graphics.setShader()
end

function ConsoleLine:getText()
    local str = ''
    for _, c in ipairs(self.characters) do
        str = str .. c.c
    end
    return str
end
