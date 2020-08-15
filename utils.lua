function UUID()
    local fn = function(x)
        local r = love.math.random(16) - 1
        r = (x == "x") and (r + 1) or (r % 4) + 9
        return ("0123456789abcdef"):sub(r, r)
    end
    return (("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"):gsub("[xy]", fn))
end

function KEY()
    local fn = function(x)
        local r = love.math.random(16) - 1
        r = (x == "x") and (r + 1) or (r % 4) + 9
        return ("0123456789abcdef"):sub(r, r)
    end
    return (("xxxxxxxx"):gsub("[xy]", fn))
end

function random(min, max)
    local min, max = min or 0, max or 1
    return (min > max and (love.math.random()*(min - max) + max)) or (love.math.random()*(max - min) + min)
end

function round(n, m)
    return math.floor(((n + m - 1)/m))*m
end

function sign(n)
    if n > 0 then return 1
    elseif n < 0 then return -1
    else return 0 end
end

function table.find(t, v)
    for i, value in ipairs(t) do
        if value == v  then return i end
    end
end

function table.random(t)
    return t[love.math.random(1, #t)]
end

function table.randomh(t)
    local keys = {}
    for k in pairs(t) do table.insert(keys, k) end
    return table.random(keys)
end

function table.merge(t1, t2)
    local new_table = {}
    for k, v in pairs(t2) do new_table[k] = v end
    for k, v in pairs(t1) do new_table[k] = v end
    return new_table
end

function table.copy(t)
    local copy
    if type(t) == 'table' then
        copy = {}
        for k, v in next, t, nil do copy[table.copy(k)] = table.copy(v) end
        setmetatable(copy, table.copy(getmetatable(t)))
    else copy = t end
    return copy
end


function pushRotate(x, y, r)
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(r or 0)
    love.graphics.translate(-x, -y)
end

function pushRotateScale(x, y, r, sx, sy)
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(r or 0)
    love.graphics.scale(sx or 1, sy or sx or 1)
    love.graphics.translate(-x, -y)
end

function areRectanglesOverlapping(x1, y1, x2, y2, x3, y3, x4, y4)
    return not (x3 > x2 or x4 < x1 or y3 > y2 or y4 < y1)
end

function rectangleToVertexList(x, y, w, h)
    return {x, y, x+w, y, x+w, y+h, x, y+h}
end

function getPointsAlongLine(n, x1, y1, x2, y2)
    local points = {}
    local angle = Vector.angle(x2 - x1, y2 - y1)
    local step = distance(x1, y1, x2, y2)/n
    for i = 1, n do table.insert(points, {x = x1 + (i-1)*(step)*math.cos(angle), y = y1 + (i-1)*(step)*math.sin(angle)}) end
    return points
end

function createIrregularPolygon(size, point_amount)
    local point_amount = point_amount or 8
    local points = {}
    for i = 1, point_amount do
        local angle_interval = 2*math.pi/point_amount
        local s = size + random(-size/4, size/4)
        local angle = (i-1)*angle_interval + random(-angle_interval/4, angle_interval/4)
        table.insert(points, s*math.cos(angle))
        table.insert(points, s*math.sin(angle))
    end
    return points
end

function BSGRectangle(mode, x, y, w, h, s)
    love.graphics.polygon(mode, x + s, y, x + w - s, y, x + w, y + s, x + w, y + h - s, x + w - s, y + h, x + s, y + h, x, y + h - s, x, y + s)
end

function chanceList(...)
    return {
        chance_list = {},
        chance_definitions = {...},
        next = function(self)
            if #self.chance_list == 0 then
                for _, chance_definition in ipairs(self.chance_definitions) do
                    for i = 1, chance_definition[2] do table.insert(self.chance_list, chance_definition[1]) end
                end
            end
            return table.remove(self.chance_list, love.math.random(1, #self.chance_list))
        end
    }
end

function distance(x1, y1, x2, y2)
    return math.sqrt((x1 - x2)*(x1 - x2) + (y1 - y2)*(y1 - y2))
end

function pointLineDistance(a, b, p)
    local n = b - a
    local pa = a - p
    local c = n*((pa*n)/(n*n))
    local d = pa - c
    return math.sqrt(d*d)
end

function rotatePointAroundPoint(px, py, angle, cx, cy)
    local s, c = math.sin(angle), math.cos(angle)
    px = px - cx
    py = py - cy
    local xnew = px*c - py*s
    local ynew = px*s + py*c
    px = xnew + cx
    py = ynew + cy
    return px, py
end

function printCenteredText(text, x, y, font, color)
    love.graphics.setColor(color or default_color)
    love.graphics.print(text, x - math.floor(font:getWidth(text)/2), y - math.floor(font:getHeight()/2))
    love.graphics.setColor(default_color)
end

function drawCenteredRectangle(fill_mode, x, y, w, h, color)
    love.graphics.setColor(color)
    love.graphics.rectangle(fill_mode, x - w/2, y - h/2, w, h)
    love.graphics.setColor(default_color)
end

function drawRectangle(fill_mode, x, y, w, h, color)
    love.graphics.setColor(color)
    love.graphics.rectangle(fill_mode, x, y, w, h)
    love.graphics.setColor(default_color)
end

function addColor(color, amount)
    local r, g, b = unpack(color)
    return {r + amount, g + amount, b + amount}
end
