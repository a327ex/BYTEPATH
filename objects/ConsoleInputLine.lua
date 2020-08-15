ConsoleInputLine = Object:extend()

function ConsoleInputLine:new(x, y, opts)
    self.id = UUID()
    self.timer = Timer()
    self.x, self.y = x, y
    self.text = opts.text
    self.console = opts.console
    self:setCharacters()
    self.timer:every(0.4, function() self.cursor_show = not self.cursor_show end)

    self.commands = {'resolution', 'sound', 'device', 'fullscreen', 'passives', 'clear', 'help', 'achievements', 'about', 'escape', 'shutdown', 'start', 'classes', 'display', 'effects', 'credits'}
end

function ConsoleInputLine:update(dt)
    self.timer:update(dt)
    if (self.console.input_line and self.console.input_line.id ~= self.id) or not self.console.input_line then return end

    if input:pressed('backspace') then
        if #self.text > 14 then
            self.text = self.text:utf8sub(1, -2)
            self:setCharacters()
            playKeystroke()
        end
    end

    if input:pressed('return') then 
        self:enter() 
        playKeystroke()
    end

    if input:pressed('escape') then 
        --self:enter() 
        self.console:bytepathMain2()
        playKeystroke()
    end

    if input:pressed('tab') then
        local command = self.text:utf8sub(15, -1)
        for _, available_command in ipairs(self.commands) do
            if available_command:find(command) then
                self.text = '[;root,]arch~ ' .. available_command
                self:setCharacters()
            end
        end
    end

    if input:pressed('up') and not self.console.bytepath_main_active then
        if #command_history > 0 then
            command_history_index = command_history_index - 1
            if command_history_index < 1 then command_history_index = 1 end
            self.text = '[;root,]arch~ ' .. command_history[command_history_index]
            self:setCharacters()
        end
    end

    if input:pressed('down') and not self.console.bytepath_main_active then
        if #command_history > 0 then
            command_history_index = command_history_index + 1
            if command_history_index > #command_history then command_history_index = #command_history end
            self.text = '[;root,]arch~ ' .. command_history[command_history_index]
            self:setCharacters()
        end
    end
end

function ConsoleInputLine:enter()
    local command = self.text:utf8sub(15, -1)
    if #command == 0 then return end
    self.console:addToCommandHistory(command)
    if fn.any(self.commands, command) or command:find('verify') then
        self.console.input_line = nil
        self.console.bytepath_main = nil
        if command == 'help' then
            self:help()

        elseif command == 'about' then
            table.insert(self.console.modules, AboutModule(self.console, self.console.line_y))

        elseif command == 'resolution' then
            table.insert(self.console.modules, ResolutionModule(self.console, self.console.line_y))

        elseif command == 'sound' then
            table.insert(self.console.modules, SoundModule(self.console, self.console.line_y))

        elseif command == 'device' then
            table.insert(self.console.modules, DeviceModule(self.console, self.console.line_y))

        elseif command == 'display' then
            table.insert(self.console.modules, DisplayModule(self.console, self.console.line_y))

        elseif command == 'effects' then
            table.insert(self.console.modules, EffectsModule(self.console, self.console.line_y))

        elseif command == 'achievements' then
            gotoRoom('Achievements')

        elseif command == 'fullscreen' then
            table.insert(self.console.modules, FullscreenModule(self.console, self.console.line_y))

        elseif command == 'passives' then
            gotoRoom('SkillTree')

        elseif command == 'start' then
            gotoRoom('Stage')

        elseif command == 'credits' then
            table.insert(self.console.modules, CreditsModule(self.console, self.console.line_y))

        elseif command == 'shutdown' then
            table.insert(self.console.modules, ShutdownModule(self.console, self.console.line_y))

        elseif command == 'clear' then
            table.insert(self.console.modules, ClearModule(self.console, self.console.line_y))
            
        elseif command == 'escape' then
            table.insert(self.console.modules, EscapeModule(self.console, self.console.line_y))

        elseif command == 'classes' then
            gotoRoom('Classes')

        elseif command:find('verify') then
            local key_string = command:utf8sub(8, -1)
            for i = 1, 8 do
                local kav = keys[i].address .. ' ' .. keys[i].value
                if key_string == kav then
                    verified_keys[i] = 1
                    self.console:addLine(0.02, '')
                    self.console:addLine(0.04, '[  ;WAIT,  ] verifying key ' .. kav, 4.4, {{';WAIT,', ' <OK> '}, {'verifying', 'verified'}})
                    local r = love.math.random(4, 6)
                    local words = {}; for i = 1, r do words[i] = self.console:getRandomArchWord() end
                    for i = 1, r do self.console:addLine(0.04 + 0.02*i, '[  ;WAIT,  ] connecting to node [' .. words[i] .. ']', random(1.2, 2.2), {{';WAIT,', ' <OK> '}, {'connecting', 'connected'}}) end
                    self.console:addLine(2.46, '[  ;WAIT,  ] verifying node integrity', 1.6, {{';WAIT,', ' <OK> '}, {'verifying', 'verified'}}) 
                    for i = 1, r do self.console:addLine(2.5 + 0.02*i, '[  ;WAIT,  ] verifying node data [' .. words[i] .. ']', random(0.8, 1.4), {{';WAIT,', ' <OK> '}, {'verifying', 'verified'}}) end
                    self.console:addLine(4.48, '')
                    self.console:addInputLine(4.50, '[;root,]arch~ ')
                    save()
                    goto continue
                end
            end
            self.console:addLine(0.02, 'invalid key address or value ;' .. key_string .. ',')
            self.console:addInputLine(0.04, '[;root,]arch~ ')
            ::continue::

        elseif command == 'achievements' then
            table.insert(self.console.modules, AchievementModule(self.console, self.console.line_y))
        end

    else
        self.console:addLine(0.02, command .. ': command not found')
        self.console:addInputLine(0.04, '[;root,]arch~ ')
    end
