Achievements = Object:extend()

function Achievements:new()
    self.timer = Tim()
    self.area = Area(self)

    self.x, self.y = 15, 15
    self.camera = Cam(gw/2, gh/2, gw, gh)
    self.target_x = gw/2
    
    self.font = fonts.Anonymous_8
    self.big_font = fonts.m5x7_16
    self.main_canvas = love.graphics.newCanvas(gw, gh)
    self.final_canvas = love.graphics.newCanvas(gw, gh)
    self.glitch_canvas = love.graphics.newCanvas(gw, gh)
    self.y_offsets = {['Fighter'] = -2, ['Crusader'] = 0, ['Rogue'] = -2, ['Bit Hunter'] = 0, ['Sentinel'] = 0, ['Striker'] = 0, ['Nuclear'] = 0, ['Cycler'] = 0, ['Wisp'] = 0}
    self.achievement_index = 1

    self.timer:every({0.1, 0.2}, function() self.area:addGameObject('GlitchDisplacement') end)
    
    self.device_vertices = {
        ['Fighter'] = {
            ['vertice_groups'] = {
                [1] = {
                    12, 0,
                    12/2, -12/2,
                    -12/2, -12/2,
                    -12, 0,
                    -12/2, 12/2,
                    12/2, 12/2,
                },

                [2] = {
                    12/2, -12/2,
                    0, -12,
                    -12 - 12/2, -12,
                    -3*12/4, -12/4,
                    -12/2, -12/2,
                },
                
                [3] = {
                    12/2, 12/2,
                    -12/2, 12/2,
                    -3*12/4, 12/4,
                    -12 - 12/2, 12,
                    0, 12,
                }
            }
        },

        ['Crusader'] = {
            ['vertice_groups'] = {
                [1] = {
                    12, 0,
                    12/2, 12/2,
                    -12/4, 12/2,
                    -12/2, 12/4,
                    -12/2, -12/4,
                    -12/4, -12/2,
                    12/2, -12/2,
                },

                [2] = {
                    12/2, 12/2,
                    12/2, 12,
                    -12/2, 12,
                    -12, 12/2,
                    -12, 0,
                    -12/2, 0,
                    -12/2, 12/4,
                    -12/4, 12/2,
                },

                [3] = {
                    12/2, -12/2,
                    12/2, -12,
                    -12/2, -12,
                    -12, -12/2,
                    -12, 0,
                    -12/2, 0,
                    -12/2, -12/4,
                    -12/4, -12/2,
                },
            }
        },

        ['Rogue'] = {
            ['vertice_groups'] = {
                [1] = {
                    12, 0,
                    0, -12/2,
                    -12, 0,
                    0, 12/2,
                },

                [2] = {
                    12/2, -12/4,
                    12/4, -3*12/4,
                    -12 - 12/2, -2*12,
                    -12/2, -12/4,
                    0, -12/2,
                },

                [3] = {
                    12/2, 12/4,
                    0, 12/2,
                    -12/2, 12/4,
                    -12 - 12/2, 2*12,
                    12/4, 3*12/4,
                },
            }
        },

        ['Bit Hunter'] = {
            ['vertice_groups'] = {
                [1] = {
                    12, 0,
                    12/2, -12/2,
                    -12, -12/2,
                    -12/2, 0,
                    -12, 12/2,
                    12/2, 12/2,
                }
            }
        },

        ['Sentinel'] = {
            ['vertice_groups'] = {
                [1] = {
                    12, 0,
                    0, -12,
                    -3*12/4, -3*12/4,
                    -12, 0,
                    -3*12/4, 3*12/4,
                    0, 12,
                }
            }
        },

        ['Striker'] = {
            ['vertice_groups'] = {
                [1] = {
                    12, 0,
                    12/2, -12/2,
                    -12/2, -12/2,
                    -12, 0,
                    -12/2, 12/2,
                    12/2, 12/2,
                },

                [2] = {
                    0, 12/2,
                    -12/4, 12,
                    0, 12 + 12/2,
                    12, 12,
                    0, 2*12,
                    -12/2, 12 + 12/2,
                    -12, 0,
                    -12/2, 12/2,
                },

                [3] = {
                    0, -12/2,
                    -12/4, -12,
                    0, -12 - 12/2,
                    12, -12,
                    0, -2*12,
                    -12/2, -12 - 12/2,
                    -12, 0,
                    -12/2, -12/2,
                },
            }
        },

        ['Nuclear'] = {
            ['vertice_groups'] = {
                [1] = {
                    12, -12/4,
                    12, 12/4,
                    12 - 12/4, 12/2,
                    -12 + 12/4, 12/2,
                    -12, 12/4,
                    -12, -12/4,
                    -12 + 12/4, -12/2,
                    12 - 12/4, -12/2,
                }
            }
        },

        ['Cycler'] = {
            ['vertice_groups'] = {
                [1] = {
                    12, 0,
                    0, 12,
                    -12, 0,
                    0, -12,
                }
            }
        },

        ['Wisp'] = {
            ['vertice_groups'] = {
                [1] = {
                    12, -12/4,
                    12, 12/4,
                    12/4, 12,
                    -12/4, 12,
                    -12, 12/4,
                    -12, -12/4,
                    -12/4, -12,
                    12/4, -12,
                }
            }
        }
    }

