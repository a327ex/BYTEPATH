Classes = Object:extend()

function Classes:new()
    self.timer = Timer()
    self.area = Area(self)
    
    self.font = fonts.Anonymous_8
    self.main_canvas = love.graphics.newCanvas(gw, gh)
    self.final_canvas = love.graphics.newCanvas(gw, gh)
    self.temp_canvas = love.graphics.newCanvas(gw, gh)
    self.glitch_canvas = love.graphics.newCanvas(gw, gh)
    self.rgb_shift_mag = 0

    self.classes = {
        [1] = {'Gunner', 'Tanker', 'Runner', 'Cycler'},
        [2] = {'Buster', 'Buffer', 'Berserker', 'Shielder', 'Regeneer', 'Recycler', 'Absorber', 'Turner', 'Driver', 'Swapper', 'Barrager', 'Seeker'},
        [3] = {'Buster', 'Buffer', 'Berserker', 'Shielder', 'Regeneer', 'Recycler', 'Absorber', 'Turner', 'Driver', 'Swapper', 'Barrager', 'Seeker'},
        [4] = {'Buster', 'Buffer', 'Berserker', 'Shielder', 'Regeneer', 'Recycler', 'Absorber', 'Turner', 'Driver', 'Swapper', 'Barrager', 'Seeker'},
        [5] = {'Repeater', 'Launcher', 'Panzer', 'Reserver', 'Deployer', 'Booster', 'Processor', 'Gambler'},
        [6] = {'Repeater', 'Launcher', 'Panzer', 'Reserver', 'Deployer', 'Booster', 'Processor', 'Gambler'},
        [7] = {'Discharger', 'Hoamer', 'Splitter', 'Spinner', 'Bouncer', 'Blaster', 'Raider', 'Waver', 'Bomber', 'Zoomer', 'Racer', 'Miner'},
        [8] = {'Discharger', 'Hoamer', 'Splitter', 'Spinner', 'Bouncer', 'Blaster', 'Raider', 'Waver', 'Bomber', 'Zoomer', 'Racer', 'Miner'},
        [9] = {'Piercer', 'Dasher', 'Engineer', 'Threader'},
    }

    for _, class in ipairs(classes) do
        for i = 1, 9 do
            for j = #self.classes[i], 1, -1 do
                if class == self.classes[i][j] then
                    table.remove(self.classes[i], j)
                end
            end
        end
    end

    self.class_colors = { 
        ['Gunner'] = ammo_color, ['Tanker'] = hp_color, ['Runner'] = boost_color, ['Cycler'] = default_color,
        ['Buster'] = ammo_color, ['Buffer'] = ammo_color, ['Berserker'] = ammo_color, ['Shielder'] = hp_color,
        ['Regeneer'] = hp_color, ['Recycler'] = hp_color, ['Absorber'] = boost_color, ['Turner'] = boost_color,
        ['Driver'] = boost_color, ['Swapper'] = default_color, ['Barrager'] = default_color, ['Seeker'] = default_color,
        ['Repeater'] = ammo_color, ['Launcher'] = ammo_color, ['Panzer'] = hp_color, ['Reserver'] = hp_color, 
        ['Deployer'] = boost_color, ['Booster'] = boost_color, ['Processor'] = default_color, ['Gambler'] = default_color,
        ['Discharger'] = boost_color, ['Hoamer'] = skill_point_color, ['Splitter'] = boost_color, ['Bouncer'] = default_color,
        ['Blaster'] = default_color, ['Raider'] = skill_point_color, ['Waver'] = ammo_color, ['Bomber'] = hp_color, ['Zoomer'] = boost_color,
        ['Racer'] = boost_color, ['Miner'] = ammo_color, ['Piercer'] = ammo_color, ['Dasher'] = boost_color, ['Engineer'] = hp_color, ['Threader'] = default_color
    }

    self.class_info = {
        ['Gunner'] = {
            'CLASS: GUNNER',
            '',
            '+15% ASPD',
            '+25% PSPD',
        },

        ['Tanker'] = {
            'CLASS: TANKER',
            '',
            '+25% HP',
            '+25% Ammo',
        },

        ['Runner'] = {
            'CLASS: RUNNER',
            '',
            '+25% MVSPD',
            '+25% Boost',
        },

        ['Cycler'] = {
            'CLASS: CYCLER',
            '',
            '+25% Luck',
            '+25% Cycle Speed',
        },

        ['Buster'] = {
            'CLASS: BUSTER',
            '',
            '+50% Projectile Size',
            '+25% Projectile Duration',
            '-15% HP',
            '-15% ASPD',
        },

        ['Buffer'] = {
            'CLASS: BUFFER',
            '',
            '+50% Stat Boost Duration',
            '-20% Boost',
        },

        ['Berserker'] = {
            'CLASS: BERSERKER',
            '',
            'Consecutive kills grant you RAMPAGE',
            'RAMPAGE grants you buffs as it grows',
            'RAMPAGE grants you +1% ASPD per 10',
            'RAMPAGE grants you +1% PSPD per 10',
            '-25% Luck',
        },

        ['Shielder'] = {
            'CLASS: SHIELDER',
            '',
            '+25% Shield Projectile Chance',
            '+25% Projectile Duration',
            '-25% Shield Projectile Damage',
        },

        ['Regeneer'] = {
            'CLASS: REGENEER',
            '',
            'Restores 25 HP on Item Pickup',
            '-15% MVSPD',
        },

        ['Recycler'] = {
            'CLASS: RECYCLER',
            '',
            'When ammo reaches 0:',
            '    Create a protective barrier that',
            '    protects for the next (AMMO/50)',
            '    projectile hits',
            '+50% Ammo Consumption',
        },

        ['Absorber'] = {
            'CLASS: ABSORBER',
            '',
            'Absorbs hits',
            'Absorbed projectiles consume 25 boost',
            'Absorbed hits consume 50 boost',
            'Cannot absorb without enough boost',
        },

        ['Turner'] = {
            'CLASS: TURNER',
            '',
            'Boosting up increases turn rate',
            'Boosting down decreases turn rate',
        },

        ['Driver'] = {
            'CLASS: DRIVER',
            '',
            '+30% Invulnerability Time',
            '+30% Boost Recharge Rate',
            '+30% Size',
        },

        ['Swapper'] = {
            'CLASS: SWAPPER',
            '',
            'Gain a buff when attack is changed',
            '-10% HP',
            '-10% Ammo',
            '-10% MVSPD',
            '-10% PSPD',
        },

        ['Barrager'] = {
            'CLASS: BARRAGER',
            '',
            '+5% Barrage on Kill Chance',
            '+10% Barrage on Cycle Chance',
            '+2 Barrage Projectiles',
            "Can't Launch Homing Projectiles",
            '-25% ASPD',
        },

        ['Seeker'] = {
            'CLASS: SEEKER',
            '',
            '+10% Launch Homing Proj on Kill Chance',
            '+5% Launch Homing Proj on Cycle Chance',
            '+1 Homing Projectile',
            "Can't Barrage",
            '-25% ASPD',
        },

        ['Processor'] = {
            'CLASS: PROCESSOR',
            '',
            '+50% Cycle Speed',
            '-25% HP',
            '-50% Spawn SP Chance',
        },

        ['Gambler'] = {
            'CLASS: GAMBLER',
            '',
            '+50% Luck',
            "Can't trigger \"On Cycle\" events",
        },

        ['Panzer'] = {
            'CLASS: PANZER',
            '',
            '+50% HP',
            '+50% Size',
            '-25% MVSPD',
        },

        ['Reserver'] = {
            'CLASS: RESERVER',
            '',
            'When ammo reaches 0:',
            '    Change to new attack',
            '+50% Ammo',
            '-25% ASPD',
        },

        ['Repeater'] = {
            'CLASS: REPEATER',
            '',
            '+50% ASPD',
            '-25% Damage',
        },

        ['Launcher'] = {
            'CLASS: LAUNCHER',
            '',
            '+75% PSPD',
            '+25% Projectile Duration',
            '-20% HP',
            '-20% Ammo',
        },

        ['Deployer'] = {
            'CLASS: DEPLOYER',
            '',
            '+25% MVSPD',
            '-25% Size',
            '+25% Chance to Drop Mines',
        },

        ['Booster'] = {
            'CLASS: BOOSTER',
            '',
            '+50% Boost',
            '-25% Ammo',
            '-25% Luck',
        },

        ['Discharger'] = {
            'CLASS: DISCHARGER',
            '',
            '+2 Lightning Bolts',
            '+50% Lightning Trigger Distance',
            'Lightning Targets Projectiles',
        },

        ['Hoamer'] = {
            'CLASS: HOAMER',
            '',
            '+50% Homing Speed',
            '+1 Homing Projectile',
            '+10% Chance to Attack Twice',
        },

        ['Splitter'] = {
            'CLASS: SPLITTER',
            '',
            '+15% Split Projectile Split Chance',
            '+25% PSPD',
        },

        ['Spinner'] = {
            'CLASS: SPINNER',
            '',
            '+50% Chance to Create Spin Proj on Expiration',
            '+25% Projectile Duration',
        },

        ['Bouncer'] = {
            'CLASS: BOUNCER',
            '',
            '+4 Bounce to Bounce Projectiles',
            '-50% PSPD',
        },

        ['Blaster'] = {
            'CLASS: BLASTER',
            '',
            '+8 Blast Projectiles',
            'If Blast Projs are Shield Projs:',
            '    +500% Projectile Duration',
        },

        ['Raider'] = {
            'CLASS: RAIDER',
            '',
            '+50% Luck to SP Related Passives',
            '+100% Chance to Spawn SP',
        },

        ['Waver'] = {
            'CLASS: WAVER',
            '',
            '+50% Projectile Waviness',
            '+50% Projectile Angle Change Frequency',
        },

        ['Bomber'] = {
            'CLASS: BOMBER',
            '',
            '+25% Area',
            '+25% Chance to Attack Twice',
        },

        ['Zoomer'] = {
            'CLASS: ZOOMER',
            '',
            '+30% MVSPD',
            '-30% Size',
        },

        ['Racer'] = {
            'CLASS: RACER',
            '',
            'Ammo gives Boost instead',
            '-50% Ammo',
        },

        ['Miner'] = {
            'CLASS: MINER',
            '',
            '+50% Resource Spawn Rate',
            '+25% Item Spawn Rate',
        },

        ['Piercer'] = {
            'CLASS: PIERCER',
            '',
            '+2 Projectile Pierce',
            '-15% HP',
            '-15% Ammo',
            '-15% Boost',
            '-15% MVSPD',
            '-15% ASPD',
        },

        ['Dasher'] = {
            'CLASS: DASHER',
            '',
            'Boosting forward twice dashes forward',
            'Become invulnerable for 1s after dash',
            'Dash consumes 50 boost',
            'Creates 10 explosions after dash',
        },

        ['Engineer'] = {
            'CLASS: ENGINEER',
            '',
            '2 drones follow the player',
            "Drones inherit player's passives",
            'Drones are invulnerable',
            'Drones have +50% ASPD',
            'Drones deal -50% damage',
            '-50% Ammo',
        },

        ['Threader'] = {
            'CLASS: THREADER',
            '',
            'Adds 3 additional cycles',
            'Each cycle has:',
            '    -53% Cycle Speed',
            '    -78% Cycle Speed',
            '    -94% Cycle Speed',
        },
    }

    self.selection_index = 1

    self.timer:every(0.1, function() 
        self.area:addGameObject('GlitchDisplacement') 
    end)
