DeviceModule = Object:extend()

function DeviceModule:new(console, y)
    self.console = console
    self.x, self.y = gw/2, y + 100
    self.w, self.h = 160, 80

    self.console:addLine(0.02, '')
    self.console:addLine(0.04, '~ press @LEFT# or @RIGHT# to select devices')
    self.console:addLine(0.06, '~ press @ENTER# to unlock a device')
    self.console:addLine(0.08, '~ press @ESC# to exit')
    self.console:addLine(0.10, '')
    self.console:addLine(0.10, '')
    self.console:addLine(0.10, '')
    self.console:addLine(0.10, '')
    self.console:addLine(0.10, '')
    self.console:addLine(0.10, '')
    self.console:addLine(0.10, '')
    self.console:addLine(0.10, '')
    self.console:addLine(0.10, '')
    self.console:addLine(0.10, '')
    self.console:addLine(0.10, '')
    self.console:addLine(0.10, '')
    self.console:addLine(0.10, '')
    self.console:addLine(0.10, '')
    self.console:addLine(0.10, '')
    self.console:addLine(0.12, '~ ;SP: ' .. tostring(skill_points) .. ', / $CURRENT DEVICE: ' .. string.upper(device) .. '%')
    self.console.timer:after(0.14, function() 
        self.active = true 
        self.device_line = self.console.lines[#self.console.lines]
    end)

    self.sx, self.sy = 1, 1
    self.font = fonts.m5x7_16

    self.devices = {'Fighter', 'Crusader', 'Rogue', 'Bit Hunter', 'Sentinel', 'Striker', 'Nuclear', 'Cycler', 'Wisp'}

    self.device_stats = {
        ['Fighter'] = {attack = 1, defense = 1, luck = 1, mobility = 1, uniqueness = 1},
        ['Crusader'] = {attack = 0.6, defense = 1.6, luck = 1, mobility = 0.2, uniqueness = 1},
        ['Rogue'] = {attack = 1.4, defense = 0.2, luck = 1, mobility = 2, uniqueness = 1},
        ['Bit Hunter'] = {attack = 0.8, defense = 0.6, luck = 2, mobility = 0.6, uniqueness = 1},
        ['Sentinel'] = {attack = 1, defense = 1, luck = 1, mobility = 1, uniqueness = 2},
        ['Striker'] = {attack = 1.8, defense = 1, luck = 1, mobility = 1, uniqueness = 1.6},
        ['Nuclear'] = {attack = 0.8, defense = 0.4, luck = 2, mobility = 0.8, uniqueness = 1.4},
        ['Cycler'] = {attack = 1, defense = 1, luck = 1.4, mobility = 1, uniqueness = 1},
        ['Wisp'] = {attack = 0.8, defense = 0, luck = 1, mobility = 0.2, uniqueness = 1.6},
    }

    self.device_costs = {
        ['Fighter'] = 0,
        ['Crusader'] = 10,
        ['Rogue'] = 15,
        ['Bit Hunter'] = 20,
        ['Sentinel'] = 25,
        ['Striker'] = 30,
        ['Nuclear'] = 35,
        ['Cycler'] = 40,
        ['Wisp'] = 45,
    }

    self.device_y_offsets = {
        ['Fighter'] = -4,
        ['Crusader'] = 0,
        ['Rogue'] = -4,
        ['Bit Hunter'] = 0,
        ['Sentinel'] = 0,
        ['Striker'] = 0,
        ['Nuclear'] = 0,
        ['Cycler'] = 0,
        ['Wisp'] = 0,
    }

    self.device_descriptions = {
        ['Fighter'] = {
            'DEVICE: FIGHTER',
            '',
            '       Average All Stats'
        },

        ['Crusader'] = {
            'DEVICE: CRUSADER',
            '',
            '   ++  HP',
            '   --- Mobility',
            '   --- Attack Speed',
        },

        ['Rogue'] = {
            'DEVICE: ROGUE',
            '',
            '   +++ Mobility',
            '   ++  Attack Speed',
            '   --  Invulnerability Time',
            '   -   HP',
        },

        ['Bit Hunter'] = {
            'DEVICE: BIT HUNTER',
            '',
            '   +++ Luck',
            '   ++  Cycle Speed',
            '   ++  Invulnerability Time',
            '   -   All Other Stats',
        },

        ['Sentinel'] = {
            'DEVICE: SENTINEL',
            '',
            '       Energy Shield:',
            '          Takes Double Damage',
            '          HP Recharges',
            '          Half Invulnerability Time',
        },

        ['Striker'] = {
            'DEVICE: STRIKER',
            '',
            '   +++ Attack Speed',
            '   +++ Barrage',
            '   --- HP',
        },

        ['Nuclear'] = {
            'DEVICE: NUCLEAR',
            '',
            '   +++ Luck',
            '   +   Chance to Self Explode on Cycle',
            '   --  All Other Stats',
        },

        ['Cycler'] = {
            'DEVICE: CYCLER',
            '',
            '   +++ Cycle Speed',
        },

        ['Wisp'] = {
            'DEVICE: WISP',
            '',
            '   +++ Orbitting Projectiles',
            '   +++ Projectile Duration',
            '   --- All Other Stats',
        },
    }

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

    self.device_index = 1
end

function DeviceModule:update(dt)
    if not self.active then return end 

    if input:pressed('left') then
        self.device_index = self.device_index - 1
        if self.device_index == 0 then self.device_index = #self.devices end
        local current_device = self.devices[self.device_index]
        if fn.any(unlocked_devices, current_device) then
            self.device_line:replace(string.upper(device), string.upper(current_device))
            device = current_device
        end
        playMenuSwitch()
    end

    if input:pressed('right') then
        self.device_index = self.device_index + 1
        if self.device_index == #self.devices+1 then self.device_index = 1 end
        local current_device = self.devices[self.device_index]
        if fn.any(unlocked_devices, current_device) then
            self.device_line:replace(string.upper(device), string.upper(current_device))
            device = current_device
        end
        playMenuSwitch()
    end

    if input:pressed('return') then
        local current_device = self.devices[self.device_index]
        if not fn.any(unlocked_devices, current_device) then
            if skill_points >= self.device_costs[current_device] then
                self.device_line:replace(tostring(skill_points), tostring(skill_points - self.device_costs[current_device]))
                skill_points = skill_points - self.device_costs[current_device]
                spent_sp = spent_sp + self.device_costs[current_device]
                table.insert(unlocked_devices, current_device)
                self.device_line:replace(string.upper(device), string.upper(current_device))
                device = current_device
                save()
                playMenuSelect()
            end
        else
            self.active = false
            self.console:addLine(0.02, '')
            self.console:addLine(0.04, '')
            self.console.timer:after(0.06, function() self.console:bytepathMain() end)
        end
    end

    if input:pressed('escape') then
        self.active = false
        self.console:addLine(0.02, '')
        self.console.timer:after(0.04, function() self.console:bytepathMain() end)
    end
end

function DeviceModule:draw()
    love.graphics.setColor(default_color)
    pushRotateScale(self.x, self.y, 0, self.sx, self.sy)
    local w, h = self.w, self.h 
    local x, y = self.x, self.y

    love.graphics.setFont(self.font)
    -- love.graphics.print('CHOOSE device', x, y - h/1.5, 0, 1.01, 1.01, self.font:getWidth('CHOOSE device')/2, self.font:getHeight()/2)

    love.graphics.line(self.x - self.w/2 - 80, self.y, self.x - self.w/2 - 60, self.y - self.h/4)
    love.graphics.line(self.x - self.w/2 - 80, self.y, self.x - self.w/2 - 60, self.y + self.h/4)
    love.graphics.line(self.x + self.w/2 + 80, self.y, self.x + self.w/2 + 60, self.y - self.h/4)
    love.graphics.line(self.x + self.w/2 + 80, self.y, self.x + self.w/2 + 60, self.y + self.h/4)
    BSGRectangle('line', self.x - self.w/2 - 50, self.y - self.h/2, 120, self.h, 8, 8)
    BSGRectangle('line', self.x + self.w/2 - 70, self.y - self.h/2, 120, self.h, 8, 8)

    -- Left
    local device = self.devices[self.device_index]
    love.graphics.setLineWidth(1)
    love.graphics.print(device, self.x - self.w/2 + 10, self.y - 27, 0, 1.01, 1.01, self.font:getWidth(device)/2, self.font:getHeight()/2)
    pushRotate(self.x - self.w/2 + 10, self.y - 2 + self.device_y_offsets[device], -math.pi/2)
    for _, vertice_group in ipairs(self.device_vertices[self.devices[self.device_index]].vertice_groups) do
        local points = fn.map(vertice_group, function(k, v) 
            if k % 2 == 1 then return self.x - self.w/2 + 10 + v + random(-1, 1) else return self.y - 2 + self.device_y_offsets[device] + v + random(-1, 1) end 
        end)
        love.graphics.polygon('line', points)
    end
    love.graphics.pop()
    if fn.any(unlocked_devices, device) then 
        love.graphics.print('UNLOCKED', self.x - self.w/2 + 10, self.y + 23 + self.device_y_offsets[device]/2, 0, 1.01, 1.01, self.font:getWidth('UNLOCKED')/2, self.font:getHeight()/2)
    else
        love.graphics.setColor(skill_point_color)
        love.graphics.print('LOCKED - ' .. self.device_costs[device] .. 'SP', self.x - self.w/2 + 10, self.y + 23 + self.device_y_offsets[device]/2, 0, 1.01, 1.01, 
        self.font:getWidth('LOCKED - ' .. self.device_costs[device] .. 'SP')/2, self.font:getHeight()/2)
        love.graphics.setColor(default_color)
    end

    -- Right
    local x, y = self.x + self.w/2 - 10, self.y + 5
    local drawPentagon = function(radius)
        local points = {}
        for i = 1, 5 do
            table.insert(points, x + radius*math.cos(-math.pi/2 + i*(2*math.pi/5)))
            table.insert(points, y + radius*math.sin(-math.pi/2 + i*(2*math.pi/5)))
        end
        love.graphics.polygon('line', points)
    end

    local r, g, b = unpack(default_color)
    love.graphics.setColor(r, g, b, 32)
    drawPentagon(32)
    drawPentagon(16)
    love.graphics.setColor(r, g, b, 255)
    love.graphics.print('TECH', x, y - 38, 0, 1, 1, self.font:getWidth('TECH')/2, self.font:getHeight()/2)
    love.graphics.print('ATK', x - 41, y - 12, 0, 1, 1, self.font:getWidth('ATK')/2, self.font:getHeight()/2)
    love.graphics.print('DEF', x + 41, y - 12, 0, 1, 1, self.font:getWidth('DEF')/2, self.font:getHeight()/2)
    love.graphics.print('SPD', x + 32, y + 26, 0, 1, 1, self.font:getWidth('SPD')/2, self.font:getHeight()/2)
    love.graphics.print('LCK', x - 32, y + 26, 0, 1, 1, self.font:getWidth('LCK')/2, self.font:getHeight()/2)

    local stats = {'uniqueness', 'defense', 'mobility', 'luck', 'attack'}
    local points = {}
    for i = 1, 5 do
        local d = self.device_stats[device][stats[i]]
        table.insert(points, x + d*16*math.cos(-math.pi/2 + (i-1)*(2*math.pi/5)) + random(-1, 1))
        table.insert(points, y + d*16*math.sin(-math.pi/2 + (i-1)*(2*math.pi/5)) + random(-1, 1))
    end
    love.graphics.setColor(r, g, b, 64)
    local triangles = love.math.triangulate(points)
    for _, triangle in ipairs(triangles) do love.graphics.polygon('fill', triangle) end
    love.graphics.setColor(r, g, b, 255)
    love.graphics.polygon('line', points)

    -- Text
    local x, y = self.x - self.w/2 - 80, self.y + self.h - 24
    for i, line in ipairs(self.device_descriptions[device]) do
        love.graphics.print(line, x, y + 12*(i-1), 0, 1, 1, 0, self.font:getHeight()/2)
    end
    love.graphics.pop()
end
