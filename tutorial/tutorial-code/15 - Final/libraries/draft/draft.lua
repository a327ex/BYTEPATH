--[[
Title:     draft
Use:       drafting module for the LÖVE 2D game engine
Author:    Pierre-Emmanuel Lévesque
Email:     pierre.e.levesque@gmail.com
Created:   July 26th, 2012
Copyright: Copyright 2012, Pierre-Emmanuel Lévesque
License:   MIT license - @see LICENSE.md
--]]

----------------------------------------------------
-- Module setup
----------------------------------------------------

local draft = {}
draft.__index = draft

--[[
	New (constructor)

	@param   string   drawMode (fill, line, false) [def: fill]
	@return  table    metatable
--]]
local function new(mode)
	if mode == nil then mode = 'fill' end
	return setmetatable({
		mode = mode
	}, draft)
end

----------------------------------------------------
-- Getters and setters
----------------------------------------------------

function draft:getMode() return self.mode end
function draft:setMode(mode) self.mode = mode end

----------------------------------------------------
-- Utilities
----------------------------------------------------

--[[
	Appends vertices to another set of vertices

	@param   table    vertices {x1, y1, x2, y2, ...}
	@param   table    new vertices {x1, y1, x2, y2, ...}
	@return  table    merged vertices {x1, y1, x2, y2, ...}
--]]
local function appendVertices(vertices, newVertices)
	for _,v in ipairs(newVertices) do
		table.insert(vertices, v)
	end
	return vertices
end

----------------------------------------------------
-- Primary shapes (using core drawing functions)
----------------------------------------------------

--[[
	Draws lines between points

	@param   table    points {x1, y1, x2, y2, ...}
	@param   mixed    drawMode (fill, line, false) [def: self.mode]
	@return  table    points {x1, y1, x2, y2, ...}
--]]
function draft:line(points, mode)
	if mode == nil then mode = self.mode end
	if mode then
		love.graphics.line(points)
	end
	return points
end

--[[
	Draws an isosceles triangle

	@param   number   center x
	@param   number   center y
	@param   number   width of the base
	@param   number   height
	@param   mixed    drawMode (fill, line, false) [def: self.mode]
	@return  table    vertices {x1, y2, x2, y2, x3, y3}
--]]
function draft:triangleIsosceles(cx, cy, width, height, mode)
	if mode == nil then mode = self.mode end
	local widthRadius = width / 2
	local heightRadius = height / 2
	local x1 = cx
	local y1 = cy - heightRadius
	local x2 = cx + widthRadius
	local y2 = cy + heightRadius
	local x3 = cx - widthRadius
	local y3 = y2
	if mode then
		love.graphics.polygon(mode, x1, y1, x2, y2, x3, y3)
	end
	return {x1, y1, x2, y2, x3, y3}
end

--[[
	Draws a right triangle

	@param   number   center x
	@param   number   center y
	@param   number   width of the base (a minus width flips the triangle)
	@param   number   height
	@param   mixed    drawMode (fill, line, false) [def: self.mode]
	@return  table    vertices {x1, y2, x2, y2, x3, y3}
--]]
function draft:triangleRight(cx, cy, width, height, mode)
	if mode == nil then mode = self.mode end
	local widthRadius = width / 2
	local heightRadius = height / 2
	local x1 = cx - widthRadius
	local y1 = cy - heightRadius
	local x2 = cx + widthRadius
	local y2 = cy + heightRadius
	local x3 = x1
	local y3 = y2
	if mode then
		love.graphics.polygon(mode, x1, y1, x2, y2, x3, y3)
	end
	return {x1, y1, x2, y2, x3, y3}
end

--[[
	Draws a rectangle

	@param   number   center x
	@param   number   center y
	@param   number   width
	@param   number   height
	@param   mixed    drawMode (fill, line, false) [def: self.mode]
	@return  table    vertices {x1, y2, x2, y2, x3, y3, x4, y4}
--]]
function draft:rectangle(cx, cy, width, height, mode)
	if mode == nil then mode = self.mode end
	local widthRadius = width / 2
	local heightRadius = height / 2
	local left = cx - widthRadius
	local right = cx + widthRadius
	local top = cy - heightRadius
	local bottom = cy + heightRadius
	local vertices = {left, top, right, top, right, bottom, left, bottom}
	if mode then
		love.graphics.rectangle(mode, vertices[1], vertices[2], width, height)
	end
	return vertices