end

function Achievements:update(dt)
    self.timer:update(dt)
    self.area:update(dt)
    self.camera:update(dt)
    self.camera:follow(self.target_x, gh/2)
    self.camera:setFollowStyle(nil)

    local pmx, pmy = love.mouse.getPosition()
    local text = 'CONSOLE'
    local w = self.font:getWidth(text)
    local x, y = gw - w - 15, 5
    if (pmx >= sx*x and pmx <= sx*(x + w + 10) and pmy >= sy*y and pmy <= sy*(y + 16) and input:pressed('left_click')) or input:pressed('escape') then
        save()
        playMenuBack()
        gotoRoom('Console')
    end

    if input:down('left', 0.05, 0.25) then
        if self.achievement_index > 1 then
            self.achievement_index = self.achievement_index - 1
            self.timer:tween(0.1, self, {target_x = gw/2 + (self.achievement_index-1)*80}, 'in-out-cubic', 'camera_target')
            playMenuSwitch()
        end
    end

    if input:down('right', 0.05, 0.25) then
        if self.achievement_index < #achievement_names then
            self.achievement_index = self.achievement_index + 1
            self.timer:tween(0.1, self, {target_x = gw/2 + (self.achievement_index-1)*80}, 'in-out-cubic', 'camera_target')
            playMenuSwitch()
        end
    end
end

function Achievements:draw()
    love.graphics.setCanvas(self.glitch_canvas)
    love.graphics.clear()
        love.graphics.setColor(127, 127, 127)
        love.graphics.rectangle('fill', 0, 0, gw, gh)
        love.graphics.setColor(255, 255, 255)
        self.area:drawOnly({'glitch'})
    love.graphics.setCanvas()

    love.graphics.setFont(self.font)
    love.graphics.setCanvas(self.main_canvas)
        love.graphics.clear()
        love.graphics.setColor(default_color)
        love.graphics.print('~ ACHIEVEMENTS:', 8, 10)

        local pmx, pmy = love.mouse.getPosition()
        local text = 'CONSOLE'
        local w = self.font:getWidth(text)
        local x, y = gw - w - 15, 5
        love.graphics.setColor(0, 0, 0, 222)
        love.graphics.rectangle('fill', x, y, w + 10, 16) 
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.print(text, x + 5, y + 3)
        if pmx >= sx*x and pmx <= sx*(x + w + 10) and pmy >= sy*y and pmy <= sy*(y + 16) then love.graphics.rectangle('line', x, y, w + 10, 16) end

        self.camera:attach()
        for i, achievement in ipairs(achievement_names) do
            self:drawAchievement(gw/2 + (i-1)*80, gh/2, achievement, i == self.achievement_index)
        end
        self.camera:detach()
    love.graphics.setCanvas()

    love.graphics.setCanvas(self.final_canvas)
    love.graphics.clear()
        love.graphics.setColor(255, 255, 255)
        love.graphics.setBlendMode("alpha", "premultiplied")
        love.graphics.setShader(shaders.glitch)
        shaders.glitch:send('glitch_map', self.glitch_canvas)
        love.graphics.draw(self.main_canvas, 0, 0, 0, 1, 1)
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

