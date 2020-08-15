local input_path = (...):match('(.-)[^%.]+$') .. '.'
local Input = {}
Input.__index = Input

Input.all_keys = {
    " ", "return", "escape", "backspace", "tab", "space", "!", "\"", "#", "$", "&", "'", "(", ")", "*", "+", ",", "-", ".", "/", "0", "1", "2", "3", "4",
    "5", "6", "7", "8", "9", ":", ";", "<", "=", ">", "?", "@", "[", "\\", "]", "^", "", "`", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
    "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "capslock", "f1", "f2", "f3", "f4", "f5", "f6", "f7", "f8", "f9", "f10", "f11", "f12", "printscreen",
    "scrolllock", "pause", "insert", "home", "pageup", "delete", "end", "pagedown", "right", "left", "down", "up", "numlock", "kp/", "kp*", "kp-", "kp+", "kpenter",
    "kp0", "kp1", "kp2", "kp3", "kp4", "kp5", "kp6", "kp7", "kp8", "kp9", "kp.", "kp,", "kp=", "application", "power", "f13", "f14", "f15", "f16", "f17", "f18", "f19",
    "f20", "f21", "f22", "f23", "f24", "execute", "help", "menu", "select", "stop", "again", "undo", "cut", "copy", "paste", "find", "mute", "volumeup", "volumedown",
    "alterase", "sysreq", "cancel", "clear", "prior", "return2", "separator", "out", "oper", "clearagain", "thsousandsseparator", "decimalseparator", "currencyunit",
    "currencysubunit", "lctrl", "lshift", "lalt", "lgui", "rctrl", "rshift", "ralt", "rgui", "mode", "audionext", "audioprev", "audiostop", "audioplay", "audiomute",
    "mediaselect", "brightnessdown", "brightnessup", "displayswitch", "kbdillumtoggle", "kbdillumdown", "kbdillumup", "eject", "sleep", "mouse1", "mouse2", "mouse3",
    "mouse4", "mouse5", "wheelup", "wheeldown", "fdown", "fup", "fleft", "fright", "back", "guide", "start", "leftstick", "rightstick", "l1", "r1", "l2", "r2", "dpup",
    "dpdown", "dpleft", "dpright", "leftx", "lefty", "rightx", "righty",
}

function Input.new()
    local self = {}

    self.prev_state = {}
    self.state = {}
    self.binds = {}
    self.functions = {}
    self.repeat_state = {}

    -- Gamepads... currently only supports 1 gamepad, adding support for more is not that hard, just lazy.
    self.joysticks = love.joystick.getJoysticks()

    -- Register callbacks automagically
    local callbacks = {'keypressed', 'keyreleased', 'mousepressed', 'mousereleased', 'gamepadpressed', 'gamepadreleased', 'gamepadaxis', 'wheelmoved', 'update'}
    local old_functions = {}
    local empty_function = function() end
    for _, f in ipairs(callbacks) do
        old_functions[f] = love[f] or empty_function
        love[f] = function(...)
            old_functions[f](...)
            self[f](self, ...)
        end
    end

    return setmetatable(self, Input)
end

function Input:bind(key, action)
    if type(action) == 'function' then self.functions[key] = action; return end
    if not self.binds[action] then self.binds[action] = {} end
    table.insert(self.binds[action], key)
end

function Input:pressed(action)
    if action then
        for _, key in ipairs(self.binds[action]) do
            if self.state[key] and not self.prev_state[key] then
                return true
            end
        end

    else
        for _, key in ipairs(Input.all_keys) do
            if self.state[key] and not self.prev_state[key] then
                if self.functions[key] then
                    self.functions[key]()
                end
            end
        end
    end
end

function Input:pressRepeat(action, interval, delay)
    if action and delay and interval then
        for _, key in ipairs(self.binds[action]) do
            if self.state[key] and not self.prev_state[key] then
                self.repeat_state[key] = {pressed_time = love.timer.getTime(), delay = delay, interval = interval, delay_stage = true}
                return true
            elseif self.repeat_state[key] and self.repeat_state[key].pressed then
                return true
            end
        end
    elseif action and interval and not delay then
        for _, key in ipairs(self.binds[action]) do
            if self.state[key] and not self.prev_state[key] then
                self.repeat_state[key] = {pressed_time = love.timer.getTime(), delay = 0, interval = interval, delay_stage = false}
                return true
            elseif self.repeat_state[key] and self.repeat_state[key].pressed then
                return true
            end
        end
    end