end

--[[
	Draws a polygon

	@param   table    vertices {x1, y1, x2, y2, ...}
	@param   mixed    drawMode (fill, line, false) [def: self.mode]
	@return  table    vertices {x1, y1, x2, y2, ...}
--]]
function draft:polygon(vertices, mode)
	if mode == nil then mode = self.mode end
	if mode then
		if (mode == 'fill' and not love.math.isConvex(vertices)) then
			local triangles = love.math.triangulate(vertices)
			for _, v in pairs(triangles) do
				love.graphics.polygon('fill', v)
			end
		else
			love.graphics.polygon(mode, vertices)
		end
	end
	return vertices
end

----------------------------------------------------
-- Secondary shapes (using primary shape functions)
----------------------------------------------------

--[[
	Draws an equilateral triangle

	@param   number   center x
	@param   number   center y
	@param   number   width of the base
	@param   mixed    drawMode (fill, line, false) [def: self.mode]
	@return  table    vertices {x1, y2, x2, y2, x3, y3}
	@uses    self:triangleIsosceles()
--]]
function draft:triangleEquilateral(cx, cy, width, mode)
	local height = math.sqrt(math.pow(width, 2) - math.pow(width / 2, 2))
	return self:triangleIsosceles(cx, cy, width, height, mode)
end

--[[
	Draws a square

	@param   number   center x
	@param   number   center y
	@param   number   length of one side (width or height)
	@param   mixed    drawMode (fill, line, false) [def: self.mode]
	@return  table    vertices {x1, y2, x2, y2, x3, y3, x4, y4}
	@uses    self:rectangle()
--]]
function draft:square(cx, cy, length, mode)
	return self:rectangle(cx, cy, length, length, mode)
end

--[[
	Draws a trapezoid

	@param   number   center x
	@param   number   center y
	@param   number   width (bottom)
	@param   number   height
	@param   number   top width
	@param   number   top width offset (to the left)
	@param   mixed    drawMode (fill, line, false) [def: self.mode]
	@return  table    vertices {x1, y2, x2, y2, x3, y3, x4, y4}
	@uses    self:polygon()
--]]
function draft:trapezoid(cx, cy, width, height, widthTop, widthTopOffset, mode)
	local widthRadius = width / 2
	local heightRadius = height / 2
	local widthTopRadiusOffsetted = widthTop / 2 + widthTopOffset
	local vertices = {
		cx - widthTopRadiusOffsetted, cy - heightRadius,
		cx + widthTopRadiusOffsetted, cy - heightRadius,
		cx + widthRadius, cy + heightRadius,
		cx - widthRadius, cy + heightRadius
	}
	return self:polygon(vertices, mode)
end

--[[
	Draws a rhombus

	@param   number   center x
	@param   number   center y
	@param   number   width
	@param   number   height
	@param   mixed    drawMode (fill, line, false) [def: self.mode]
	@return  table    vertices {x1, y2, x2, y2, x3, y3, x4, y4}
	@uses    self:polygon()
--]]
function draft:rhombus(cx, cy, width, height, mode)
	local widthRadius = width / 2
	local heightRadius = height / 2
	local vertices = {
		cx - widthRadius, cy,
		cx, cy - heightRadius,
		cx + widthRadius, cy,
		cx, cy + heightRadius
	}
	return self:polygon(vertices, mode)
end

--[[
	Draws a trapezium (no parallel sides)

	@param   number   center x
	@param   number   center y
	@param   number   width left
	@param   number   width right
	@param   number   height
	@param   number   depth
	@param   mixed    drawMode (fill, line, false) [def: self.mode]
	@return  table    vertices {x1, y2, x2, y2, x3, y3, x4, y4}
	@uses    self:polygon()
--]]
function draft:trapezium(cx, cy, widthLeft, widthRight, height, depth, mode)
	local vertices = {
		cx - widthLeft, cy,
		cx, cy - height,
		cx + widthRight, cy,
		cx, cy + depth
	}
	return self:polygon(vertices, mode)
end

