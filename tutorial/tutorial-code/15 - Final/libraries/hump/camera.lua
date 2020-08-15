--[[
Copyright (c) 2010-2015 Matthias Richter

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

local _PATH = (...):match('^(.*[%./])[^%.%/]+$') or ''
local cos, sin = math.cos, math.sin

local camera = {}
camera.__index = camera

-- Movement interpolators (for camera locking/windowing)
camera.smooth = {}

function camera.smooth.none()
	return function(dx,dy) return dx,dy end
end

function camera.smooth.linear(speed)
	assert(type(speed) == "number", "Invalid parameter: speed = "..tostring(speed))
	return function(dt,dx,dy, s)
		-- normalize direction
		local d = math.sqrt(dx*dx+dy*dy)
		local dts = math.min((s or speed) * dt, d) -- prevent overshooting the goal
		if d > 0 then
			dx,dy = dx/d, dy/d
		end

		return dx*dts, dy*dts
	end
end

function camera.smooth.damped(stiffness)
	assert(type(stiffness) == "number", "Invalid parameter: stiffness = "..tostring(stiffness))
	return function(dt,dx,dy, s)
		local dts = dt * (s or stiffness)
		return dx*dts, dy*dts
	end
end


local function new(x,y, zoom, rot, smoother)
	x,y  = x or love.graphics.getWidth()/2, y or love.graphics.getHeight()/2
	zoom = zoom or 1
	rot  = rot or 0
	smoother = smoother or camera.smooth.none() -- for locking, see below
	return setmetatable({x = x, y = y, scale = zoom, rot = rot, smoother = smoother, x_shakes = {}, y_shakes = {}}, camera)
end

function camera:update(dt)
    local x_shake_amount, y_shake_amount = 0, 0
    for i = #self.x_shakes, 1, -1 do
        self.x_shakes[i]:update(dt)
        x_shake_amount = x_shake_amount + self.x_shakes[i]:getAmplitude()
        if not self.x_shakes[i].shaking then table.remove(self.x_shakes, i) end
    end
    for i = #self.y_shakes, 1, -1 do
        self.y_shakes[i]:update(dt)
        y_shake_amount = y_shake_amount + self.y_shakes[i]:getAmplitude()
        if not self.y_shakes[i].shaking then table.remove(self.y_shakes, i) end
    end
    self:move(x_shake_amount, y_shake_amount)
end

-- camera shake
function camera:shake(amplitude, frequency, duration)
    table.insert(self.x_shakes, Shake(amplitude, frequency, duration*1000))
    table.insert(self.y_shakes, Shake(amplitude, frequency, duration*1000))
end

function camera:shakeHorizontal(amplitude, frequency, duration)
    table.insert(self.x_shakes, Shake(amplitude, frequency, duration*1000))
end

function camera:shakeVertical(amplitude, frequency, duration)
    table.insert(self.y_shakes, Shake(amplitude, frequency, duration*1000))
end

function camera:lookAt(x,y)
	self.x, self.y = x, y
	return self
end

function camera:move(dx,dy)
	self.x, self.y = self.x + dx, self.y + dy
	return self
end

function camera:position()
	return self.x, self.y
end

function camera:rotate(phi)
	self.rot = self.rot + phi
	return self
end

function camera:rotateTo(phi)
	self.rot = phi
	return self
end

function camera:zoom(mul)
	self.scale = self.scale * mul
	return self
end

function camera:zoomTo(zoom)
	self.scale = zoom
	return self
end

function camera:attach(x,y,w,h, noclip)
	x,y = x or 0, y or 0
	w,h = w or love.graphics.getWidth(), h or love.graphics.getHeight()

	self._sx,self._sy,self._sw,self._sh = love.graphics.getScissor()
	if not noclip then
		love.graphics.setScissor(x,y,w,h)
	end

	local cx,cy = x+w/2, y+h/2
	love.graphics.push()
	love.graphics.translate(cx, cy)
	love.graphics.scale(self.scale)
	love.graphics.rotate(self.rot)
	love.graphics.translate(-self.x, -self.y)
end

function camera:detach()
	love.graphics.pop()
	love.graphics.setScissor(self._sx,self._sy,self._sw,self._sh)
end

function camera:draw(...)
	local x,y,w,h,noclip,func
	local nargs = select("#", ...)
	if nargs == 1 then
		func = ...
	elseif nargs == 5 then
		x,y,w,h,func = ...
	elseif nargs == 6 then
		x,y,w,h,noclip,func = ...
	else
		error("Invalid arguments to camera:draw()")
	end

	self:attach(x,y,w,h,noclip)
	func()
	self:detach()
end

-- world coordinates to camera coordinates
function camera:getCameraCoords(x,y, ox,oy,w,h)
	ox, oy = ox or 0, oy or 0
	w,h = w or love.graphics.getWidth(), h or love.graphics.getHeight()

	-- x,y = ((x,y) - (self.x, self.y)):rotated(self.rot) * self.scale + center
	local c,s = cos(self.rot), sin(self.rot)
	x,y = x - self.x, y - self.y
	x,y = c*x - s*y, s*x + c*y
	return x*self.scale + w/2 + ox, y*self.scale + h/2 + oy
end

-- camera coordinates to world coordinates
function camera:getWorldCoords(x,y, sx,sy,ox,oy,w,h)
    sx, sy = sx or 1, sy or 1
	ox, oy = ox or 0, oy or 0
	w,h = w or love.graphics.getWidth(), h or love.graphics.getHeight()

	-- x,y = (((x,y) - center) / self.scale):rotated(-self.rot) + (self.x,self.y)
	local c,s = cos(-self.rot), sin(-self.rot)
	x,y = (x - w/2 - ox) / sx, (y - h/2 - oy) / sy
	x,y = c*x - s*y, s*x + c*y
	return x+self.x, y+self.y
end

function camera:getMousePosition(sx,sy,ox,oy,w,h)
	local mx,my = love.mouse.getPosition()
	return self:getWorldCoords(mx,my, sx,sy,ox,oy,w,h)
end

-- camera scrolling utilities
function camera:lockX(dt, x, smoother, ...)
	local dx, dy = (smoother or self.smoother)(dt, x - self.x, self.y, ...)
	self.x = self.x + dx
	return self
end

function camera:lockY(dt, y, smoother, ...)
	local dx, dy = (smoother or self.smoother)(dt, self.x, y - self.y, ...)
	self.y = self.y + dy
	return self
end

function camera:lockPosition(dt, x, y, smoother, ...)
	return self:move((smoother or self.smoother)(dt, x - self.x, y - self.y, ...))
end

function camera:lockWindow(dt, x, y, x_min, x_max, y_min, y_max, smoother, ...)
	-- figure out displacement in camera coordinates
	x,y = self:getCameraCoords(x,y)
	local dx, dy = 0,0
	if x < x_min then
		dx = x - x_min
	elseif x > x_max then
		dx = x - x_max
	end
	if y < y_min then
		dy = y - y_min
	elseif y > y_max then
		dy = y - y_max
	end

	-- transform displacement to movement in world coordinates
	local c,s = cos(-self.rot), sin(-self.rot)
	dx,dy = (c*dx - s*dy) / self.scale, (s*dx + c*dy) / self.scale

	-- move
	self:move((smoother or self.smoother)(dt,dx,dy,...))
end

-- the module
return setmetatable({new = new, smooth = camera.smooth},
	{__call = function(_, ...) return new(...) end})
