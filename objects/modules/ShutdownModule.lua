ShutdownModule = Object:extend()

function ShutdownModule:new(console, y)
    self.console = console
    self.y = y

    self.console:addLine(0.00, '')
    self.console:addLine(0.02, '[  ;WAIT,  ] shutting down...', 2.0, {{';WAIT,', ' <OK> '}, {'shutting', 'shut'}})
    self.console:addLine(0.20, '[   <OK>   ] stopped message system')
    self.console:addLine(0.22, '[  ;WAIT,  ] stopping bioware abstraction layer', 1.4, {{';WAIT,', ' <OK> '}, {'stopping', 'stopped'}})
    self.console:addLine(0.24, '[   <OK>   ] stopped logger')
    self.console:addLine(0.26, '[  ;WAIT,  ] sending [' .. self.console:getRandomArchWord() .. '] to processes', 0.9, {{';WAIT,', ' <OK> '}, {'sending', 'sent'}})
    self.console:addLine(0.28, '[  ;WAIT,  ] sending [' .. self.console:getRandomArchWord() .. '] to processes', 1.5, {{';WAIT,', ' <OK> '}, {'sending', 'sent'}})
    self.console:addLine(0.30, '[   <OK>   ] saved random seed')
    self.console:addLine(0.32, '[   <OK>   ] saved system clock')
    self.console:addLine(0.34, '[  ;WAIT,  ] unmounting filesystems', 0.4, {{';WAIT,', ' <OK> '}, {'unmounting', 'unmounted'}})
    self.console:addLine(0.36, '')
    self.console:addLine(2.35, '$~SHUTDOWN% ~GOODBYE!')
    self.console.timer:after(3.0, function() love.event.push('quit') end)
end

function ShutdownModule:update(dt)
    
end

function ShutdownModule:draw()
    
end
