AchievementScreenshots = Object:extend()

function AchievementScreenshots:new()
    self.font = fonts.Anonymous_8
    self.big_font = fonts.m5x7_16
    self.main_canvas = love.graphics.newCanvas(10*64, 10*64)

    self.active = true

    self.y_offsets = {['Fighter'] = -2, ['Crusader'] = 0, ['Rogue'] = -2, ['Bit Hunter'] = 0, ['Sentinel'] = 0, ['Striker'] = 0, ['Nuclear'] = 0, ['Cycler'] = 0, ['Wisp'] = 0}
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

function AchievementScreenshots:update(dt)
    if input:pressed('escape') then self.active = not self.active end
end

function AchievementScreenshots:draw()
    love.graphics.setFont(self.font)
    love.graphics.setCanvas(self.main_canvas)
    love.graphics.clear()
    love.graphics.setColor(default_color)
    local k = 1
    for i = 1, 4 do
        for j = 1, 10 do
            self:drawAchievement(32 + (j-1)*64, 32 + (i-1)*64, achievement_names[k])
            k = k + 1
        end
    end
    love.graphics.setCanvas()

    shaders.distort:send('time', time)
    shaders.distort:send('horzFuzzOpt', 0.2)
    love.graphics.setShader(shaders.distort)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.draw(self.main_canvas, 0, 0, 0, sx, sy)
    love.graphics.setBlendMode('alpha')
    love.graphics.setShader()
end

function AchievementScreenshots:drawAchievement(x, y, achievement_name, active)
    -- BSGRectangle('line', x - 32, y - 32, 64, 64, 8, 8)

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
    if self.active then love.graphics.setColor(color) end
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
end

function AchievementScreenshots:destroy()
    
end
