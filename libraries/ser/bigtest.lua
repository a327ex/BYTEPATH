local serialize = require 'ser'

local t = {}
for i = 1, 15 do
    t[i] = {}
    for j = 1, 10 do
        t[i][j] = {{'woo'}}
    end
end
local s = serialize(t)
print(s)
loadstring(s)()
