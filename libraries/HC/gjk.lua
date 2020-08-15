--[[
Copyright (c) 2012 Matthias Richter

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

local _PACKAGE = (...):match("^(.+)%.[^%.]+")
local vector  = require(_PACKAGE .. '.vector-light')
local huge, abs = math.huge, math.abs

local simplex, edge = {}, {}

local function support(shape_a, shape_b, dx, dy)
	local x,y = shape_a:support(dx,dy)
	return vector.sub(x,y, shape_b:support(-dx, -dy))
end

-- returns closest edge to the origin
local function closest_edge(n)
	edge.dist = huge

	local i = n-1
	for k = 1,n-1,2 do
		local ax,ay = simplex[i], simplex[i+1]
		local bx,by = simplex[k], simplex[k+1]
		i = k

		local ex,ey = vector.perpendicular(bx-ax, by-ay)
		local nx,ny = vector.normalize(ex,ey)
		local d = vector.dot(ax,ay, nx,ny)

		if d < edge.dist then
			edge.dist = d
			edge.nx, edge.ny = nx, ny
			edge.i = k
		end
	end
end

local function EPA(shape_a, shape_b)
	-- make sure simplex is oriented counter clockwise
	local cx,cy, bx,by, ax,ay = unpack(simplex, 1, 6)
	if vector.dot(ax-bx,ay-by, cx-bx,cy-by) < 0 then
		simplex[1],simplex[2] = ax,ay
		simplex[5],simplex[6] = cx,cy
	end

	-- the expanding polytype algorithm
	local is_either_circle = shape_a._center or shape_b._center
	local last_diff_dist, n = huge, 6
	while true do
		closest_edge(n)
		local px,py = support(shape_a, shape_b, edge.nx, edge.ny)
		local d = vector.dot(px,py, edge.nx, edge.ny)

		local diff_dist = d - edge.dist
		if diff_dist < 1e-6 or (is_either_circle and abs(last_diff_dist - diff_dist) < 1e-10) then
			return -d*edge.nx, -d*edge.ny
		end
		last_diff_dist = diff_dist

		-- simplex = {..., simplex[edge.i-1], px, py, simplex[edge.i]
		for i = n, edge.i, -1 do
			simplex[i+2] = simplex[i]
		end
		simplex[edge.i+0] = px
		simplex[edge.i+1] = py
		n = n + 2
	end
end

--   :      :     origin must be in plane between A and B
-- B o------o A   since A is the furthest point on the MD
--   :      :     in direction of the origin.
local function do_line()
	local bx,by, ax,ay = unpack(simplex, 1, 4)

	local abx,aby = bx-ax, by-ay

	local dx,dy = vector.perpendicular(abx,aby)

	if vector.dot(dx,dy, -ax,-ay) < 0 then
		dx,dy = -dx,-dy
	end
	return dx,dy
end

-- B .'
--  o-._  1
--  |   `-. .'     The origin can only be in regions 1, 3 or 4:
--  |  4   o A 2   A lies on the edge of the MD and we came
--  |  _.-' '.     from left of BC.
--  o-'  3
-- C '.
local function do_triangle()
	local cx,cy, bx,by, ax,ay = unpack(simplex, 1, 6)
	local aox,aoy = -ax,-ay
	local abx,aby = bx-ax, by-ay
	local acx,acy = cx-ax, cy-ay

	-- test region 1
	local dx,dy = vector.perpendicular(abx,aby)
	if vector.dot(dx,dy, acx,acy) > 0 then
		dx,dy = -dx,-dy
	end
	if vector.dot(dx,dy, aox,aoy) > 0 then
		-- simplex = {bx,by, ax,ay}
		simplex[1], simplex[2] = bx,by
		simplex[3], simplex[4] = ax,ay
		return 4, dx,dy
	end

	-- test region 3
	dx,dy = vector.perpendicular(acx,acy)
	if vector.dot(dx,dy, abx,aby) > 0 then
		dx,dy = -dx,-dy
	end
	if vector.dot(dx,dy, aox, aoy) > 0 then
		-- simplex = {cx,cy, ax,ay}
		simplex[3], simplex[4] = ax,ay
		return 4, dx,dy
	end

	-- must be in region 4
	return 6
end

local function GJK(shape_a, shape_b)
	local ax,ay = support(shape_a, shape_b, 1,0)
	if ax == 0 and ay == 0 then
		-- only true if shape_a and shape_b are touching in a vertex, e.g.
		--  .---                .---.
		--  | A |           .-. | B |   support(A, 1,0)  = x
		--  '---x---.  or  : A :x---'   support(B, -1,0) = x
		--      | B |       `-'         => support(A,B,1,0) = x - x = 0
		--      '---'
		-- Since CircleShape:support(dx,dy) normalizes dx,dy we have to opt
		-- out or the algorithm blows up. In accordance to the cases below
		-- choose to judge this situation as not colliding.
		return false
	end

	simplex[1], simplex[2] = ax, ay
	local dx,dy = -ax,-ay

	-- first iteration: line case
	ax,ay = support(shape_a, shape_b, dx,dy)
	if vector.dot(ax,ay, dx,dy) <= 0 then
		return false
	end

	simplex[3], simplex[4] = ax,ay
	dx, dy = do_line()

	local n

	-- all other iterations must be the triangle case
	while true do
		ax,ay = support(shape_a, shape_b, dx,dy)

		if vector.dot(ax,ay, dx,dy) <= 0 then
			return false
		end

		simplex[5], simplex[6] = ax,ay
		n, dx, dy = do_triangle()

		if n == 6 then
			return true, EPA(shape_a, shape_b)
		end
	end
end

return GJK
