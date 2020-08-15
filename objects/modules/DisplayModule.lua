DisplayModule = Object:extend()

function DisplayModule:new(console, y)
    self.console = console

    self.console:addLine(0.02, '')
    self.console:addLine(0.04, '~ press @ENTER# to select the default display')
    self.console:addLine(0.06, '~ press @ESC# to exit')

    local n = love.window.getDisplayCount()
    local texts = {}
    self.selection_widths = {}
    for i = 1, n do
        local w, h = love.window.getDesktopDimensions(i)
        table.insert(texts, '    @' .. i .. ' - ' .. w .. 'x' .. h .. '#')
        table.insert(self.selection_widths, self.console.font:getWidth(i .. ' - ' .. w .. 'x' .. h))
    end
    for i, text in ipairs(texts) do self.console:addLine(0.08 + i*0.02, text) end
    self.console:addLine(0.10 + #texts*0.02, '')

    self.y = y
    self.h = 6*self.console.font:getHeight()

    self.selection_index = 1
    self.console.timer:after(0.02 + self.selection_index*0.02, function() self.active = true end)
end

function DisplayModule:update(dt)
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
        changeToDisplay(self.selection_index)
        self.console:addInputLine(0.02, '[;root,]arch~ ')
    end

    if input:pressed('escape') then
        self.active = false
        self.console:addInputLine(0.02, '[;root,]arch~ ')
    end
end

function DisplayModule:draw()
    if not self.active then return end

    local width = self.selection_widths[self.selection_index]
    local r, g, b = unpack(hp_color)
    love.graphics.setColor(r, g, b, 128)
    local x_offset = self.console.font:getWidth('    ')
    love.graphics.rectangle('fill', 8 + x_offset - 2, self.y + self.selection_index*12 + 17 + 12, width + 4, self.console.font:getHeight())
    love.graphics.setColor(255, 255, 255, 255)
end
