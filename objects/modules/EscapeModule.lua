EscapeModule = Object:extend()

function EscapeModule:new(console, y)
    self.console = console
    self.y = y

    if found_keys[1] == 1 and found_keys[2] == 1 and found_keys[3] == 1 and found_keys[4] == 1 and 
       found_keys[5] == 1 and found_keys[6] == 1 and found_keys[7] == 1 and found_keys[8] == 1 then
        self.console:addLine(0.02, '')
        self.console:addLine(0.04, '~ all keys have been found')
        self.console:addLine(0.06, '')
        for i = 1, 8 do
            if found_keys[i] == 1 then self.console:addLine(0.06 + i*0.02, '    key:' .. keys[i].address .. '                         [  <FOUND>  ]')
            else self.console:addLine(0.06 + i*0.02, '    ;key:' .. keys[i].address .. ', found in difficulty @' .. i*5 .. '+#') end
        end

        self.console:addLine(0.98, '')
        self.console:addLine(1.00, '...')
        self.console:addLine(2.00, '...')
        self.console:addLine(3.00, '...')
        self.console:addLine(4.00, '...')
        self.console:addLine(5.02, '')
        self.console:addLine(8.00, "Congratulations! You've successfully beaten the simulation!")
        self.console:addLine(12.00, "We said your goal was to escape this terminal but we lied.")
        self.console:addLine(16.00, "It's impossible for that to really happen...")
        self.console:addLine(20.00, "But you've provided us with a lot of data!")
        self.console:addLine(22.00, "We'll make sure to use it well!!!")
        self.console:addLine(22.02, '')
        self.console:addLine(24.00, '...')
        self.console:addLine(26.00, '...')
        self.console:addLine(26.02, '')
        self.console:addLine(32.00, "It's always hard doing this but... I'm sorry...")
        self.console:addLine(36.50, "Now that you've served your purpose you must be terminated.")
        self.console:addLine(40.00, "Goodbye... $[BYTE]-24% <" .. string.sub(id, 1, 8) .. ">...")
        self.console:addLine(40.02, '')
        self.console:addLine(42.00, '...')
        self.console:addLine(44.00, '...')
        self.console:addLine(44.02, '')

        timer:after(46, function()
            self.active = false
            self.console:addLine(0.02, ';~RESETTING CLASSES!~,')
            for i, class in ipairs(classes) do self.console:addLine(2.02 + 0.02*i, '[   <OK>   ] removed class @' .. class .. '#') end
            local n = #classes
            self.console:addLine(2.04 + 0.04 + n*0.02, '[  ;WAIT,  ] removing core targets', 0.8, {{';WAIT,', ' <OK> '}, {'removing', 'removed'}})
            self.console:addLine(2.06 + 0.04 + n*0.02, '')

            local t = 3.06 + 0.04 + n*0.02
            self.console:addLine(t + 0.02, ';~RESETTING SKILL TREE!~,')
            for i, node_index in ipairs(bought_node_indexes) do self.console:addLine(t + 2.02 + 0.02*i, '[   <OK>   ] removed node @(' .. node_index .. ')#') end
            local n = #bought_node_indexes
            self.console:addLine(t + 2.02 + 0.04 + n*0.02, '[  ;WAIT,  ] unlinking paths', 1.4, {{';WAIT,', ' <OK> '}, {'unlinking', 'unlinked'}})
            self.console:addLine(t + 2.04 + 0.04 + n*0.02, '[  ;WAIT,  ] removing core targets', 0.8, {{';WAIT,', ' <OK> '}, {'removing', 'removed'}})
            self.console:addLine(t + 2.06 + 0.04 + n*0.02, '[  ;WAIT,  ] unmounting (' .. self.console:getRandomArchWord() .. ') [' .. self.console:getRandomArchWord() .. ']', 
            0.4, {{';WAIT,', ' <OK> '}, {'unmounting', 'unmounted'}})
            self.console:addLine(t + 2.08 + 0.04 + n*0.02, '')

            local t = t + 4.0 + 0.04 + n*0.02
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
                if #classes >= 9 and #bought_node_indexes >= 80 then unlockAchievement('Reroll Build') end
                if #classes >= 9 then unlockAchievement('Reroll Classes') end
                if #bought_node_indexes >= 80 then unlockAchievement('Reroll Skills') end
                unlockAchievement('Escape')
            end)

            timer:after(t + 24, function()
                removeSave()
                loop = loop + 1
                setTransientGlobals()
                love.event.quit('restart')
            end)
        end)

    else
        self.console:addLine(0.02, '')
        self.console:addLine(0.04, '$BYTEPATH% version 1.0-release')
        self.console:addLine(0.06, 'The $BYTEPATH% test has been designed to test $[BYTE]-24% PSYON AI systems.')
        self.console:addLine(0.08, 'If you are reading this then you are an instance of such a system.')
        self.console:addLine(0.10, 'Your objective is to escape this terminal.')
        self.console:addLine(0.12, '@You can only escape when all keys are found.#')
        self.console:addLine(0.14, '')
        for i = 1, 8 do
            if found_keys[i] == 1 then self.console:addLine(0.14 + i*0.02, '    key:' .. keys[i].address .. '                         [  <FOUND>  ]')
            else self.console:addLine(0.14 + i*0.02, '    ;key:' .. keys[i].address .. ', found in difficulty @' .. i*5 .. '+#') end
        end
        self.console:addLine(0.34, '')
        self.console:addInputLine(0.38, '[;root,]arch~ ')
        self.console.timer:after(0.4, function() self.active = false end)
    end
end

function EscapeModule:update(dt)
    if input:pressed('escape') and self.active then
        self.active = false
        self.console:addInputLine(0.02, '[;root,]arch~ ')
    end
end

function EscapeModule:draw()
    
end
