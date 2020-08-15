ClearModule = Object:extend()

function ClearModule:new(console, y)
    self.console = console
    self.y = y

    self.console:addLine(0.02, '')
    self.console:addLine(0.04, '~ press @ENTER# to select')
    self.console:addLine(0.06, '~ press @ESC# to exit')
    self.console:addLine(0.08, '    $clear CLASS data%')
    self.console:addLine(0.10, '    ;clear PASSIVE data,')
    self.console:addLine(0.12, '    @clear ALL data#')
    self.console:addLine(0.14, '')

    self.selection_index = 1
    self.selection_widths = {self.console.font:getWidth('clear CLASS data'), self.console.font:getWidth('clear PASSIVE data'), self.console.font:getWidth('clear ALL data')}
    self.console.timer:after(0.10, function() self.active = true end)

    self.confirm_selection_index = 1
    self.confirm_selection_widths = {self.console.font:getWidth('YES'), self.console.font:getWidth('NO')}
    self.confirm_selecting = false
end

function ClearModule:update(dt)
    if self.confirming then return end

    if input:pressed('escape') and self.active then
        self.active = false
        self.console:addInputLine(0.02, '[;root,]arch~ ')
    end

    if self.active and not self.confirm_selecting then
        if input:pressed('up') then
            self.selection_index = self.selection_index - 1
            if self.selection_index < 1 then self.selection_index = #self.selection_widths end
        end

        if input:pressed('down') then
            self.selection_index = self.selection_index + 1
            if self.selection_index > #self.selection_widths then self.selection_index = 1 end
        end

        if input:pressed('return') then
            if not self.confirm_selecting then
                if self.selection_index == 1 then
                    self.confirming = true
                    self.console:addLine(0.02, '@WARNING!!!# This will erase all bought classes.')
                    self.console:addLine(0.04, 'You will @NOT# be given any skill points back.')
                    self.console:addLine(0.06, 'Are you sure you want to proceed?')
                    self.console:addLine(0.08, '    YES')
                    self.console:addLine(0.10, '    NO')
                    self.console:addLine(0.12, '')
                    self.console.timer:after(0.14, function() 
                        self.confirm_selecting = true 
                        self.confirming = false
                    end)

                elseif self.selection_index == 2 then
                    self.confirming = true
                    self.console:addLine(0.02, '@WARNING!!!# This will erase all bought passives on your passive skill tree.')
                    self.console:addLine(0.04, 'You will @NOT# be given any skill points back.')
                    self.console:addLine(0.06, 'Are you sure you want to proceed?')
                    self.console:addLine(0.08, '    YES')
                    self.console:addLine(0.10, '    NO')
                    self.console:addLine(0.12, '')
                    self.console.timer:after(0.14, function() 
                        self.confirm_selecting = true 
                        self.confirming = false
                    end)

                elseif self.selection_index == 3 then
                    self.confirming = true
                    self.console:addLine(0.02, '@WARNING!!!# This will erase ALL saved data.')
                    self.console:addLine(0.04, 'You will start from zero again.')
                    self.console:addLine(0.06, 'Are you sure you want to proceed?')
                    self.console:addLine(0.08, '    YES')
                    self.console:addLine(0.10, '    NO')
                    self.console:addLine(0.12, '')
                    self.console.timer:after(0.14, function() 
                        self.confirm_selecting = true 
                        self.confirming = false
                    end)
                end
            end
        end

    elseif self.active and self.confirm_selecting then
        if input:pressed('up') then
            self.confirm_selection_index = self.confirm_selection_index - 1
            if self.confirm_selection_index < 1 then self.confirm_selection_index = #self.confirm_selection_widths end
        end

        if input:pressed('down') then
            self.confirm_selection_index = self.confirm_selection_index + 1
            if self.confirm_selection_index > #self.confirm_selection_widths then self.confirm_selection_index = 1 end
        end

        if input:pressed('return') then
            if self.confirm_selection_index == 2 then
                self.active = false
                self.confirm_selecting = false
                self.console:addInputLine(0.02, '[;root,]arch~ ')
            else
                if self.selection_index == 1 then
                    if #classes >= 9 then unlockAchievement('Reroll Classes') end
                    self.active = false
                    self.console:addLine(0.02, ';~RESETTING CLASSES!~,')
                    for i, class in ipairs(classes) do self.console:addLine(0.02 + 0.02*i, '[   <OK>   ] removed class @' .. class .. '#') end
                    local n = #classes
                    self.console:addLine(0.04 + 0.04 + n*0.02, '[  ;WAIT,  ] removing core targets', 0.8, {{';WAIT,', ' <OK> '}, {'removing', 'removed'}})
                    self.console:addLine(0.06 + 0.04 + n*0.02, '')
                    self.console:addInputLine(1.6 + 0.04 + n*0.02, '[;root,]arch~ ')
                    classes = {}
                    rank = 1
                    save()
                
                elseif self.selection_index == 2 then
                    if #bought_node_indexes >= 80 then unlockAchievement('Reroll Skills') end
                    self.active = false
                    self.console:addLine(0.02, ';~RESETTING SKILL TREE!~,')
                    for i, node_index in ipairs(bought_node_indexes) do self.console:addLine(0.02 + 0.02*i, '[   <OK>   ] removed node @(' .. node_index .. ')#') end
                    local n = #bought_node_indexes
                    self.console:addLine(0.02 + 0.04 + n*0.02, '[  ;WAIT,  ] unlinking paths', 1.4, {{';WAIT,', ' <OK> '}, {'unlinking', 'unlinked'}})
                    self.console:addLine(0.04 + 0.04 + n*0.02, '[  ;WAIT,  ] removing core targets', 0.8, {{';WAIT,', ' <OK> '}, {'removing', 'removed'}})
                    self.console:addLine(0.06 + 0.04 + n*0.02, '[  ;WAIT,  ] unmounting (' .. self.console:getRandomArchWord() .. ') [' .. self.console:getRandomArchWord() .. ']', 
                    0.4, {{';WAIT,', ' <OK> '}, {'unmounting', 'unmounted'}})
                    self.console:addLine(0.08 + 0.04 + n*0.02, '')
                    self.console:addInputLine(1.6 + 0.04 + n*0.02, '[;root,]arch~ ')
                    bought_node_indexes = {1}
                    save()

                elseif self.selection_index == 3 then
                    if #classes >= 9 and #bought_node_indexes >= 80 then unlockAchievement('Reroll Build') end
                    if #classes >= 9 then unlockAchievement('Reroll Classes') end
                    if #bought_node_indexes >= 80 then unlockAchievement('Reroll Skills') end

                    self.active = false
                    self.console:addLine(0.02, ';~RESETTING CLASSES!~,')
                    for i, class in ipairs(classes) do self.console:addLine(0.02 + 0.02*i, '[   <OK>   ] removed class @' .. class .. '#') end
                    local n = #classes
                    self.console:addLine(0.04 + 0.04 + n*0.02, '[  ;WAIT,  ] removing core targets', 0.8, {{';WAIT,', ' <OK> '}, {'removing', 'removed'}})
                    self.console:addLine(0.06 + 0.04 + n*0.02, '')

                    local t = 1.06 + 0.04 + n*0.02
                    self.console:addLine(t + 0.02, ';~RESETTING SKILL TREE!~,')
                    for i, node_index in ipairs(bought_node_indexes) do self.console:addLine(t + 0.02 + 0.02*i, '[   <OK>   ] removed node @(' .. node_index .. ')#') end
                    local n = #bought_node_indexes
                    self.console:addLine(t + 0.02 + 0.04 + n*0.02, '[  ;WAIT,  ] unlinking paths', 1.4, {{';WAIT,', ' <OK> '}, {'unlinking', 'unlinked'}})
                    self.console:addLine(t + 0.04 + 0.04 + n*0.02, '[  ;WAIT,  ] removing core targets', 0.8, {{';WAIT,', ' <OK> '}, {'removing', 'removed'}})
                    self.console:addLine(t + 0.06 + 0.04 + n*0.02, '[  ;WAIT,  ] unmounting (' .. self.console:getRandomArchWord() .. ') [' .. self.console:getRandomArchWord() .. ']', 
                    0.4, {{';WAIT,', ' <OK> '}, {'unmounting', 'unmounted'}})
                    self.console:addLine(t + 0.08 + 0.04 + n*0.02, '')

                    local t = t + 2.0 + 0.04 + n*0.02
                    self.console:addLine(t + 0.02, ';~RESETTING ALL OTHER SYSTEM SETTINGS!~,')
                    self.console:addLine(t + 3.80, '[   <OK>   ] removed target (' .. self.console:getRandomArchWord() .. ')')
                    self.console:addLine(t + 3.81, '[   <OK>   ] removed target (' .. self.console:getRandomArchWord() .. ')')
                    self.console:addLine(t + 4.81, '[  ;WAIT,  ] deallocating system (' .. self.console:getRandomArchWord() .. ') [' .. self.console:getRandomArchWord() .. ']', 1.1, {{';WAIT,', ' <OK> '}, {'deallocating', 'deallocated'}})
                    self.console:addLine(t + 5.2, '[  ;WAIT,  ] stopping (' .. self.console:getRandomArchWord() .. ') devices', 0.4, {{';WAIT,', ' <OK> '}, {'stopping', 'stopped'}})
                    self.console:addLine(t + 5.60, '[  ;WAIT,  ] stopping virtual console', 1.2, {{';WAIT,', ' <OK> '}, {'stopping', 'stopped'}})
                    self.console:addLine(t + 5.61, '[  ;WAIT,  ] unmounting (' .. self.console:getRandomArchWord() .. ') message queue file system', 1.4, {{';WAIT,', ' <OK> '}, {'unmounting', 'unmounted'}})
                    self.console:addLine(t + 6.82, '[  ;WAIT,  ] stopping (' .. self.console:getRandomArchWord() .. ') (' .. self.console:getRandomArchWord() .. ') manager', 1.2, {{';WAIT,', ' <OK> '}, {'stopping', 'stopped'}})
                    self.console:addLine(t + 7.40, '[   <OK>   ] removed target (' .. self.console:getRandomArchWord() .. ')')
                    self.console:addLine(t + 7.41, '[   <OK>   ] removed target (' .. self.console:getRandomArchWord() .. ')')
                    self.console:addLine(t + 7.41, '[   <OK>   ] removed target (' .. self.console:getRandomArchWord() .. ')')
                    self.console:addLine(t + 7.42, '[   <OK>   ] removed target (' .. self.console:getRandomArchWord() .. ')')
                    self.console:addLine(t + 7.43, '[   <OK>   ] removed target (' .. self.console:getRandomArchWord() .. ')')
                    self.console:addLine(t + 7.80, '[   <OK>   ] removed target (' .. self.console:getRandomArchWord() .. ')')
                    self.console:addLine(t + 7.81, '[   <OK>   ] removed target (' .. self.console:getRandomArchWord() .. ')')
                    self.console:addLine(t + 8.00, '[   <OK>   ] removed target (' .. self.console:getRandomArchWord() .. ')')
                    self.console:addLine(t + 10.25, '')
                    self.console:addLine(t + 12.40, ':: restarting system [byte]')
                    self.console:addLine(t + 14.00, '')
                    self.console:addLine(t + 14.02, '[  ;WAIT,  ] shutting down...', 2.0, {{';WAIT,', ' <OK> '}, {'shutting', 'shut'}})
                    self.console:addLine(t + 14.20, '[   <OK>   ] stopped message system')
                    self.console:addLine(t + 14.22, '[  ;WAIT,  ] stopping bioware abstraction layer', 1.4, {{';WAIT,', ' <OK> '}, {'stopping', 'stopped'}})
                    self.console:addLine(t + 14.24, '[   <OK>   ] stopped logger')
                    self.console:addLine(t + 14.26, '[  ;WAIT,  ] sending [' .. self.console:getRandomArchWord() .. '] to processes', 0.9, {{';WAIT,', ' <OK> '}, {'sending', 'sent'}})
                    self.console:addLine(t + 14.28, '[  ;WAIT,  ] sending [' .. self.console:getRandomArchWord() .. '] to processes', 1.5, {{';WAIT,', ' <OK> '}, {'sending', 'sent'}})
                    self.console:addLine(t + 14.30, '[   <OK>   ] saved random seed')
                    self.console:addLine(t + 14.32, '[   <OK>   ] saved system clock')
                    self.console:addLine(t + 14.34, '[  ;WAIT,  ] unmounting filesystems', 0.4, {{';WAIT,', ' <OK> '}, {'unmounting', 'unmounted'}})
                    self.console:addLine(t + 14.36, '')
                    self.console:addLine(t + 16.35, '$~SHUTDOWN% ~GOODBYE!')

                    timer:after(t + 18, function()
                        removeSave()
                        setTransientGlobals()
                        love.event.quit('restart')
                    end)
                end
            end
        end
    end
end

function ClearModule:draw()
    if self.active and not self.confirm_selecting then 
        local width = self.selection_widths[self.selection_index]
        local r, g, b = unpack(default_color)
        if self.selection_index == 1 then r, g, b = unpack(boost_color) end
        if self.selection_index == 2 then r, g, b = unpack(skill_point_color) end
        if self.selection_index == 3 then r, g, b = unpack(hp_color) end
        love.graphics.setColor(r, g, b, 128)
        local x_offset = self.console.font:getWidth('    ')
        love.graphics.rectangle('fill', 8 + x_offset - 2, self.y + self.selection_index*12 + 17 + 12, width + 4, self.console.font:getHeight())
        love.graphics.setColor(255, 255, 255, 255)
    elseif self.active and self.confirm_selecting then
        local width = self.confirm_selection_widths[self.confirm_selection_index]
        local r, g, b = unpack(default_color)
        love.graphics.setColor(r, g, b, 128)
        local x_offset = self.console.font:getWidth('    ')
        love.graphics.rectangle('fill', 8 + x_offset - 2, self.y + self.confirm_selection_index*12 + 8*12 + 17, width + 4, self.console.font:getHeight())
        love.graphics.setColor(255, 255, 255, 255)
    end
end