--[[
	Draws a gem

	@param   number   center x
	@param   number   center y
	@param   number   top width
	@param   number   middle width
	@param   number   height
	@param   number   depth
	@param   mixed    drawMode (fill, line, false) [def: self.mode]
	@return  table    vertices {x1, y2, x2, y2, x3, y3, x4, y4, x5, y5}
	@uses    self:polygon()
--]]
function draft:gem(cx, cy, widthTop, widthMiddle, height, depth, mode)
	local widthTopRadius = widthTop / 2
	local widthMiddleRadius = widthMiddle / 2
	local vertices = {
		cx - widthTopRadius, cy - height,
		cx + widthTopRadius, cy - height,
		cx + widthMiddleRadius, cy,
		cx, cy + depth,
		cx - widthMiddleRadius, cy
	}
	return self:polygon(vertices, mode)
end

--[[
	Draws a diamond

	@param   number   center x
	@param   number   center y
	@param   number   width
	@param   mixed    drawMode (fill, line, false) [def: self.mode]
	@return  table    vertices {x1, y2, x2, y2, x3, y3, x4, y4, x5, y5}
	@uses    self:polygon()
--]]
function draft:diamond(cx, cy, width, mode)
	local widthRadius = width / 2
	local depth = math.sqrt(math.pow(width, 2) - math.pow(widthRadius, 2)) / 2
	local height = depth / 2
	local topOffset = widthRadius / 3 * 2
	local vertices = {
		cx - widthRadius, cy,
		cx - topOffset, cy - height,
		cx + topOffset, cy - height,
		cx + widthRadius, cy,
		cx, cy + depth
	}
	return self:polygon(vertices, mode)
end

----------------------------------------------------
-- Tertiary shapes (using secondary shape functions)
----------------------------------------------------

--[[
	Draws an equiangular rhombus (square rotated 45˚)

	@param   number   center x
	@param   number   center y
	@param   number   length of one side (width or height)
	@param   mixed    drawMode (fill, line, false) [def: self.mode]
	@return  table    vertices {x1, y2, x2, y2, x3, y3, x4, y4}
	@uses    self:rhombus()
--]]
function draft:rhombusEquilateral(cx, cy, length, mode)
	return self:rhombus(cx, cy, length, length, mode)
end

--[[
	Draws a lozenge (rhombus with 45 degree angles)

	@param   number   center x
	@param   number   center y
	@param   number   width
	@param   mixed    drawMode (fill, line, false) [def: self.mode]
	@return  table    vertices {x1, y2, x2, y2, x3, y3, x4, y4}
	@uses    self:rhombus()
	
--]]
function draft:lozenge(cx, cy, width, mode)
	return self:rhombus(cx, cy, width, width * 2, mode)
end

--[[
	Draws a kite

	@param   number   center x
	@param   number   center y
	@param   number   width
	@param   number   height
	@param   number   depth
	@param   mixed    drawMode (fill, line, false) [def: self.mode]
	@return  table    vertices {x1, y2, x2, y2, x3, y3, x4, y4}
	@uses    self:trapezium()

--]]
function draft:kite(cx, cy, width, height, depth, mode)
	return self:trapezium(cx, cy, width, width, height, depth, mode)
end

--[[
	Draws an isosceles trapezoid

	@param   number   center x
	@param   number   center y
	@param   number   width (bottom)
	@param   number   height
	@param   number   top width
	@param   mixed    drawMode (fill, line, false) [def: self.mode]
	@return  table    vertices {x1, y2, x2, y2, x3, y3, x4, y4}
	@uses    self:trapezoid()
--]]
function draft:trapezoidIsosceles(cx, cy, width, height, widthTop, mode)
	return self:trapezoid(cx, cy, width, height, widthTop, 0, mode)
end

--[[
	Draws a parallelogram

	@param   number   center x
	@param   number   center y
	@param   number   width
	@param   number   height
	@param   number   width offset (to the left)
	@param   mixed    drawMode (fill, line, false) [def: self.mode]
	@return  table    vertices {x1, y2, x2, y2, x3, y3, x4, y4}
	@uses    self:trapezoid()
--]]
function draft:parallelogram(cx, cy, width, height, widthOffset, mode)
	return self:trapezoid(cx, cy, width, height, width, widthOffset, mode)
end

----------------------------------------------------
-- Curved shapes
----------------------------------------------------