end

function ConsoleInputLine:draw()
    local normal_font = fonts.Anonymous_8
    local arch_font = fonts.Arch_16
    for i = 1, #self.characters do 
        local width = 0
        if i > 1 then
            for j = 1, i-1 do
                if self.characters[j].c ~= '{' and self.characters[j].c ~= '}' and self.characters[j].c ~= '(' and self.characters[j].c ~= ')' and 
                   self.characters[j].c ~= '<' and self.characters[j].c ~= '>' and self.characters[j].c ~= ';' and self.characters[j].c ~= ',' and 
                   self.characters[j].c ~= '@' and self.characters[j].c ~= '#' and self.characters[j].c ~= '$' and self.characters[j].c ~= '%' then
                    if self.characters[j].language == 'normal' then width = width + normal_font:getWidth(self.characters[j].c)
                    elseif self.characters[j].language == 'arch' then width = width + arch_font:getWidth(self.characters[j].c) end
                end
            end
        end
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
        if self.characters[i].c ~= '{' and self.characters[i].c ~= '}' and self.characters[i].c ~= '(' and self.characters[i].c ~= ')' and 
           self.characters[i].c ~= '<' and self.characters[i].c ~= '>' and self.characters[i].c ~= ';' and self.characters[i].c ~= ',' and
           self.characters[i].c ~= '@' and self.characters[i].c ~= '#' and self.characters[i].c ~= '$' and self.characters[i].c ~= '%' then
            if self.characters[i].language == 'normal' then love.graphics.print(self.characters[i].c, self.x + width, self.y + math.floor(normal_font:getHeight()/2), 0, 1, 1, 0, 0)
            else love.graphics.print(self.characters[i].c, self.x + width, self.y, 0, 1, 1, 0, 0) end
        end
    end
    local width = 0
    for j = 1, #self.characters do
        if self.characters[j].c ~= '{' and self.characters[j].c ~= '}' and self.characters[j].c ~= '(' and self.characters[j].c ~= ')' and 
           self.characters[j].c ~= '<' and self.characters[j].c ~= '>' and self.characters[j].c ~= ';' and self.characters[j].c ~= ',' and 
           self.characters[j].c ~= '@' and self.characters[j].c ~= '#' and self.characters[j].c ~= '$' and self.characters[j].c ~= '%' then
            if self.characters[j].language == 'normal' then width = width + normal_font:getWidth(self.characters[j].c)
            elseif self.characters[j].language == 'arch' then width = width + arch_font:getWidth(self.characters[j].c) end
        end
    end

    if self.console.input_line and self.console.input_line.id == self.id then
        local r, g, b = unpack(default_color)
        love.graphics.setColor(r, g, b, 96)
        if self.cursor_show then love.graphics.rectangle('fill', self.x + width, self.y + math.floor(normal_font:getHeight()/2), normal_font:getWidth('w'), normal_font:getHeight()) end
        love.graphics.setColor(r, g, b, 255)
        love.graphics.setShader()
    end
end

function ConsoleInputLine:setCharacters()
    self.characters = {}
    local language = 'normal'
    for i = 1, #self.text do 
        local c = self.text:utf8sub(i, i)
        local c2 = self.text:utf8sub(i+1, i+1)
        if c == ']' then language = 'normal' end
        if c == ')' then language = 'normal' end
        table.insert(self.characters, {c = c, language = language}) 
        if c == '[' and c2 ~= ' ' then language = 'arch' end
        if c == '(' then language = 'arch' end
    end
end

function ConsoleInputLine:keypressed(key)
    if self.console.input_line and self.console.input_line.id == self.id then
        if key == 'space' then self.text = self.text .. ' '
        else self.text = self.text .. key end
        self:setCharacters()
        playKeystroke()
    end
end

function ConsoleInputLine:help()
    self.console.input_line = nil
    self.console.bytepath_main = nil
    table.insert(self.console.modules, HelpModule(self.console, self.console.line_y))
end
