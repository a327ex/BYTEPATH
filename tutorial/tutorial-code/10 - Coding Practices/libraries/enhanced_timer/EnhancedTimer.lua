local EnhancedTimer = Object:extend()
local Timer = require 'libraries/hump/timer'

function EnhancedTimer:new()
    self.timer = Timer()
    self.tags = {}
end

function EnhancedTimer:update(dt)
    if self.timer then self.timer:update(dt) end
end

function EnhancedTimer:after(tag, duration, func)
    if type(tag) == 'string' then
        self:cancel(tag)
        self.tags[tag] = self.timer:after(duration, func)
        return self.tags[tag]
    else
        return self.timer:after(tag, duration, func)
    end
    
end

function EnhancedTimer:during(tag, duration, func, after)
    if type(tag) == 'string' then
        self:cancel(tag)
        self.tags[tag] = self.timer:during(duration, func, after)
        return self.tags[tag]
    else
        return self.timer:during(tag, duration, func, after)
    end
end

function EnhancedTimer:every(tag, duration, func, count)
    if type(tag) == 'string' then
        self:cancel(tag)
        self.tags[tag] = self.timer:every(duration, func, count)
        return self.tags[tag]
    else
        return self.timer:every(tag, duration, func, count)
    end
end

function EnhancedTimer:tween(tag, duration, table, tween_table, tween_function, after)
    if type(tag) == 'string' then
        self:cancel(tag)
        self.tags[tag] = self.timer:tween(duration, table, tween_table, tween_function, after)
        return self.tags[tag]
    else
        return self.timer:tween(tag, duration, table, tween_table, tween_function, after)
    end
end

function EnhancedTimer:cancel(tag)
    if tag then
        if self.tags[tag] then
            self.timer:cancel(self.tags[tag])
            self.tags[tag] = nil
        else self.timer:cancel(tag) end
    end
end

function EnhancedTimer:clear()
    self.timer:clear()
    self.tags = {}
end

function EnhancedTimer:destroy()
    self.timer:clear()
    self.tags = {}
    self.timer = nil
end


return EnhancedTimer
