-- load draft
local Draft = require('draft')
local draft = Draft()

function love.load()
	limitUpper = 100
	limitLower = 4
	numSegments = limitLower
	direction = "up"
	step = 0.01
end

function love.update(dt)
	if numSegments > limitUpper and direction == "up" then
		direction = "down"
	elseif numSegments < limitLower and direction == "down" then
		direction = "up"
	elseif direction == "up" then
		numSegments = numSegments + step
	else
		numSegments = numSegments - step
	end
end

function love.draw()
	local v = draft:egg(400, 300, 1500, 1, 1, numSegments, 'line')
	draft:linkWeb(v)
end
