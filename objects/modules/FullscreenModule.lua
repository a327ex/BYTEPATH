FullscreenModule = Object:extend()

function FullscreenModule:new(console, y)
    self.console = console
    self.y = y

    self.console:addLine(0.02, '')
    self.console:addLine(0.04, '~ press ;ESC, to exit')
    self.console:addLine(0.06, '    ;fullscreened: ' .. tostring(fullscreen) .. ',')
    self.console:addLine(0.08, '')
    self.console.timer:after(0.14, function() 
        self.active = true 
        self.fullscreen_line = self.console.lines[#self.console.lines - 1]
    end)

    self.selection_width = self.console.font:getWidth('fullscreened: ' .. tostring(fullscreen))
end

function FullscreenModule:update(dt)
    if not self.active then return end

    if input:pressed('left') or input:pressed('right') or input:pressed('return') then
        self.fullscreen_line:replace(tostring(fullscreen), tostring(not fullscreen))
        fullscreen = not fullscreen
        if fullscreen then love.window.setMode(sx*gw, sy*gh, {fullscreen = true, borderless = true, fullscreentype = "desktop", display = display})
        else love.window.setMode(sx*gw, sy*gh, {display = display}) end
        self.selection_width = self.console.font:getWidth('fullscreened: ' .. tostring(fullscreen))
    end

    if input:pressed('escape') then
        self.active = false
        self.console:addInputLine(0.02, '[;root,]arch~ ')
    end
end

function FullscreenModule:draw()
    if not self.active then return end

    local r, g, b = unpack(skill_point_color)
    love.graphics.setColor(r, g, b, 128)
    local x_offset = self.console.font:getWidth('    ')
    love.graphics.rectangle('fill', 8 + x_offset - 2, self.y + 12 + 17, self.selection_width + 4, self.console.font:getHeight())
    love.graphics.setColor(255, 255, 255, 255)
end