--[[
	Draws all kinds of curved shapes

	Based on code from: http://slabode.exofire.net/circle_draw.shtml

	@param   number   center x
	@param   number   center y
	@param   number   width
	@param   number   arc angle
	@param   number   start angle [def: 0]
	@param   number   number of segments [def: math.floor(10 * math.sqrt(radius))]
	@param   bool     wrap the arc upon itself [def: false]
	@param   mixed    scale (table {x, y} or function (x, y, segmentNum, numSegments)) [def: nil]
	@param   mixed    drawMode (fill, line, false) [def: self.mode]
	@return  table    vertices {x1, y1, x2, y2, ...}
	@uses    self:polygon(), self:line()
--]]
function draft:compass(cx, cy, width, arcAngle, startAngle, numSegments, wrap, scale, mode)
	if mode == nil then mode = self.mode end
	local radius = width / 2
	startAngle = startAngle or 0
	numSegments = numSegments or math.floor(10 * math.sqrt(radius))
	if wrap == true then wrap = 0 else wrap = -1 end
	local theta = arcAngle / (numSegments - wrap)
	local cosine = math.cos(theta)
	local sine = math.sin(theta)
	local x = radius * math.cos(startAngle)
	local y = radius * math.sin(startAngle)
	local vertices = {}
	for i = 1, numSegments, 1 do
		local vx, vy
		if type(scale) == 'function' then
			vx, vy = scale(x,y,i,numSegments)
		elseif type(scale) == 'table' then
			vx = x * scale[1]
			vy = y * scale[2]
		else
			vx = x
			vy = y
		end
		table.insert(vertices, vx + cx)
		table.insert(vertices, vy + cy)
		local t = x
		x = (cosine * x) - (sine * y)
		y = (sine * t) + (cosine * y)
	end
	if mode then 
		if wrap == 0 then
			self:polygon(vertices, mode)
		else
			self:line(vertices, mode)
		end
	end
	return vertices
end

--[[
	Draws a circle (regular polygon)

	@param   number   center x
	@param   number   center y
	@param   number   radius
	@param   number   number of segments [def: 10 * math.sqrt(radius)]
	@param   mixed    drawMode (fill, line, false) [def: self.mode]
	@return  table    vertices {x1, y1, x2, y2, ...}
	@uses    self:compass()
--]]
function draft:circle(cx, cy, radius, numSegments, mode)
	return self:compass(cx, cy, radius, 2 * math.pi, 0, numSegments, true, nil, mode)
end

--[[
	Draws an arc

	@param   number   center x
	@param   number   center y
	@param   number   radius
	@param   number   arc angle
	@param   number   start angle [def: 0]
	@param   number   number of segments [def: 10 * math.sqrt(radius)]
	@param   mixed    drawMode (fill, line, false) [def: self.mode]
	@return  table    vertices {x1, y1, x2, y2, ...}
	@uses    self:compass()
--]]
function draft:arc(cx, cy, radius, arcAngle, startAngle, numSegments, mode)
	return self:compass(cx, cy, radius, arcAngle, startAngle, numSegments, false, nil, mode)
end

--[[
	Draws a bow (closed arc)

	@param   number   center x
	@param   number   center y
	@param   number   radius
	@param   number   arc angle
	@param   number   start angle [def: 0]
	@param   number   number of segments [def: 10 * math.sqrt(radius)]
	@param   mixed    drawMode (fill, line, false) [def: self.mode]
	@return  table    vertices {x1, y1, x2, y2, ...}
	@uses    self:compass()
--]]
function draft:bow(cx, cy, radius, arcAngle, startAngle, numSegments, mode)
	return self:compass(cx, cy, radius, arcAngle, startAngle, numSegments, true, nil, mode)
end

--[[
	Draws a pie

	@param   number   center x
	@param   number   center y
	@param   number   radius
	@param   number   arc angle
	@param   number   start angle [def: 0]
	@param   number   number of segments [def: 10 * math.sqrt(radius)]
	@param   mixed    drawMode (fill, line, false) [def: self.mode]
	@return  table    vertices {x1, y1, x2, y2, ...}
	@uses    self:compass(), appendVertices(), self:polygon()
--]]
function draft:pie(cx, cy, radius, arcAngle, startAngle, numSegments, mode)
	local vertices = self:compass(cx, cy, radius, arcAngle, startAngle, numSegments, false, nil, false)
	vertices = appendVertices(vertices, {cx, cy})
	return self:polygon(vertices, mode)
end