function Achievements:drawAchievement(x, y, achievement_name, active)
    BSGRectangle('line', x - 32, y - 32, 64, 64, 8, 8)

    y = y - 20
    local name = ''
    local color = nil
    if achievement_name:find('Reroll') then name = 'RR'; color = hp_color end
    if achievement_name:find('Escape') then name = 'WIN'; color = skill_point_color end
    if achievement_name:find('10K') then name = '10K'; color = ammo_color end
    if achievement_name:find('50K') then name = '50K'; color = ammo_color end
    if achievement_name:find('100K') then name = '100K'; color = boost_color end
    if achievement_name:find('500K') then name = '500K'; color = hp_color end
    if achievement_name:find('1KK') then name = '1KK'; color = skill_point_color end
    if achievements[achievement_name] then love.graphics.setColor(color) end
    love.graphics.print(name, x, y, 0, 2, 2, math.floor(self.font:getWidth(name)/2), math.floor(self.font:getHeight()/2))

    y = y + 28 
    local device = ''
    if achievement_name:find('Fighter') then device = 'Fighter' end
    if achievement_name:find('Crusader') then device = 'Crusader' end
    if achievement_name:find('Rogue') then device = 'Rogue' end
    if achievement_name:find('Bit Hunter') then device = 'Bit Hunter' end
    if achievement_name:find('Sentinel') then device = 'Sentinel' end
    if achievement_name:find('Striker') then device = 'Striker' end
    if achievement_name:find('Nuclear') then device = 'Nuclear' end
    if achievement_name:find('Cycler') then device = 'Cycler' end
    if achievement_name:find('Wisp') then device = 'Wisp' end
    if device == '' then goto continue end
    y = y + self.y_offsets[device]
    love.graphics.setColor(default_color)
    pushRotateScale(x, y, -math.pi/2)
    for _, vertice_group in ipairs(self.device_vertices[device].vertice_groups) do
        local points = fn.map(vertice_group, function(k, v) 
            if k % 2 == 1 then return x + v + random(-1, 1) else return y + v + random(-1, 1) end 
        end)
        love.graphics.polygon('line', points)
    end
    love.graphics.pop()

    y = y - self.y_offsets[device]
    ::continue::

    if achievement_name == 'Reroll Build' then
        love.graphics.line(x - 16 + 4, y - 8, x + 4, y + 8)
        love.graphics.setColor(background_color)
        love.graphics.rectangle('fill', x - 4 - 16 + 4, y - 4 - 8, 8, 8)
        love.graphics.rectangle('fill', x - 4 + 4, y - 4 + 8, 8, 8)
        love.graphics.rectangle('fill', x - 4 - 12 + 12 + 4, y - 4 - 8, 16, 8)
        love.graphics.setColor(default_color)
        love.graphics.rectangle('line', x - 4 - 16 + 4, y - 4 - 8, 8, 8)
        love.graphics.rectangle('line', x - 4 + 4, y - 4 + 8, 8, 8)
        love.graphics.rectangle('line', x - 4 - 12 + 12 + 4, y - 4 - 8, 16, 8)

    elseif achievement_name == 'Reroll Skills' then
        love.graphics.line(x - 16, y - 8, x + 16, y - 8)
        love.graphics.line(x - 16, y - 8, x, y + 8)
        love.graphics.line(x + 16, y - 8, x, y + 8)
        love.graphics.setColor(background_color)
        love.graphics.rectangle('fill', x - 4 - 16, y - 4 - 8, 8, 8)
        love.graphics.rectangle('fill', x - 4 + 16, y - 4 - 8, 8, 8)
        love.graphics.rectangle('fill', x - 4, y - 4 + 8, 8, 8)
        love.graphics.setColor(default_color)
        love.graphics.rectangle('line', x - 4 - 16, y - 4 - 8, 8, 8)
        love.graphics.rectangle('line', x - 4 + 16, y - 4 - 8, 8, 8)
        love.graphics.rectangle('line', x - 4, y - 4 + 8, 8, 8)

    elseif achievement_name == 'Reroll Classes' then
        love.graphics.setColor(background_color)
        love.graphics.rectangle('fill', x - 4 - 12, y - 4 - 4, 16, 8)
        love.graphics.rectangle('fill', x - 4 + 4, y - 4 - 4, 16, 8)
        love.graphics.rectangle('fill', x - 4 + 4, y - 4 + 4, 16, 8)
        love.graphics.setColor(default_color)
        love.graphics.rectangle('line', x - 4 - 12, y - 4 - 4, 16, 8)
        love.graphics.rectangle('line', x - 4 + 4, y - 4 - 4, 16, 8)
        love.graphics.rectangle('line', x - 4 + 4, y - 4 + 4, 16, 8)

    elseif achievement_name == 'Escape' then
        love.graphics.setColor(default_color)
        love.graphics.print('escape', x - 1, y, 0, 1, 1, math.floor(self.font:getWidth('escape')/2), math.floor(self.font:getHeight()/2))
        local r, g, b = unpack(default_color)
        love.graphics.setColor(r, g, b, 96)
        love.graphics.rectangle('fill', x + 16 - math.floor(self.font:getWidth('w')/2), y - math.floor(self.font:getHeight()/2), self.font:getWidth('w'), self.font:getHeight())
        love.graphics.setColor(r, g, b, 255)
    end

    love.graphics.setColor(default_color)

    if active then
        y = y + 36
        if achievements[achievement_name] then 
            love.graphics.setColor(ammo_color)
            love.graphics.print('UNLOCKED', x, y, 0, 1, 1, math.floor(self.font:getWidth('UNLOCKED')/2), math.floor(self.font:getHeight()/2))
        else 
            love.graphics.setColor(hp_color)
            love.graphics.print('LOCKED', x, y, 0, 1, 1, math.floor(self.font:getWidth('LOCKED')/2), math.floor(self.font:getHeight()/2)) 
        end
        love.graphics.setColor(default_color)

        y = y + 16
        love.graphics.print(achievement_descriptions[achievement_name], x, y, 0, 1, 1, math.floor(self.font:getWidth(achievement_descriptions[achievement_name])/2), math.floor(self.font:getHeight()/2))
    end
end

function Achievements:destroy()
    
end