end

function Classes:update(dt)
    self.timer:update(dt)
    self.area:update(dt)

    -- Console
    local pmx, pmy = love.mouse.getPosition()
    local text = 'CONSOLE'
    local w = self.font:getWidth(text)
    local x, y = gw - w - 15, 5
    if (pmx >= sx*x and pmx <= sx*(x + w + 10) and pmy >= sy*y and pmy <= sy*(y + 16) and input:pressed('left_click')) or input:pressed('escape') then
        save()
        playMenuBack()
        gotoRoom('Console')
    end

    local n = 3
    if rank == 1 then n = 4 end
    if rank >= 2 and rank <= 4 then n = 3 end
    if rank >= 5 and rank <= 6 then n = 2 end
    if rank >= 7 and rank <= 8 then n = 4 end
    if rank == 9 then n = 4 end
    if rank == 10 then return end

    if input:pressed('left') then
        self.selection_index = self.selection_index - 1
        if self.selection_index == 0 or self.selection_index == n or self.selection_index == 2*n or self.selection_index == 3*n then 
            self.selection_index = self.selection_index + n
            if self.selection_index > #self.classes[rank] then self.selection_index = #self.classes[rank] end
        end
        playMenuSwitch()
        self:changedIndex()
    end
    if input:pressed('right') then
        self.selection_index = self.selection_index + 1
        if self.selection_index == n+1 or self.selection_index == 2*n+1 or self.selection_index == 3*n+1 then self.selection_index = self.selection_index - n
        elseif self.selection_index > #self.classes[rank] then
            if rank >= 1 and rank <= n then self.selection_index = 1
            elseif rank >= n+1 and rank <= 2*n then self.selection_index = n+1
            elseif rank >= 2*n+1 and rank <= 3*n then self.selection_index = 2*n+1
            elseif rank >= 3*n+1 and rank <= #self.classes[rank] then self.selection_index = 3*n+1 end
        end
        playMenuSwitch()
        self:changedIndex()
    end
    if input:pressed('up') then
        self.selection_index = self.selection_index - n
        if self.selection_index < 1 then 
            self.selection_index = #self.classes[rank] + self.selection_index
            if self.selection_index > #self.classes[rank] then self.selection_index = #self.classes[rank] end
        end
        playMenuSwitch()
        self:changedIndex()
    end
    if input:pressed('down') then
        self.selection_index = self.selection_index + n
        if self.selection_index > #self.classes[rank] then 
            self.selection_index = self.selection_index - #self.classes[rank]
            if self.selection_index < 1 then self.selection_index = 1 end
        end
        playMenuSwitch()
        self:changedIndex()
    end

    if input:pressed('return') then
        if skill_points >= rank*5 then
            skill_points = skill_points - rank*5
            spent_sp = spent_sp + rank*5
            if rank == 2 or rank == 3 or rank == 4 then
                classes[rank] = table.remove(self.classes[2], self.selection_index)
                classes[rank] = table.remove(self.classes[3], self.selection_index)
                classes[rank] = table.remove(self.classes[4], self.selection_index)
            elseif rank == 5 or rank == 6 then
                classes[rank] = table.remove(self.classes[5], self.selection_index)
                classes[rank] = table.remove(self.classes[6], self.selection_index)
            elseif rank == 7 or rank == 8 then
                classes[rank] = table.remove(self.classes[7], self.selection_index)
                classes[rank] = table.remove(self.classes[8], self.selection_index)
            else
                classes[rank] = table.remove(self.classes[rank], self.selection_index)
            end
            rank = rank + 1
            self.selection_index = 1
            playMenuSelect()
            self:rgbShift()
        else
            self.cant_buy_error = 'NOT ENOUGH SKILL POINTS'
            self.timer:after(0.5, function() self.cant_buy_error = false end)
            playMenuError()
            self:glitchError()
        end
    end