--[[
	Draws an ellipse

	@param   number   center x
	@param   number   center y
	@param   number   width
	@param   number   height
	@param   number   number of segments [def: 10 * math.sqrt(radius)]
	@param   mixed    drawMode (fill, line, false) [def: self.mode]
	@return  table    vertices {x1, y1, x2, y2, ...}
	@uses    self:compass()
--]]
function draft:ellipse(cx, cy, width, height, numSegments, mode)
	return self:compass(cx, cy, width, 2 * math.pi, 0, numSegments, true, {1, height / width}, mode)
end

--[[
	Draws an elliptic arc

	@param   number   center x
	@param   number   center y
	@param   number   width
	@param   number   height
	@param   number   arc angle
	@param   number   start angle [def: 0]
	@param   number   number of segments [def: 10 * math.sqrt(radius)]
	@param   mixed    drawMode (fill, line, false) [def: self.mode]
	@return  table    vertices {x1, y1, x2, y2, ...}
	@uses    self:compass()
--]]
function draft:ellipticArc(cx, cy, width, height, arcAngle, startAngle, numSegments, mode)
	return self:compass(cx, cy, width, arcAngle, startAngle, numSegments, false, {1, height / width}, mode)
end

--[[
	Draws an elliptic bow (closed elliptic arc)

	@param   number   center x
	@param   number   center y
	@param   number   width
	@param   number   height
	@param   number   arc angle
	@param   number   start angle [def: 0]
	@param   number   number of segments [def: 10 * math.sqrt(radius)]
	@param   mixed    drawMode (fill, line, false) [def: self.mode]
	@return  table    vertices {x1, y1, x2, y2, ...}
	@uses    self:compass()
--]]
function draft:ellipticBow(cx, cy, width, height, arcAngle, startAngle, numSegments, mode)
	return self:compass(cx, cy, width, arcAngle, startAngle, numSegments, true, {1, height / width}, mode)
end

--[[
	Draws an elliptic pie

	@param   number   center x
	@param   number   center y
	@param   number   width
	@param   number   height
	@param   number   arc angle
	@param   number   start angle [def: 0]
	@param   number   number of segments [def: 10 * math.sqrt(radius)]
	@param   mixed    drawMode (fill, line, false) [def: self.mode]
	@return  table    vertices {x1, y1, x2, y2, ...}
	@uses    self:compass(), appendVertices(), self:polygon()
--]]
function draft:ellipticPie(cx, cy, width, height, arcAngle, startAngle, numSegments, mode)
	local vertices = self:compass(cx, cy, width, arcAngle, startAngle, numSegments, false, {1, height / width}, false)
	vertices = appendVertices(vertices, {cx, cy})
	return self:polygon(vertices, mode)
end

--[[
	Draws a semicircle

	@param   number   center x
	@param   number   center y
	@param   number   width
	@param   number   start angle
	@param   number   number of segments [def: 10 * math.sqrt(radius)]
	@param   mixed    drawMode (fill, line, false) [def: self.mode]
	@return  table    vertices {x1, y1, x2, y2, ...}
	@uses    self:compass()
--]]
function draft:semicircle(cx, cy, width, startAngle, numSegments, mode)
	return self:compass(cx, cy, width / 2, math.rad(180), startAngle, numSegments, false, nil, mode)
end

--[[
	Draws a dome (closed semicircle)

	@param   number   center x
	@param   number   center y
	@param   number   width
	@param   number   start angle
	@param   number   number of segments [def: 10 * math.sqrt(radius)]
	@param   mixed    drawMode (fill, line, false) [def: self.mode]
	@return  table    vertices {x1, y1, x2, y2, ...}
	@uses    self:compass()
--]]
function draft:dome(cx, cy, width, startAngle, numSegments, mode)
	return self:compass(cx, cy, width / 2, math.rad(180), startAngle, numSegments, true, nil, mode)
end

----------------------------------------------------
-- Complex shapes
----------------------------------------------------