end

function Input:released(action)
    for _, key in ipairs(self.binds[action]) do
        if self.prev_state[key] and not self.state[key] then
            return true
        end
    end
end

local key_to_button = {mouse1 = '1', mouse2 = '2', mouse3 = '3', mouse4 = '4', mouse5 = '5'} 
local gamepad_to_button = {fdown = 'a', fup = 'y', fleft = 'x', fright = 'b', back = 'back', guide = 'guide', start = 'start',
                           leftstick = 'leftstick', rightstick = 'rightstick', l1 = 'leftshoulder', r1 = 'rightshoulder',
                           dpup = 'dpup', dpdown = 'dpdown', dpleft = 'dpleft', dpright = 'dpright'}
local axis_to_button = {leftx = 'leftx', lefty = 'lefty', rightx = 'rightx', righty = 'righty', l2 = 'triggerleft', r2 = 'triggerright'}

function Input:down(action)
    for _, key in ipairs(self.binds[action]) do
        if (love.keyboard.isDown(key) or love.mouse.isDown(key_to_button[key] or 0)) then
            return true
        end
        
        -- Supports only 1 gamepad, add more later...
        if self.joysticks[1] then
            if axis_to_button[key] then
                return self.state[key]
            elseif gamepad_to_button[key] then
                if self.joysticks[1]:isGamepadDown(gamepad_to_button[key]) then
                    return true
                end
            end
        end
    end
end

function Input:unbind(key)
    for action, keys in pairs(self.binds) do
        for i = #keys, 1, -1 do
            if key == self.binds[action][i] then
                table.remove(self.binds[action], i)
            end
        end
    end
end

function Input:unbindAll()
    self.binds = {}
end

local copy = function(t1)
    local out = {}
    for k, v in pairs(t1) do out[k] = v end
    return out
end

function Input:update()
    self:pressed()
    self.prev_state = copy(self.state)
    self.state['wheelup'] = false
    self.state['wheeldown'] = false

    -- pressRepeat
    for k, v in pairs(self.repeat_state) do
        if v then
            v.pressed = false 
            local t = love.timer.getTime() - v.pressed_time
            if v.delay_stage then 
                if t > v.delay then 
                    v.pressed = true 
                    v.pressed_time = love.timer.getTime()
                    v.delay_stage = false
                end
            else
                if t > v.interval then
                    v.pressed = true
                    v.pressed_time = love.timer.getTime()
                end
            end
        end
    end
end

function Input:keypressed(key)
    self.state[key] = true
end

function Input:keyreleased(key)
    self.state[key] = false
    self.repeat_state[key] = false
end

local button_to_key = {[1] = 'mouse1', [2] = 'mouse2', [3] = 'mouse3', [4] = 'mouse4', [5] = 'mouse5'}

function Input:mousepressed(x, y, button)
    self.state[button_to_key[button]] = true
end

function Input:mousereleased(x, y, button)
    self.state[button_to_key[button]] = false
    self.repeat_state[button_to_key[button]] = false
end

function Input:wheelmoved(x, y)
    if y > 0 then self.state['wheelup'] = true
    elseif y < 0 then self.state['wheeldown'] = true end
end

local button_to_gamepad = {a = 'fdown', y = 'fup', x = 'fleft', b = 'fright', back = 'back', guide = 'guide', start = 'start',
                           leftstick = 'leftstick', rightstick = 'rightstick', leftshoulder = 'l1', rightshoulder = 'r1',
                           dpup = 'dpup', dpdown = 'dpdown', dpleft = 'dpleft', dpright = 'dpright'}

function Input:gamepadpressed(joystick, button)
    self.state[button_to_gamepad[button]] = true 
end

function Input:gamepadreleased(joystick, button)
    self.state[button_to_gamepad[button]] = false
    self.repeat_state[button_to_gamepad[button]] = false
end

local button_to_axis = {leftx = 'leftx', lefty = 'lefty', rightx = 'rightx', righty = 'righty', triggerleft = 'l2', triggerright = 'r2'}

function Input:gamepadaxis(joystick, axis, newvalue)
    self.state[button_to_axis[axis]] = newvalue
end

return setmetatable({}, {__call = function(_, ...) return Input.new(...) end})
