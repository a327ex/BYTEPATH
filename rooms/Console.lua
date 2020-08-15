Console = Object:extend()

function Console:new()
    self.timer = Tim()
    self.area = Area(self)

    self.main_canvas = love.graphics.newCanvas(gw, gh)
    self.final_canvas = love.graphics.newCanvas(gw, gh)
    self.temp_canvas = love.graphics.newCanvas(gw, gh)
    self.glitch_canvas = love.graphics.newCanvas(gw, gh)
    self.rgb_shift_mag = 0
    self.font = fonts.Anonymous_8
    self.arch = fonts.Arch_8

    self.lines = {}
    self.line_y = 8
    camera:lookAt(gw/2, gh/2)
    camera.scale = 1
    self.modules = {}

    self.glitches = {}

    command_history_index = #command_history

    if first_run_ever then self:bytepathIntro()
    else self:bytepathMain() end

    input:unbindAll()
    input:bind('left', 'left')
    input:bind('right', 'right')
    input:bind('up', 'up')
    input:bind('down', 'down')
    input:bind('mouse1', 'left_click')
    input:bind('return', 'return')
    input:bind('backspace', 'backspace')
    input:bind('escape', 'escape')
    input:bind('dpleft', 'left')
    input:bind('dpright', 'right')
    input:bind('dpup', 'up')
    input:bind('dpdown', 'down')
    input:bind('fright', 'escape')
    input:bind('fdown', 'return')
    input:bind('fleft', 'return')
    input:bind('select', 'escape')
    input:bind('start', 'start')
    input:bind('tab', 'tab')

    save()
    fadeVolume('music', 1, 0.05)
    fadeVolume('game', 1, 0.0)

    self.timer:every(0.05, function()
        local r = 127 + love.math.random(-8, 8)
        table.insert(self.glitches, GlitchDisplacementC(love.math.random(0, gw), love.math.random(0, gh), love.math.random(16, 48), love.math.random(8, 16), {r, r, r}))
    end)

    self.timer:every({0.1, 0.2}, function() self.area:addGameObject('GlitchDisplacement') end)
end

