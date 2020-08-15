ScoreScreen = Object:extend()

function ScoreScreen:new(stage)
    self.stage = stage
    self.font = fonts.Anonymous_8
    
end

function ScoreScreen:update(dt)
    if input:pressed('return') or input:pressed('escape') then timer:after(0.15, function() gotoRoom('Console') end) end
    if input:pressed('restart') then 
        timer:after(0.15, function() gotoRoom('Stage') end)
    end
end

function ScoreScreen:draw()
    love.graphics.setFont(self.font)

    love.graphics.setColor(default_color)
    love.graphics.print('DEVICE: ' .. device, gw/2, gh/2 - 30, 0, 1, 1, math.floor(self.font:getWidth('DEVICE: ' .. device)/2), 0)
    love.graphics.print('SCORE: ' .. score, gw/2, gh/2 - 20, 0, 1, 1, math.floor(self.font:getWidth('SCORE: ' .. score)/2), 0)
    love.graphics.print('HIGH SCORE: ' .. high_score, gw/2, gh/2 - 10, 0, 1, 1, math.floor(self.font:getWidth('HIGH SCORE: ' .. high_score)/2), 0)
    love.graphics.print('DIFFICULTY REACHED: ' .. self.stage.difficulty_reached, 
    gw/2, gh/2, 0, 1, 1, math.floor(self.font:getWidth('DIFFICULTY REACHED: ' .. self.stage.difficulty_reached)/2), 0)
    local gained_sp = skill_points - self.stage.start_sp
    love.graphics.print('SP GAINED: ' .. gained_sp, gw/2, gh/2 + 10, 0, 1, 1, math.floor(self.font:getWidth('SP GAINED: ' .. gained_sp)/2), 0)

    love.graphics.print('PRESS ENTER TO GO TO CONSOLE', gw/2, gh/2 + 30, 0, 1, 1, math.floor(self.font:getWidth('PRESS ENTER TO GO TO CONSOLE')/2), 0)
    love.graphics.print('PRESS Q TO QUICK RESTART', gw/2, gh/2 + 40, 0, 1, 1, math.floor(self.font:getWidth('PRESS R TO QUICK RESTART')/2), 0)
end
