local Grid = {}
Grid.__index = Grid

function Grid.new(w, h, v)
    local self = {}

    if type(w) == 'table' then
        self.w = #w[1]
        self.h = #w
        self.grid = {}
        for i = 1, self.h do
            self.grid[i] = {}
            for j = 1, self.w do
                self.grid[i][j] = w[i][j]
            end
        end
    else
        self.w = w
        self.h = h
        self.grid = {}
        for i = 1, self.h do
            self.grid[i] = {}
            for j = 1, self.w do
                self.grid[i][j] = v
            end
        end
    end

    return setmetatable(self, Grid)
end

function Grid:set(x, y, n)
    if self.grid[y] then self.grid[y][x] = n end
end

function Grid:get(x, y)
    if self.grid[y] and self.grid[y][x] then return self.grid[y][x] else return 0 end
end

function Grid:flipHorizontally()
    for i = 1, self.h do
        for j = 1, math.floor(self.w/2) do
            self.grid[i][j], self.grid[i][self.w-(j-1)] = self.grid[i][self.w-(j-1)], self.grid[i][j]
        end
    end
end

function Grid:__tostring()
    local out = ''
    for i = 1, self.h do
        local s = '['
        for j = 1, self.w do
            s = s .. self:get(j, i) .. ', '
        end
        s = s .. ']\n'
        out = out .. s
    end
    return out
end 

return setmetatable({new = new}, {__call = function(_, ...) return Grid.new(...) end})