function Console:update(dt)
    self.timer:update(dt)
    self.area:update(dt)

    for _, line in ipairs(self.lines) do line:update(dt) end
    for _, module in ipairs(self.modules) do module:update(dt) end
    for i = #self.glitches, 1, -1 do
        self.glitches[i]:update(dt)
        if self.glitches[i].dead then table.remove(self.glitches, i) end
    end

    if self.bytepath_main_active then
        if input:pressed('up') then
            self.bytepath_main_selection_index = self.bytepath_main_selection_index - 1
            if self.bytepath_main_selection_index == 0 then self.bytepath_main_selection_index = #self.bytepath_main_selection_widths end
            playMenuSwitch()
        end

        if input:pressed('down') then
            self.bytepath_main_selection_index = self.bytepath_main_selection_index + 1
            if self.bytepath_main_selection_index == 7 then self.bytepath_main_selection_index = 1 end
            playMenuSwitch()
        end

        if input:pressed('return') then
            self:rgbShift()
            self.bytepath_main = false
            local command = self.bytepath_main_texts[self.bytepath_main_selection_index]
            for i = 1, #command do
                local c = command:sub(i, i)
                self.timer:after(0.025*i, function() love.event.push('keypressed', c) end)
            end
            self.timer:after(0.025*(#command+1) + 0.25, function() 
                if self.input_line then 
                    self.input_line:enter() 
                    playKeystroke()
                    self:rgbShift()
                end 
            end)
        end

        if input:pressed('start') then
            self:rgbShift()
            local command = 'start'
            self:addToCommandHistory(command)
            for i = 1, #command do
                local c = command:sub(i, i)
                self.timer:after(0.025*i, function() love.event.push('keypressed', c) end)
            end
            self.timer:after(0.025*(#command+1) + 0.25, function() 
                if self.input_line then 
                    self.input_line:enter() 
                    playKeystroke()
                    self:rgbShift()
                end 
            end)
        end
    end
    if not self.bytepath_main then self.bytepath_main_active = false end
end

function Console:draw()
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
        for _, line in ipairs(self.lines) do line:draw() end
        for _, module in ipairs(self.modules) do module:draw() end

        if self.bytepath_main_active then
            local width = self.bytepath_main_selection_widths[self.bytepath_main_selection_index]
            local r, g, b = unpack(hp_color)
            love.graphics.setColor(r, g, b, 128)
            local x_offset = self.font:getWidth('~ type ')
            love.graphics.rectangle('fill', 8 + x_offset - 2, self.bytepath_main_y + self.bytepath_main_selection_index*12 - 7, width + 4, self.font:getHeight())
            love.graphics.setColor(255, 255, 255, 255)
        end
        camera:detach()
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

function Console:destroy()
    
end

function Console:addLine(after, text, duration, swaps)
    self.timer:after(after, function()
        if text ~= '' then playComputerLine() end
        if self.bytepath_main then 
            if text == '~ type @help# for help' then
                self.bytepath_main_y = self.line_y
            end
        end
        table.insert(self.lines, ConsoleLine(8, self.line_y, {text = text, duration = duration, swaps = swaps}))
        self.line_y = self.line_y + 12
        if self.line_y > gh then camera:lookAt(camera.x, camera.y + 12) end 
    end)
end

function Console:addInputLine(delay, text)
    self.timer:after(delay, function()
        self.input_line = ConsoleInputLine(8, self.line_y, {text = text, console = self})
        table.insert(self.lines, self.input_line)
        self.line_y = self.line_y + 12
        if self.line_y > gh then camera:lookAt(camera.x, camera.y + 12) end 
    end)
end

function Console:getRandomArchWord()
    local word = ''
    local random_letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWYXZ'
    for i = 1, love.math.random(1, 5) do 
        local r = love.math.random(1, #random_letters)
        word = word .. random_letters:utf8sub(r, r) 
    end
    return word
end

function Console:keypressed(key)
    if self.input_line and self:isConsoleCharacter(key) then 
        self.bytepath_main = false
        self.input_line:keypressed(key) 
    end
end

function Console:addToCommandHistory(command)
    table.insert(command_history, command)
    command_history_index = #command_history
end

function Console:isConsoleCharacter(key)
    local keys = {'space', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0'}
    if fn.any(keys, key) then return true end
end

function Console:bytepathMain(delay)
    local delay = delay or 0 
    local classes_string = ''
    for _, class in ipairs(classes) do
        if class_colors[class] == ammo_color then
            classes_string = classes_string .. '<' .. class .. '> - '
        elseif class_colors[class] == hp_color then
            classes_string = classes_string .. '@' .. class .. '# - '
        elseif class_colors[class] == boost_color then
            classes_string = classes_string .. '$' .. class .. '% - '
        elseif class_colors[class] == default_color then
            classes_string = classes_string .. class .. ' - '
        elseif class_colors[class] == skill_point_color then
            classes_string = classes_string .. ';' .. class .. ', - '
        end
    end

    self:addLine(delay + 0.02, ':: running $BYTEPATH [byte]% in SAFE MODE')
    self:addLine(delay + 0.04, ':: ' .. os.date("%a %b %d ") .. tostring(tonumber(os.date("%Y"))+1000) .. os.date(" %X ") .. 'on ;VCON1,')
    self:addLine(delay + 0.06, '')
    self:addLine(delay + 0.08, 'Welcome to $BYTEPATH v1.0% - <' .. string.sub(id, 1, 8) .. '>!')
    self:addLine(delay + 0.10, '')
    if loop > 0 then
        self:addLine(delay + 0.12, '$LOOP: ' .. loop .. '% ~~ +10 SP / +5 MAX TREE NODES PER LOOP ~~ UP TO 5 LOOPS')
    end
    self:addLine(delay + 0.14, ';SP: ' .. skill_points .. ',')
    self:addLine(delay + 0.16, '$CURRENT DEVICE: ' .. device .. '%')
    self:addLine(delay + 0.18, 'CLASSES: ' .. classes_string) 
    self:addLine(delay + 0.20, 'LAST SCORE: ' .. score)
    self:addLine(delay + 0.22, 'HIGH SCORE: ' .. high_score)
    self:addLine(delay + 0.24, '')
    self:addLine(delay + 0.26, 'Your objective is to escape this terminal by reaching difficulty 40 and finding all keys.')
    self:addLine(delay + 0.28, '~ type @escape# to escape')
    self:addLine(delay + 0.32, '~ type @start# to start the simulation with the current device')
    self:addLine(delay + 0.34, '~ type @help# to view all builtin commands')
    self:addLine(delay + 0.36, '~ type @classes# to view the class window')
    self:addLine(delay + 0.38, '~ type @device# to select a new device')
    self:addLine(delay + 0.40, '~ type @passives# to view the passive skill tree')
    self:addLine(delay + 0.42, '')
    self:addInputLine(delay + 0.44, '[;root,]arch~ ')

    self.timer:after(delay, function()
        self.bytepath_main = true
        self.bytepath_main_active = false
        self.bytepath_main_selection_index = 1
        self.bytepath_main_texts = {'escape', 'start', 'help', 'classes', 'device', 'passives'}
        self.bytepath_main_selection_widths = {self.font:getWidth('escape'), self.font:getWidth('start'), self.font:getWidth('help'), self.font:getWidth('classes'), self.font:getWidth('device'), self.font:getWidth('passives')}
        if loop > 0 then self.bytepath_main_y = self.line_y + 13*12
        else self.bytepath_main_y = self.line_y + 13*12 - 12 end
        self.timer:after(0.38, function() self.bytepath_main_active = true end)
    end)
end

function Console:bytepathMain2()
    local delay = delay or 0 
    local classes_string = ''
    for _, class in ipairs(classes) do
        if class_colors[class] == ammo_color then
            classes_string = classes_string .. '<' .. class .. '> - '
        elseif class_colors[class] == hp_color then
            classes_string = classes_string .. '@' .. class .. '# - '
        elseif class_colors[class] == boost_color then
            classes_string = classes_string .. '$' .. class .. '% - '
        elseif class_colors[class] == default_color then
            classes_string = classes_string .. class .. ' - '
        elseif class_colors[class] == skill_point_color then
            classes_string = classes_string .. ';' .. class .. ', - '
        end
    end

    self:addLine(delay + 0.02, '')
    self:addLine(delay + 0.04, ';SP: ' .. skill_points .. ',')
    self:addLine(delay + 0.06, '$CURRENT DEVICE: ' .. device .. '%')
    self:addLine(delay + 0.08, 'CLASSES: ' .. classes_string) 
    self:addLine(delay + 0.10, 'LAST SCORE: ' .. score)
    self:addLine(delay + 0.12, 'HIGH SCORE: ' .. high_score)
    self:addLine(delay + 0.14, '')
    self:addLine(delay + 0.16, 'Your objective is to escape this terminal by reaching difficulty 40 and finding all keys.')
    self:addLine(delay + 0.18, '~ type @escape# to escape')
    self:addLine(delay + 0.22, '~ type @start# to start the simulation with the current device')
    self:addLine(delay + 0.24, '~ type @help# to view all builtin commands')
    self:addLine(delay + 0.26, '~ type @classes# to view the class window')
    self:addLine(delay + 0.28, '~ type @device# to select a new device')
    self:addLine(delay + 0.30, '~ type @passives# to view the passive skill tree')
    self:addLine(delay + 0.32, '')
    self:addInputLine(delay + 0.34, '[;root,]arch~ ')

    self.timer:after(delay, function()
        self.bytepath_main = true
        self.bytepath_main_active = false
        self.bytepath_main_selection_index = 1
        self.bytepath_main_texts = {'escape', 'start', 'help', 'classes', 'device', 'passives'}
        self.bytepath_main_selection_widths = {self.font:getWidth('escape'), self.font:getWidth('start'), self.font:getWidth('help'), self.font:getWidth('classes'), self.font:getWidth('device'), self.font:getWidth('passives')}
        self.bytepath_main_y = self.line_y + 9*12 - 12
        self.timer:after(0.30, function() self.bytepath_main_active = true end)
    end)
end

function Console:bytepathIntro()
    first_run_ever = false

    local delay = 7.50
    self:addLine(2.0, '...')
    self:addLine(3.0, '...')
    self:addLine(4.0, '...')
    self:addLine(5.0, '...')
    self:addLine(5.52, '')
    self:addLine(delay + 0.0, ':: running genesis hook [stre]')
    self:addLine(delay + 0.02, ':: running hook [stre]')
    self:addLine(delay + 0.1, '.. triggering genesis events...')
    self:addLine(delay + 0.3, ':: running hook [' .. self:getRandomArchWord() .. ']')
    self:addLine(delay + 0.3, ':: running hook [' .. self:getRandomArchWord() .. ']')
    self:addLine(delay + 0.3, ':: running hook [' .. self:getRandomArchWord() .. ']')
    self:addLine(delay + 0.5, ':: running hook [' .. self:getRandomArchWord() .. ']')
    self:addLine(delay + 0.5, ':: running hook [' .. self:getRandomArchWord() .. ']')
    self:addLine(delay + 0.5, ':: running hook [' .. self:getRandomArchWord() .. ']')
    self:addLine(delay + 0.5, ':: running hook [' .. self:getRandomArchWord() .. ']')
    self:addLine(delay + 0.5, ':: running hook [' .. self:getRandomArchWord() .. ']')
    self:addLine(delay + 0.6, ':: running hook [' .. self:getRandomArchWord() .. ']')
    self:addLine(delay + 0.60, ":: mounting '/dev/ARCH-282809' to '/run/archtype/bootmnt'")
    self:addLine(delay + 0.61, ":: device '/dev/ARCH-282809' mounted successfully")
    self:addLine(delay + 0.62, ":: mounting '/run/archtype/ethspace' (tmpfs) filesystem, size=75%...")
    self:addLine(delay + 0.8, ":: mounting '/dev/loop0' to '/run/archtype/rootfs'")
    self:addLine(delay + 1.6, ":: device '/dev/loop0' mounted successfully'")
    self:addLine(delay + 1.70, ":: creating '/run/archtype/ethspace/persistent-ARCH-3017/rootfs.eth' as non-persistent")
    self:addLine(delay + 1.71, ":: mounting '/dev/mapper/arch-rootfs' to /new-root/")
    self:addLine(delay + 1.80, ":: device '/dev/mapper/arch-rootfs' mounted successfully'")
    self:addLine(delay + 1.81, ':: running late hook [' .. self:getRandomArchWord() .. ']')
    self:addLine(delay + 1.82, ':: running cleanup hook [' .. self:getRandomArchWord() .. ']')
    self:addLine(delay + 1.83, ':: running cleanup hook [stre]')
    self:addLine(delay + 1.88, '')
    self:addLine(delay + 1.91, 'Welcome to {ArchType}!')
    self:addLine(delay + 1.94, '')
    self:addLine(delay + 3.80, '[   <OK>   ] reached target (' .. self:getRandomArchWord() .. ')')
    self:addLine(delay + 3.81, '[   <OK>   ] reached target (' .. self:getRandomArchWord() .. ')')
    self:addLine(delay + 3.82, '[   <OK>   ] created nodes')
    self:addLine(delay + 3.83, '[   <OK>   ] created core path')
    self:addLine(delay + 3.84, '[   <OK>   ] reached core nodes')
    self:addLine(delay + 4.30, '[   <OK>   ] listening on /dev/init')
    self:addLine(delay + 4.31, '[   <OK>   ] listening on device-mapper event procedure')
    self:addLine(delay + 4.32, '[   <OK>   ] listening on logger')
    self:addLine(delay + 4.33, '[   <OK>   ] listening on (' .. self:getRandomArchWord() .. ') core procedure')
    self:addLine(delay + 4.34, '[   <OK>   ] listening on (' .. self:getRandomArchWord() .. ') control procedure')
    self:addLine(delay + 4.80, '[  ;WAIT,  ] allocating user and session (' .. self:getRandomArchWord() .. ') [' .. self:getRandomArchWord() .. ']', 1, {{';WAIT,', ' <OK> '}, {'allocating', 'allocated'}})
    self:addLine(delay + 4.81, '[  ;WAIT,  ] allocating system (' .. self:getRandomArchWord() .. ') [' .. self:getRandomArchWord() .. ']', 1.1, {{';WAIT,', ' <OK> '}, {'allocating', 'allocated'}})
    self:addLine(delay + 5.00, '[  ;WAIT,  ] mounting page file system (' .. self:getRandomArchWord() .. ') [' .. self:getRandomArchWord() .. ']', 1, {{';WAIT,', ' <OK> '}, {'mounting', 'mounted'}})
    self:addLine(delay + 5.01, '[  ;WAIT,  ] starting load core modules (' .. self:getRandomArchWord() .. ') [' .. self:getRandomArchWord() .. ']', 0.8, {{';WAIT,', ' <OK> '}, {'starting', 'started'}})
    self:addLine(delay + 5.2, '[  ;WAIT,  ] starting (' .. self:getRandomArchWord() .. ') devices', 0.4, {{';WAIT,', ' <OK> '}, {'starting', 'started'}})
    self:addLine(delay + 5.60, '[  ;WAIT,  ] starting virtual console', 1.2, {{';WAIT,', ' <OK> '}, {'starting', 'started'}})
    self:addLine(delay + 5.61, '[  ;WAIT,  ] mounting (' .. self:getRandomArchWord() .. ') message queue file system', 1.4, {{';WAIT,', ' <OK> '}, {'mounting', 'mounted'}})
    self:addLine(delay + 5.80, '[   <OK>   ] created list of required static nodes for the current core')
    self:addLine(delay + 5.81, '[  ;WAIT,  ] mounting temporary directory (' .. self:getRandomArchWord() .. ') [' .. self:getRandomArchWord() .. ']', 0.8, {{';WAIT,', ' <OK> '}, {'mounting', 'mounted'}})
    self:addLine(delay + 6.2, '[  ;WAIT,  ] starting root and core file systems [' .. self:getRandomArchWord() .. ']', 1.4, {{';WAIT,', ' <OK> '}, {'starting', 'started'}})
    self:addLine(delay + 6.40, '[  ;WAIT,  ] starting random seed [' .. self:getRandomArchWord() .. ']', 0.4, {{';WAIT,', ' <OK> '}, {'starting', 'started'}})
    self:addLine(delay + 6.41, '[  ;WAIT,  ] creating system users', 0.1, {{';WAIT,', ' <OK> '}, {'creating', 'created'}})
    self:addLine(delay + 6.42, '[  ;WAIT,  ] creating static nodes', 0.6, {{';WAIT,', ' <OK> '}, {'creating', 'created'}})
    self:addLine(delay + 6.80, '[  ;WAIT,  ] mounting configuration file system [' .. self:getRandomArchWord() .. ']', 0.4, {{';WAIT,', ' <OK> '}, {'mounting', 'mounted'}})
    self:addLine(delay + 6.81, '[  ;WAIT,  ] applying core variables [' .. self:getRandomArchWord() .. ']', 0.1, {{';WAIT,', ' <OK> '}, {'applying', 'applied'}})
    self:addLine(delay + 6.82, '[  ;WAIT,  ] starting (' .. self:getRandomArchWord() .. ') (' .. self:getRandomArchWord() .. ') manager', 1.2, {{';WAIT,', ' <OK> '}, {'starting', 'started'}})
    self:addLine(delay + 7.40, '[   <OK>   ] reached target (' .. self:getRandomArchWord() .. ')')
    self:addLine(delay + 7.41, '[   <OK>   ] reached target (' .. self:getRandomArchWord() .. ')')
    self:addLine(delay + 7.41, '[   <OK>   ] reached target (' .. self:getRandomArchWord() .. ')')
    self:addLine(delay + 7.42, '[   <OK>   ] reached target (' .. self:getRandomArchWord() .. ')')
    self:addLine(delay + 7.43, '[   <OK>   ] reached target (' .. self:getRandomArchWord() .. ')')
    self:addLine(delay + 7.80, '[   <OK>   ] reached target (' .. self:getRandomArchWord() .. ')')
    self:addLine(delay + 7.81, '[   <OK>   ] reached target (' .. self:getRandomArchWord() .. ')')
    self:addLine(delay + 8.00, '[   <OK>   ] reached target (' .. self:getRandomArchWord() .. ')')
    self:addLine(delay + 8.40, '[  ;WAIT,  ] starting primary message system path [' .. self:getRandomArchWord() .. ']', 5.6, {{';WAIT,', '@FAIL#'}, {'starting', 'could not start'}})
    self:addLine(delay + 9.80, '[  ;WAIT,  ] starting auxiliary message system path [' .. self:getRandomArchWord() .. ']', 4.2, {{';WAIT,', '@FAIL#'}, {'starting', 'could not start'}})
    self:addLine(delay + 11.00, '[  ;WAIT,  ] solving for optimal path [' .. self:getRandomArchWord() .. ']', 3.0, {{';WAIT,', '@FAIL#'}, {'solving', 'could not solve'}})
    self:addLine(delay + 12.00, '[  ;WAIT,  ] reaching target (' .. self:getRandomArchWord() .. ')', 2.0, {{';WAIT,', '@FAIL#'}, {'reaching', 'could not reach'}})
    self:addLine(delay + 12.01, '[  ;WAIT,  ] reaching target (' .. self:getRandomArchWord() .. ')', 2.0, {{';WAIT,', '@FAIL#'}, {'reaching', 'could not reach'}})
    self:addLine(delay + 12.02, '[  ;WAIT,  ] reaching target (' .. self:getRandomArchWord() .. ')', 2.0, {{';WAIT,', '@FAIL#'}, {'reaching', 'could not reach'}})
    self:addLine(delay + 12.03, '[  ;WAIT,  ] reaching target (' .. self:getRandomArchWord() .. ')', 2.0, {{';WAIT,', '@FAIL#'}, {'reaching', 'could not reach'}})
    self:addLine(delay + 12.04, '[  ;WAIT,  ] reaching target (' .. self:getRandomArchWord() .. ')', 2.0, {{';WAIT,', '@FAIL#'}, {'reaching', 'could not reach'}})
    self:addLine(delay + 12.05, '[  ;WAIT,  ] reaching core target (' .. self:getRandomArchWord() .. ')', 2.0, {{';WAIT,', '@FAIL#'}, {'reaching', 'could not reach'}})
    self:addLine(delay + 12.06, '[  ;WAIT,  ] reaching core target (' .. self:getRandomArchWord() .. ')', 2.0, {{';WAIT,', '@FAIL#'}, {'reaching', 'could not reach'}})
    self:addLine(delay + 12.07, '[  ;WAIT,  ] reaching core target (' .. self:getRandomArchWord() .. ')', 2.0, {{';WAIT,', '@FAIL#'}, {'reaching', 'could not reach'}})
    self:addLine(delay + 12.08, '[  ;WAIT,  ] reaching core target (' .. self:getRandomArchWord() .. ')', 2.0, {{';WAIT,', '@FAIL#'}, {'reaching', 'could not reach'}})
    self:addLine(delay + 12.09, '[  ;WAIT,  ] reaching target (' .. self:getRandomArchWord() .. ')', 2.0, {{';WAIT,', '@FAIL#'}, {'reaching', 'could not reach'}})
    self:addLine(delay + 12.10, '[  ;WAIT,  ] reaching target (' .. self:getRandomArchWord() .. ')', 2.0, {{';WAIT,', '@FAIL#'}, {'reaching', 'could not reach'}})
    self:addLine(delay + 14.25, '')
    self:addLine(delay + 14.30, '@PATHING ERROR DETECTED#')
    self:addLine(delay + 14.35, '')
    for i = 1, 8 do self:addLine(delay + 14.55 + i*0.05, ':: could not reach node @(' .. self:getRandomArchWord() .. ')# @[' .. self:getRandomArchWord() .. ']#') end
    self:addLine(delay + 15.25, '')
    self:addLine(delay + 15.30, ';MANUAL INTERVENTION REQUIRED,')
    self:addLine(delay + 15.35, '')
    self:addLine(delay + 16.20, '[  ;WAIT,  ] starting safe user and session (' .. self:getRandomArchWord() .. ') [' .. self:getRandomArchWord() .. ']', 0.5, {{';WAIT,', ' <OK> '}, {'starting', 'started'}})
    self:addLine(delay + 16.21, ":: mounting '/dev/pathfinder/arch-pathfinder' to /tmp-[root]/")
    self:addLine(delay + 16.22, ":: device '/dev/pathfinder/arch-pathfinder' mounted successfully'")
    self:addLine(delay + 16.40, ':: running PATHFINDER [byte]')
    self:addLine(delay + 16.80, '[   <OK>   ] reached target (' .. self:getRandomArchWord() .. ')')
    self:addLine(delay + 16.81, '[   <OK>   ] reached target (' .. self:getRandomArchWord() .. ')')
    self:addLine(delay + 16.82, '[   <OK>   ] reached target (' .. self:getRandomArchWord() .. ')')
    self:addLine(delay + 17.43, '[   <OK>   ] reached target (' .. self:getRandomArchWord() .. ')')
    self:addLine(delay + 17.44, '[   <OK>   ] reached target (' .. self:getRandomArchWord() .. ')')
    self:addLine(delay + 17.80, '[  ;WAIT,  ] starting primary repair system [' .. self:getRandomArchWord() .. ']', 2.0, {{';WAIT,', ' <OK> '}, {'starting', 'started'}})
    self:addLine(delay + 17.90, '[  ;WAIT,  ] starting auxiliary repair system [' .. self:getRandomArchWord() .. ']', 2.0, {{';WAIT,', ' <OK> '}, {'starting', 'started'}})

    self:addLine(delay + 19.00, '')
    self:addLine(delay + 19.30, '')

    self:bytepathMain(delay + 20.00)
end

function Console:rgbShift()
    self.rgb_shift_mag = random(1, 1.5)
    self.timer:tween(0.1, self, {rgb_shift_mag = 0}, 'in-out-cubic', 'rgb_shift')
end

function Console:glitch(x, y)
    for i = 1, 6 do
        self.timer:after(0.1*i, function()
            self.area:addGameObject('GlitchDisplacement', x + random(-32, 32), y + random(-32, 32)) 
        end)
    end
end

function Console:glitchError()
    for i = 1, 10 do self.timer:after(0.1*i, function() self.area:addGameObject('GlitchDisplacement') end) end
    self.rgb_shift_mag = random(4, 8)
    self.timer:tween(1, self, {rgb_shift_mag = 0}, 'in-out-cubic', 'rgb_shift')
end
