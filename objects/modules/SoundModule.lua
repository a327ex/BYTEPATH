SoundModule = Object:extend()

function SoundModule:new(console, y)
    self.console = console

    self.console:addLine(0.02, '')
    self.console:addLine(0.04, '~ press $ESC% to exit')
    self.console:addLine(0.06, '    $main volume: ' .. tostring(main_volume) .. '%')
    self.console:addLine(0.08, '    $sfx volume: ' .. tostring(sfx_volume) .. '%')
    self.console:addLine(0.10, '    $music volume: ' .. tostring(music_volume) .. '%')
    self.console:addLine(0.12, '    $muted: ' .. tostring(muted) .. '%')
    self.console:addLine(0.14, '')

    self.y = y
    self.h = 6*self.console.font:getHeight()

    self.selection_index = 1
    self:setSelectionWidths()
    self.console.timer:after(0.16, function() 
        self.active = true 
        self.main_volume_line = self.console.lines[#self.console.lines - 4]
        self.sfx_volume_line = self.console.lines[#self.console.lines - 3]
        self.music_volume_line = self.console.lines[#self.console.lines - 2]
        self.muted_line = self.console.lines[#self.console.lines - 1]
    end)
end

function SoundModule:update(dt)
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
        if self.selection_index == 1 then self:changeValue('main_volume', -1)
        elseif self.selection_index == 2 then self:changeValue('sfx_volume', -1)
        elseif self.selection_index == 3 then self:changeValue('music_volume', -1)
        elseif self.selection_index == 4 then
            self.muted_line:replace(tostring(muted), tostring(not muted))
            muted = not muted
        end
        self:setSelectionWidths()
    end

    if input:pressed('right') then
        if self.selection_index == 1 then self:changeValue('main_volume', 1)
        elseif self.selection_index == 2 then self:changeValue('sfx_volume', 1)
        elseif self.selection_index == 3 then self:changeValue('music_volume', 1)
        elseif self.selection_index == 4 then
            self.muted_line:replace(tostring(muted), tostring(not muted))
            muted = not muted
        end
        self:setSelectionWidths()
    end

    if input:pressed('escape') then
        self.active = false
        self.console:addInputLine(0.02, '[;root,]arch~ ')
    end
end

function SoundModule:draw()
    if not self.active then return end

    local width = self.selection_widths[self.selection_index]
    local r, g, b = unpack(boost_color)
    love.graphics.setColor(r, g, b, 128)
    local x_offset = self.console.font:getWidth('    ')
    love.graphics.rectangle('fill', 8 + x_offset - 2, self.y + self.selection_index*12 + 17, width + 4, self.console.font:getHeight())
    love.graphics.setColor(255, 255, 255, 255)
end

function SoundModule:setSelectionWidths()
    self.selection_widths = {
        self.console.font:getWidth('main volume: ' .. tostring(main_volume)), self.console.font:getWidth('sfx volume: ' .. tostring(sfx_volume)),
        self.console.font:getWidth('music volume: ' .. tostring(music_volume)), self.console.font:getWidth('muted: ' .. tostring(muted))
    }
end

function SoundModule:changeValue(variable, direction)
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
