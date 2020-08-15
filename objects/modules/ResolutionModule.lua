ResolutionModule = Object:extend()

function ResolutionModule:new(console, y)
    self.console = console

    local w, h = love.window.getDesktopDimensions(display)

    self.console:addLine(0.02, '')
    self.console:addLine(0.04, '~ press @ENTER# to select')
    self.console:addLine(0.06, '~ press @ESC# to exit')
    self.console:addLine(0.08, '    @FULLSCREEN WINDOWED BORDERLESS - ' .. w .. 'x' .. h .. '#')
    self.console:addLine(0.10, '    @480x270#')
    self.console:addLine(0.12, '    @960x540#')
    self.console:addLine(0.14, '    @1440x810#')
    self.console:addLine(0.16, '    @1920x1080#')
    self.console:addLine(0.18, '')

    self.y = y
    self.h = 6*self.console.font:getHeight()

    self.selection_index = 1
    self.selection_widths = {
        self.console.font:getWidth('FULLSCREEN WINDOWED BORDERLESS - ' .. w .. 'x' .. h), 
        self.console.font:getWidth('480x270'), self.console.font:getWidth('960x540'), self.console.font:getWidth('1440x810'), 
        self.console.font:getWidth('1920x1080')
    }
    self.console.timer:after(0.02 + self.selection_index*0.02, function() self.active = true end)
end

function ResolutionModule:update(dt)
    if not self.active then return end

    if input:pressed('up') then
        self.selection_index = self.selection_index - 1
        if self.selection_index < 1 then self.selection_index = #self.selection_widths end
    end

    if input:pressed('down') then
        self.selection_index = self.selection_index + 1
        if self.selection_index > #self.selection_widths then self.selection_index = 1 end
    end

    if input:pressed('return') then
        self.active = false
        if self.selection_index == 1 then resizeFullscreen()
        else resize(self.selection_index-1, self.selection_index-1, false) end
        self.console:addInputLine(0.02, '[;root,]arch~ ')
    end

    if input:pressed('escape') then
        self.active = false
        self.console:addInputLine(0.02, '[;root,]arch~ ')
    end
end

function ResolutionModule:draw()
    if not self.active then return end

    local width = self.selection_widths[self.selection_index]
    local r, g, b = unpack(hp_color)
    love.graphics.setColor(r, g, b, 128)
    local x_offset = self.console.font:getWidth('    ')
    love.graphics.rectangle('fill', 8 + x_offset - 2, self.y + self.selection_index*12 + 17 + 12, width + 4, self.console.font:getHeight())
    love.graphics.setColor(255, 255, 255, 255)
end