--[[
	Draws a star

	@param   number   center x
	@param   number   center y
	@param   number   width
	@param   number   inner width
	@param   number   number of points [def: 5]
	@param   number   start angle [def: 0]
	@param   mixed    drawMode (fill, line, false) [def: self.mode]
	@return  table    vertices {x1, y1, x2, y2, ...}
	@uses    self:compass()
--]]
function draft:star(cx, cy, width, widthInner, numPoints, startAngle, mode)
	widthInner = widthInner or width / 2
	numPoints = numPoints or 5
	local scale = function(cx, cy, segmentNum)
		if segmentNum % 2 == 0 then
			cx = cx * (widthInner / width)
			cy = cy * (widthInner / width)
		end
		return cx, cy
	end
	return self:compass(cx, cy, width, 2 * math.pi, startAngle, numPoints * 2, true, scale, mode)
end

--[[
	Draws an egg

	@param   number   center x
	@param   number   center y
	@param   number   width
	@param   number   scale y bottom [def: 0.8]
	@param   number   scale y top [def: 2]
	@param   number   number of segments [def: math.floor(10 * math.sqrt(radius))]
	@param   mixed    drawMode (fill, line, false) [def: self.mode]
	@return  table    vertices {x1, y1, x2, y2, ...}
	@uses    self:compass()
--]]
function draft:egg(cx, cy, width, syBottom, syTop, numSegments, mode)
	syBottom = syBottom or 0.8
	syTop = syTop or 2 
	local scale = function(cx, cy, segmentNum, numSegments)
		if segmentNum <= numSegments / 2 then
			cy = cy * syBottom
		else
			cy = cy * syTop
		end
		return cx, cy
	end
	return self:compass(cx, cy, width, 2 * math.pi, 0, numSegments, true, scale, mode)
end

----------------------------------------------------
-- Linkers (draw lines between points)
----------------------------------------------------

--[[
	Draws lines between two sets of vertices in ladder style

	Ladder style means point A->A, B->B, C->C, etc...

	Note: The sets of vertices must be the same size.

	@param   table    vertices 1
	@param   table    vertices 2
	@param   mixed    drawMode (fill, line, false) [def: self.mode]
	@return  table    lines {{x1, y1, x2, y2}, {x1, x2, y1, y2}, …}
	@uses    self:line()
--]]
function draft:linkLadder(v1, v2, mode)
	local lines = {}
	for i=1, #v1, 2 do
		table.insert(lines, self:line({v1[i], v1[i+1], v2[i], v2[i+1]}, mode))
	end
	return lines
end

--[[
	Draws lines between two sets of vertices in tangle style

	Tangle style means each point of one set of vertices
	to all the points of the other set of vertices.

	@param   table    vertices 1
	@param   table    vertices 2
	@param   mixed    drawMode (fill, line, false) [def: self.mode]
	@return  table    lines {{x1, y1, x2, y2}, {x1, x2, y1, y2}, …}
	@uses    self:line()
--]]
function draft:linkTangle(v1, v2, mode)
	local lines = {}
	for i=1, #v1, 2 do
		for j=1, #v2, 2 do
			table.insert(lines, self:line({v1[i], v1[i+1], v2[j], v2[j+1]}, mode))
		end
	end
	return lines
end

--[[
	Draws lines between vertices in web style

	Web style means each point to all other points.

	@param   table    vertices
	@param   mixed    drawMode (fill, line, false) [def: self.mode]
	@return  table    lines {{x1, y1, x2, y2}, {x1, x2, y1, y2}, …}
	@uses    self:line()
--]]
function draft:linkWeb(v, mode)
	local lines = {}
	local limit = #v - 2
	for i=1, #v-4, 2 do
		if i == 3 then limit = limit + 2 end
		for j=i+4, limit, 2 do
			table.insert(lines, self:line({v[i], v[i+1], v[j], v[j+1]}, mode))
		end
	end
	return lines
end

--[[
	Draws a linkTangle and linkWeb between two sets of vertices

	@param   table    vertices 1
	@param   table    vertices 2
	@param   mixed    drawMode (fill, line, false) [def: self.mode]
	@return  table    lines {{x1, y1, x2, y2}, {x1, x2, y1, y2}, …}
	@uses    self:linkTangle(), self:linkWeb()
--]]
function draft:linkTangleWebs(v1, v2, mode)
	local lines = {}
	table.insert(lines, self:linkTangle(v1, v2, mode))
	table.insert(lines, self:linkWeb(v1, mode))
	table.insert(lines, self:linkWeb(v2, mode))
	return lines
end

----------------------------------------------------
-- Module
----------------------------------------------------

return setmetatable({new = new},
	{__call = function(_, ...) return new(...) end})
