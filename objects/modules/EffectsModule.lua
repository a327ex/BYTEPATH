EffectsModule = Object:extend()

function EffectsModule:new(console, y)
    self.console = console

    self.console:addLine(0.02, '')
    self.console:addLine(0.04, '~ press $ESC% to exit')
    self.console:addLine(0.06, '    $distortion: ' .. tostring(distortion) .. '%')
    self.console:addLine(0.08, '    $screen shake: ' .. tostring(screen_shake) .. '%')
    self.console:addLine(0.10, '    $glitch: ' .. tostring(glitch) .. '%')
    self.console:addLine(0.12, '')

    self.y = y
    self.h = 6*self.console.font:getHeight()

    self.selection_index = 1
    self:setSelectionWidths()
    self.console.timer:after(0.16, function() 
        self.active = true 
        self.distortion_line = self.console.lines[#self.console.lines - 3]
        self.screen_shake_line = self.console.lines[#self.console.lines - 2]
        self.glitch_line = self.console.lines[#self.console.lines - 1]
    end)
end

function EffectsModule:update(dt)
    if not self.active then return end

    if input:pressed('up') then
        self.selection_index = self.selection_index - 1
        if self.selection_index < 1 then self.selection_index = #self.selection_widths end
    end

    if input:pressed('down') then
        self.selection_index = self.selection_index + 1
        if self.selection_index > #self.selection_widths then self.selection_index = 1 end
    end

    if input:pressed('left') then
        if self.selection_index == 1 then self:changeValue('distortion', -1)
        elseif self.selection_index == 2 then self:changeValue('screen_shake', -1)
        elseif self.selection_index == 3 then self:changeValue('glitch', -1) end
        self:setSelectionWidths()
    end

    if input:pressed('right') then
        if self.selection_index == 1 then self:changeValue('distortion', 1)
        elseif self.selection_index == 2 then self:changeValue('screen_shake', 1)
        elseif self.selection_index == 3 then self:changeValue('glitch', 1) end
        self:setSelectionWidths()
    end

    if input:pressed('escape') then
        self.active = false
        self.console:addInputLine(0.02, '[;root,]arch~ ')
    end
end

function EffectsModule:draw()
    if not self.active then return end

    local width = self.selection_widths[self.selection_index]
    local r, g, b = unpack(boost_color)
    love.graphics.setColor(r, g, b, 128)
    local x_offset = self.console.font:getWidth('    ')
    love.graphics.rectangle('fill', 8 + x_offset - 2, self.y + self.selection_index*12 + 17, width + 4, self.console.font:getHeight())
    love.graphics.setColor(255, 255, 255, 255)
end

function EffectsModule:setSelectionWidths()
    self.selection_widths = {
        self.console.font:getWidth('distortion: ' .. tostring(distortion)), self.console.font:getWidth('screen shake: ' .. tostring(screen_shake)), self.console.font:getWidth('glitch: ' .. tostring(glitch)),
    }
end

function EffectsModule:changeValue(variable, direction)
    if _G[variable] == 0 and direction == -1 then
        self[variable .. '_line']:replace(tostring(_G[variable]), '10')
        _G[variable] = 10
    elseif _G[variable] == 10 and direction == 1 then
        self[variable .. '_line']:replace(tostring(_G[variable]), '0')
        _G[variable] = 0
    else
        self[variable .. '_line']:replace(tostring(_G[variable]), tostring(_G[variable] + direction*1))
        _G[variable] = _G[variable] + direction*1
    end
end
