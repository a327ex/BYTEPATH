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

local _NAME, common_local = ..., common
if not (type(common) == 'table' and common.class and common.instance) then
	assert(common_class ~= false, 'No class commons specification available.')
	require(_NAME .. '.class')
end
local Shapes      = require(_NAME .. '.shapes')
local Spatialhash = require(_NAME .. '.spatialhash')

-- reset global table `common' (required by class commons)
if common_local ~= common then
	common_local, common = common, common_local
end

local newPolygonShape = Shapes.newPolygonShape
local newCircleShape  = Shapes.newCircleShape
local newPointShape   = Shapes.newPointShape

local HC = {}
function HC:init(cell_size)
	self.hash = common_local.instance(Spatialhash, cell_size or 100)
end

-- spatial hash management
function HC:resetHash(cell_size)
	local hash = self.hash
	self.hash = common_local.instance(Spatialhash, cell_size or 100)
	for shape in pairs(hash:shapes()) do
		self.hash:register(shape, shape:bbox())
	end
	return self
end

function HC:register(shape)
	self.hash:register(shape, shape:bbox())

	-- keep track of where/how big the shape is
	for _, f in ipairs({'move', 'rotate', 'scale'}) do
		local old_function = shape[f]
		shape[f] = function(this, ...)
			local x1,y1,x2,y2 = this:bbox()
			old_function(this, ...)
			self.hash:update(this, x1,y1,x2,y2, this:bbox())
			return this
		end
	end

	return shape
end

function HC:remove(shape)
	self.hash:remove(shape, shape:bbox())
	for _, f in ipairs({'move', 'rotate', 'scale'}) do
		shape[f] = function()
			error(f.."() called on a removed shape")
		end
	end
	return self
end

-- shape constructors
function HC:polygon(...)
	return self:register(newPolygonShape(...))
end

function HC:rectangle(x,y,w,h)
	return self:polygon(x,y, x+w,y, x+w,y+h, x,y+h)
end

function HC:circle(x,y,r)
	return self:register(newCircleShape(x,y,r))
end

function HC:point(x,y)
	return self:register(newPointShape(x,y))
end

-- collision detection
function HC:neighbors(shape)
	local neighbors = self.hash:inSameCells(shape:bbox())
	rawset(neighbors, shape, nil)
	return neighbors
end

function HC:collisions(shape)
	local candidates = self:neighbors(shape)
	for other in pairs(candidates) do
		local collides, dx, dy = shape:collidesWith(other)
		if collides then
			rawset(candidates, other, {dx,dy, x=dx, y=dy})
		else
			rawset(candidates, other, nil)
		end
	end
	return candidates
end

-- the class and the instance
HC = common_local.class('HardonCollider', HC)
local instance = common_local.instance(HC)

-- the module
return setmetatable({
	new       = function(...) return common_local.instance(HC, ...) end,
	resetHash = function(...) return instance:resetHash(...) end,
	register  = function(...) return instance:register(...) end,
	remove    = function(...) return instance:remove(...) end,

	polygon   = function(...) return instance:polygon(...) end,
	rectangle = function(...) return instance:rectangle(...) end,
	circle    = function(...) return instance:circle(...) end,
	point     = function(...) return instance:point(...) end,

	neighbors  = function(...) return instance:neighbors(...) end,
	collisions = function(...) return instance:collisions(...) end,
	hash       = function() return instance.hash end,
}, {__call = function(_, ...) return common_local.instance(HC, ...) end})
