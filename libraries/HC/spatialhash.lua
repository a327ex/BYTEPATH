--[[
Copyright (c) 2011 Matthias Richter
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.
Except as contained in this notice, the name(s) of the above copyright holders
shall not be used in advertising or otherwise to promote the sale, use or
other dealings in this Software without prior written authorization.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]--

local floor = math.floor
local min, max = math.min, math.max

local _PACKAGE, common_local = (...):match("^(.+)%.[^%.]+"), common
if not (type(common) == 'table' and common.class and common.instance) then
	assert(common_class ~= false, 'No class commons specification available.')
	require(_PACKAGE .. '.class')
	common_local, common = common, common_local
end

local Spatialhash = {}
function Spatialhash:init(cell_size)
	self.cell_size = cell_size or 100
	self.cells = {}
end

function Spatialhash:cellCoords(x,y)
	return floor(x / self.cell_size), floor(y / self.cell_size)
end

function Spatialhash:cell(i,k)
	local row = rawget(self.cells, i)
	if not row then
		row = {}
		rawset(self.cells, i, row)
	end

	local cell = rawget(row, k)
	if not cell then
		cell = setmetatable({}, {__mode = "kv"})
		rawset(row, k, cell)
	end

	return cell
end

function Spatialhash:cellAt(x,y)
	return self:cell(self:cellCoords(x,y))
end

 -- get all shapes
function Spatialhash:shapes()
	local set = {}
	for i,row in pairs(self.cells) do
		for k,cell in pairs(row) do
			for obj in pairs(cell) do
				rawset(set, obj, obj)
			end
		end
	end
	return set
end

-- get all shapes that are in the same cells as the bbox x1,y1 '--. x2,y2
function Spatialhash:inSameCells(x1,y1, x2,y2)
	local set = {}
	x1, y1 = self:cellCoords(x1, y1)
	x2, y2 = self:cellCoords(x2, y2)
	for i = x1,x2 do
		for k = y1,y2 do
			for obj in pairs(self:cell(i,k)) do
				rawset(set, obj, obj)
			end
		end
	end
	return set
end

function Spatialhash:register(obj, x1, y1, x2, y2)
	x1, y1 = self:cellCoords(x1, y1)
	x2, y2 = self:cellCoords(x2, y2)
	for i = x1,x2 do
		for k = y1,y2 do
			rawset(self:cell(i,k), obj, obj)
		end
	end
end

function Spatialhash:remove(obj, x1, y1, x2,y2)
	-- no bbox given. => must check all cells
	if not (x1 and y1 and x2 and y2) then
		for _,row in pairs(self.cells) do
			for _,cell in pairs(row) do
				rawset(cell, obj, nil)
			end
		end
		return
	end

	-- else: remove only from bbox
	x1,y1 = self:cellCoords(x1,y1)
	x2,y2 = self:cellCoords(x2,y2)
	for i = x1,x2 do
		for k = y1,y2 do
			rawset(self:cell(i,k), obj, nil)
		end
	end
end

-- update an objects position
function Spatialhash:update(obj, old_x1,old_y1, old_x2,old_y2, new_x1,new_y1, new_x2,new_y2)
	old_x1, old_y1 = self:cellCoords(old_x1, old_y1)
	old_x2, old_y2 = self:cellCoords(old_x2, old_y2)

	new_x1, new_y1 = self:cellCoords(new_x1, new_y1)
	new_x2, new_y2 = self:cellCoords(new_x2, new_y2)

	if old_x1 == new_x1 and old_y1 == new_y1 and
	   old_x2 == new_x2 and old_y2 == new_y2 then
		return
	end

	for i = old_x1,old_x2 do
		for k = old_y1,old_y2 do
			rawset(self:cell(i,k), obj, nil)
		end
	end
	for i = new_x1,new_x2 do
		for k = new_y1,new_y2 do
			rawset(self:cell(i,k), obj, obj)
		end
	end
end

function Spatialhash:intersectionsWithSegment(x1, y1, x2, y2)
	local odx, ody = x2 - x1, y2 - y1
	local len, cur = vector.len(odx, ody), 0
	local dx, dy = vector.normalize(odx, ody)
	local step = self.cell_size / 2
	local visited = {}
	local points = {}
	local mt = math.huge

	while (cur + step < len) do
		local cx, cy = x1 + dx * cur,  y1 + dy * cur
		local shapes = self:cellAt(cx, cy)
		cur = cur + step

		for _, shape in pairs(shapes) do
			if (not visited[shape]) then
				local ints = shape:intersectionsWithRay(x1, y1, dx, dy)

				for _, t in ipairs(ints) do
					if (t >= 0 and t <= len) then
						local px, py = vector.add(x1, y1, vector.mul(t, dx, dy))
						table.insert(points, {shape, t, px, py})
					end
				end

				visited[shape] = true
			end
		end
	end

	table.sort(points, function(a, b)
		return a[2] < b[2]
	end)

	return points
end

function Spatialhash:draw(how, show_empty, print_key)
	if show_empty == nil then show_empty = true end
	for k1,v in pairs(self.cells) do
		for k2,cell in pairs(v) do
			local is_empty = (next(cell) == nil)
			if show_empty or not is_empty then
				local x = k1 * self.cell_size
				local y = k2 * self.cell_size
				love.graphics.rectangle(how or 'line', x,y, self.cell_size, self.cell_size)

				if print_key then
					love.graphics.print(("%d:%d"):format(k1,k2), x+3,y+3)
				end
			end
		end
	end
end

return common_local.class('Spatialhash', Spatialhash)