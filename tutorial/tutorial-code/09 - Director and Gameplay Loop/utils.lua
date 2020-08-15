function UUID()
    local fn = function(x)
        local r = math.random(16) - 1
        r = (x == "x") and (r + 1) or (r % 4) + 9
        return ("0123456789abcdef"):sub(r, r)
    end
    return (("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"):gsub("[xy]", fn))
end

function random(min, max)
    local min, max = min or 0, max or 1
    return (min > max and (love.math.random()*(min - max) + max)) or (love.math.random()*(max - min) + min)
end

function table.random(t)
    return t[love.math.random(1, #t)]
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
