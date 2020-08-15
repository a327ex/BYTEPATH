HelpModule = Object:extend()

function HelpModule:new(console, y)
    self.console = console
    self.y = y

    self.console:addLine(0.02, '')
    self.console:addLine(0.04, ';ARCH(type),, version 7.4.23-release')
    self.console:addLine(0.06, "Type 'escape' to escape.") 
    self.console:addLine(0.08, '') 
    self.console:addLine(0.14, '  ;Gameplay,') 
    self.console:addLine(0.16, '    classes       Displays classes window') 
    self.console:addLine(0.18, '    clear         Clear saved data options') 
    self.console:addLine(0.20, '    device        Device options') 
    self.console:addLine(0.22, "    passives      Displays passive skill tree window") 
    self.console:addLine(0.24, "    start         Starts BYTEPATH test") 
    self.console:addLine(0.26, '  ;General,') 
    self.console:addLine(0.28, '    about         Displays information about the system') 
    self.console:addLine(0.30, '    achievements  Displays all achievements') 
    self.console:addLine(0.32, '    credits       Displays game credits') 
    self.console:addLine(0.34, '    escape        Escape the terminal') 
    self.console:addLine(0.36, '    help          Displays all builtin commands') 
    self.console:addLine(0.38, "    shutdown      Shuts the system down") 
    self.console:addLine(0.40, '  ;Video & Sound,') 
    self.console:addLine(0.42, '    display       Display options') 
    self.console:addLine(0.44, '    effects       Effects options') 
    self.console:addLine(0.46, "    resolution    Screen resolution options") 
    self.console:addLine(0.48, "    sound         Sound options") 
    self.console.timer:after(0.52, function() self.active = true end)

    self.selection_index = 1
    self.selection_widths = {
        self.console.font:getWidth('classes'),
        self.console.font:getWidth('clear'),
        self.console.font:getWidth('device'),
        self.console.font:getWidth('passives'),
        self.console.font:getWidth('start'),
        self.console.font:getWidth('about'),
        self.console.font:getWidth('achievements'),
        self.console.font:getWidth('credits'),
        self.console.font:getWidth('escape'),
        self.console.font:getWidth('help'),
        self.console.font:getWidth('shutdown'),
        self.console.font:getWidth('display'),
        self.console.font:getWidth('effects'),
        self.console.font:getWidth('resolution'),
        self.console.font:getWidth('sound'),
    }

    self.y_offsets = {12, 12, 12, 12, 12, 24, 24, 24, 24, 24, 24, 36, 36, 36, 36}
end

function HelpModule:update(dt)
    if not self.active then return end

    if input:pressed('up') then
        self.selection_index = self.selection_index - 1
        if self.selection_index < 1 then self.selection_index = #self.selection_widths end
        playMenuSwitch()
    end

    if input:pressed('down') then
        self.selection_index = self.selection_index + 1
        if self.selection_index > #self.selection_widths then self.selection_index = 1 end
        playMenuSwitch()
    end

    if input:pressed('escape') then
        self.active = false
        self.console:addInputLine(0.02, '')
        self.console:addInputLine(0.04, '[;root,]arch~ ')
        self.console:rgbShift()
    end

    if input:pressed('return') then
        self.active = false
        if self.selection_index == 1 then
            gotoRoom('Classes')
        elseif self.selection_index == 2 then
            table.insert(self.console.modules, ClearModule(self.console, self.console.line_y))
        elseif self.selection_index == 3 then
            table.insert(self.console.modules, DeviceModule(self.console, self.console.line_y))
        elseif self.selection_index == 4 then
            gotoRoom('SkillTree')
        elseif self.selection_index == 5 then
            gotoRoom('Stage')
        elseif self.selection_index == 6 then
            table.insert(self.console.modules, AboutModule(self.console, self.console.line_y))
        elseif self.selection_index == 7 then
            gotoRoom('Achievements')
        elseif self.selection_index == 8 then
            table.insert(self.console.modules, CreditsModule(self.console, self.console.line_y))
        elseif self.selection_index == 9 then
            table.insert(self.console.modules, EscapeModule(self.console, self.console.line_y))
        elseif self.selection_index == 10 then
            table.insert(self.console.modules, HelpModule(self.console, self.console.line_y))
        elseif self.selection_index == 11 then
            table.insert(self.console.modules, ShutdownModule(self.console, self.console.line_y))
        elseif self.selection_index == 12 then
            table.insert(self.console.modules, DisplayModule(self.console, self.console.line_y))
        elseif self.selection_index == 13 then
            table.insert(self.console.modules, EffectsModule(self.console, self.console.line_y))
        elseif self.selection_index == 14 then
            table.insert(self.console.modules, ResolutionModule(self.console, self.console.line_y))
        elseif self.selection_index == 15 then
            table.insert(self.console.modules, SoundModule(self.console, self.console.line_y))
        end
        playMenuSelect()
        self.console:rgbShift()
    end
end

function HelpModule:draw()
    if not self.active then return end

    local width = self.selection_widths[self.selection_index]
    local r, g, b = unpack(default_color)
    love.graphics.setColor(r, g, b, 128)
    local x_offset = self.console.font:getWidth('    ')
    love.graphics.rectangle('fill', 8 + x_offset - 2, 
    self.y + self.selection_index*12 + 3*12 + 5 + self.y_offsets[self.selection_index], width + 4, self.console.font:getHeight())
    love.graphics.setColor(255, 255, 255, 255)
end