end

function Classes:draw()
    love.graphics.setCanvas(self.glitch_canvas)
    love.graphics.clear()
        love.graphics.setColor(127, 127, 127)
        love.graphics.rectangle('fill', 0, 0, gw, gh)
        love.graphics.setColor(255, 255, 255)
        self.area:drawOnly({'glitch'})
    love.graphics.setCanvas()

    love.graphics.setCanvas(self.rgb_canvas)
    love.graphics.clear()
    	camera:attach(0, 0, gw, gh)
        love.graphics.setColor(127, 127, 127)
        love.graphics.rectangle('fill', 0, 0, gw, gh)
        love.graphics.setColor(255, 255, 255)
    	self.area:drawOnly({'rgb'})
    	camera:detach()
    love.graphics.setCanvas()

    love.graphics.setFont(self.font)
    love.graphics.setCanvas(self.main_canvas)
    love.graphics.clear()

    --[[
    love.graphics.line(8 + gw/2 + 32, 0, 8 + gw/2 + 32, gh)
    love.graphics.line(8 + gw/2 + 32 + 4, 0, 8 + gw/2 + 32 + 4, gh)
    ]]--

    local drawNormalButton = function(x, y, w, h, text, color)
        drawCenteredRectangle('fill', x, y, w, h, {16, 16, 16})
        drawCenteredRectangle('line', x, y, w, h, {4, 4, 4})
        printCenteredText(text, x, y, self.font, color)
    end

    local drawInvertedButton = function(x, y, w, h, text, color)
        drawCenteredRectangle('fill', x, y, w, h, {222, 222, 222})
        drawCenteredRectangle('line', x, y, w, h, {255, 255, 255})
        printCenteredText(text, x, y, self.font, {16, 16, 16})
    end

    -- for i = 1, 9 do love.graphics.rectangle('line', 8, 50 + (i-1)*24, gw/2 + gw/6, 20) end
    for i = 1, rank do 
        if i == 10 then goto continue end
        local n = 3
        if i == 1 then n = 4 end
        if i >= 2 and i <= 4 then n = 3 end
        if i >= 5 and i <= 6 then n = 2 end
        if i >= 7 and i <= 8 then n = 4 end
        if i == 9 then n = 4 end
        local y = 28 + (i-1)*24 + 10
        drawNormalButton(8 + 24, y, 48, 16, 'Rank ' .. i, default_color) 
        if not classes[i] then drawNormalButton(8 + 24 + 56, y, 64, 16, 'COST: ' .. tostring(rank*5) .. 'SP', skill_point_color) end
        if classes[i] then drawNormalButton(8 + 24 + 48, y, 48, 16, classes[i], self.class_colors[classes[i]])
        else
            for j = 1, #self.classes[i] do
                if self.selection_index == j then drawInvertedButton(92 + 60 + ((j-1) % n)*48, y + (math.ceil(j/n)-1)*24, 48, 16, self.classes[i][j])
                else drawNormalButton(92 + 60 + ((j-1) % n)*48, y + (math.ceil(j/n)-1)*24, 48, 16, self.classes[i][j], self.class_colors[self.classes[i][j]]) end
            end
        end
    end
    ::continue::

    if self.visible then
        if rank < 10 then
            local offset = 0
            if rank == 1 then offset = 48 end
            local x, y = offset + 8 + gw/2 + 32 + 12, 38
            for i, line in ipairs(self.class_info[self.classes[rank][self.selection_index]]) do
                love.graphics.print(line, x, y + 12*(i-1), 0, 1, 1, 0, self.font:getHeight()/2)
            end
        end
    end

    -- Console button
    local pmx, pmy = love.mouse.getPosition()
    local text = 'CONSOLE'
    local w = self.font:getWidth(text)
    local x, y = gw - w - 15, 5
    love.graphics.setColor(0, 0, 0, 222)
    love.graphics.rectangle('fill', x, y, w + 10, 16) 
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.print(text, x + 5, y + 3)
    if pmx >= sx*x and pmx <= sx*(x + w + 10) and pmy >= sy*y and pmy <= sy*(y + 16) then love.graphics.rectangle('line', x, y, w + 10, 16) end

    love.graphics.setColor(default_color)
    love.graphics.print('~ CLASSES:', 8, 10)
    love.graphics.setColor(skill_point_color)
    love.graphics.print('~ SP: ' .. tostring(skill_points), 8, gh - 20)
    love.graphics.setColor(default_color)

    -- Can't buy
    if self.cant_buy_error then
        local text = self.cant_buy_error
        local w = self.font:getWidth(text)
        local x, y = gw/2 - w/2 - 5, gh/2 - 12
        love.graphics.setColor(hp_color)
        love.graphics.rectangle('fill', x, y, w + 10, 24)
        love.graphics.setColor(background_color)
        love.graphics.print(text, math.floor(x + 5), math.floor(y + 8))
    end

    love.graphics.setColor(skill_point_color)
    love.graphics.print(skill_points .. 'SP', gw - 20, 26, 0, 1, 1, math.floor(self.font:getWidth(skill_points .. 'SP')/2), math.floor(self.font:getHeight()/2))
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

function Classes:destroy()
    
end

function Classes:changedIndex()
    self.timer:every(0.035, function() self.visible = not self.visible end, 5)
    self.timer:after(0.035*5 + 0.02, function() self.visible = true end)
end

function Classes:rgbShift()
    self.rgb_shift_mag = random(2, 4)
    self.timer:tween('rgb_shift', 0.25, self, {rgb_shift_mag = 0}, 'in-out-cubic')
end

function Classes:glitch(x, y)
    for i = 1, 6 do
        self.timer:after(0.1*i, function()
            self.area:addGameObject('GlitchDisplacement', x + random(-32, 32), y + random(-32, 32)) 
        end)
    end
end

function Classes:glitchError()
    for i = 1, 10 do self.timer:after(0.1*i, function() self.area:addGameObject('GlitchDisplacement') end) end
    self.rgb_shift_mag = random(4, 8)
    self.timer:tween('rgb_shift', 1, self, {rgb_shift_mag = 0}, 'in-out-cubic')
end
