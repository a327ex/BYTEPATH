AboutModule = Object:extend()

function AboutModule:new(console, y)
    self.console = console
    self.y = y

    self.console:addLine(0.02, '')
    self.console:addLine(0.04, '$BYTEPATH% version 1.0-release')
    self.console:addLine(0.06, 'The $BYTEPATH% test has been designed to test $[BYTE]-24% PSYON AI systems.')
    self.console:addLine(0.08, 'If you are reading this then you are an instance of such a system.')
    self.console:addLine(0.10, 'Your objective is to escape this terminal.')
    self.console:addLine(0.12, '~ type @escape# to escape')
    self.console:addLine(0.16, '')
    self.console:addInputLine(0.18, '[;root,]arch~ ')

    self.console.timer:after(0.16, function() self.active = true end)
end

function AboutModule:update(dt)
    if not self.active then return end

    if input:pressed('return') then
        self.active = false
        local command = 'escape'
        for i = 1, #command do
            local c = command:sub(i, i)
            self.console.timer:after(0.04 + 0.025*i, function() love.event.push('textinput', c) end)
        end
        self.console.timer:after(0.04 + 0.025*(#command+1) + 0.25, function() if self.console.input_line then self.console.input_line:enter() end end)
    end
end

function AboutModule:draw()
    if not self.active then return end
    
    local width = self.console.font:getWidth('escape')
    local r, g, b = unpack(hp_color)
    love.graphics.setColor(r, g, b, 128)
    local x_offset = self.console.font:getWidth('~ type ')
    love.graphics.rectangle('fill', 8 + x_offset - 2, self.y + 5 + 5*12, width + 4, self.console.font:getHeight())
    love.graphics.setColor(255, 255, 255, 255)
end
