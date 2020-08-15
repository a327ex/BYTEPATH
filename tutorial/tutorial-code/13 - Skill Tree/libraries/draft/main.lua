--[[
	Unittest

	This program acts as a unittest by testing all
	of draft's shapes and linkers.
--]]

-- load draft
local Draft = require('draft')
local draft = Draft()

function love.draw()

	-- getters and setters
	love.graphics.setColor{255, 255, 255}
	local y = 100
	draft:setMode('fill')
	love.graphics.print("The current mode is " .. draft:getMode() .. ".", 10, y)
	draft:setMode('line')
	love.graphics.print("The new mode is " .. draft:getMode() .. ".", 10, y + 20)

	-- primary shapes
	love.graphics.setColor{255, 0, 0}
	draft:line({10, 10, 45, 45, 75, 20})
	draft:triangleIsosceles(90, 50, 60, 70)
	draft:triangleIsosceles(90, 50, 40, 35, 'fill')
	draft:triangleIsosceles(200, 200, 200, 200, false)
	draft:triangleRight(150, 30, 50, 40)
	draft:triangleRight(150, 30, 30, 25, 'fill')
	draft:triangleRight(200, 200, 200, 200, false)
	draft:rectangle(210, 25, 50, 30)
	draft:rectangle(210, 25, 40, 20, 'fill')
	draft:rectangle(200, 200, 200, 200, false)
	draft:polygon({250, 10, 250, 90, 290, 75, 275, 30})
	draft:polygon({260, 30, 260, 70, 280, 65, 270, 40}, 'fill')
	draft:polygon({10, 30, 200, 500, 600, 300, 270, 40}, false)

	-- secondary shapes
	love.graphics.setColor{0, 255, 0}
	draft:triangleEquilateral(340, 50, 80)
	draft:triangleEquilateral(340, 50, 50, 'fill')
	draft:triangleEquilateral(200, 200, 200, false)
	draft:square(420, 35, 50)
	draft:square(420, 35, 30, 'fill')
	draft:square(200, 200, 200, false)
	draft:trapezoid(500, 40, 60, 30, 30, 20)
	draft:trapezoid(500, 40, 50, 20, 20, 20, 'fill')
	draft:trapezoid(200, 200, 200, 100, 60, 40, false)
	draft:rhombus(570, 50, 40, 60)
	draft:rhombus(570, 50, 35, 50, 'fill')
	draft:rhombus(200, 200, 200, 150, false)
	draft:trapezium(625, 50, 30, 20, 40, 20)
	draft:trapezium(625, 50, 25, 15, 35, 15, 'fill')
	draft:trapezium(200, 200, 100, 70, 80, 20, false)
	draft:gem(675, 40, 20, 30, 20, 35)
	draft:gem(675, 40, 15, 25, 15, 30, 'fill')
	draft:gem(200, 200, 120, 60, 100, 200, false)
	draft:diamond(730, 30, 50)
	draft:diamond(730, 30, 40, 'fill')
	draft:diamond(200, 200, 200, false)

	-- tertiary shapes
	love.graphics.setColor{0, 0, 255}
	draft:rhombusEquilateral(50, 200, 80)
	draft:rhombusEquilateral(50, 200, 60, 'fill')
	draft:rhombusEquilateral(200, 200, 200, false)
	draft:lozenge(125, 200, 50)
	draft:lozenge(125, 200,30, 'fill')
	draft:lozenge(200, 200, 200, false)
	draft:kite(200, 200, 40, 80, 30)
	draft:kite(200, 200, 30, 75, 25, 'fill')
	draft:kite(200, 200, 200, 200, 100, false)
	draft:trapezoidIsosceles(295, 165, 80, 100, 40)
	draft:trapezoidIsosceles(295, 165, 70, 90, 30, 'fill')
	draft:trapezoidIsosceles(200, 200, 200, 200, 150, false)
	draft:parallelogram(375, 145, 40, 50, 20)
	draft:parallelogram(375, 145, 35, 35, 15, 'fill')
	draft:parallelogram(200, 200, 100, 125, 75, false)

	-- curved shapes
	love.graphics.setColor{127, 127, 127}
	draft:compass(450, 85, 60, math.rad(135), 0, 10, false, nil)
	draft:circle(40, 280, 50)
	draft:circle(40, 280, 40, nil, 'fill')
	draft:circle(200, 200, 200, nil, false)
	draft:arc(435, 130, 60, 2)
	draft:arc(200, 200, 100, 3, 0, 10, false)
	draft:bow(90, 265, 80, 2)
	draft:bow(90, 265, 70, 2, 0, nil, 'fill')
	draft:bow(200, 200, 200, 2, 0, nil, false)
	draft:pie(155, 265, 100, 2)
	draft:pie(155, 265, 80, 2, 0, nil, 'fill')
	draft:pie(300, 300, 300, 2, 0, nil, false)
	draft:ellipse(530, 125, 100, 60)
	draft:ellipse(530, 125, 90, 50, 10, 'fill')
	draft:ellipse(200, 200, 200, 200, nil, false)
	draft:ellipticArc(645, 115, 90, 50, 3)
	draft:ellipticArc(200, 200, 90, 50, 3, 0, nil, false)
	draft:ellipticBow(735, 70, 90, 80, 2.4)
	draft:ellipticBow(735, 70, 90, 70, 2.4, 0, nil, 'fill')
	draft:ellipticBow(250, 250, 250, 70, 2.4, 0, nil, false)
	draft:ellipticPie(275, 275, 125, 100, 2.9, 1)
	draft:ellipticPie(275, 275, 67, 45, 2.9, 1, nil, 'fill')
	draft:ellipticPie(300, 300, 300, 45, 2.9, 1, nil, false)
	draft:semicircle(325, 255, 80, 1)
	draft:semicircle(400, 400, 400, 1, nil, false)
	draft:dome(380, 250, 150, 2.3)
	draft:dome(380, 250, 125, 2.3, 5, 'fill')
	draft:dome(400, 400, 400, 2.3, 5, false)

	-- complex shapes
	love.graphics.setColor{127, 0, 127}
	draft:star(455, 220, 80, 25, 4, 2)
	draft:star(455, 220, 55, 10, 4, 2, 'fill')
	draft:star(500, 500, 80, 14, 6, nil, false)
	draft:egg(540, 220, 50)
	draft:egg(540, 220, 30, nil, nil, nil, 'fill')
	draft:egg(500, 500, 30, nil, nil, nil, false)

	-- linkers
	love.graphics.setColor{255, 127, 0}
	local v1
	local v2

	v1 = draft:line({
			580, 160,
			580, 180,
			580, 200,
			580, 220,
			580, 240,
			580, 260,
			580, 280
	})
	v2 = draft:line({
			580, 280,
			600, 280,
			620, 280,
			640, 280,
			660, 280,
			680, 280,
			700, 280
	})
	draft:linkLadder(v1, v2)

	v1 = draft:square(640, 200, 60)
	v2 = draft:square(680, 190, 60)
	draft:linkTangle(v1, v2)

	v1 = draft:diamond(750, 200, 50)
	draft:linkWeb(v1)

	v1 = draft:square(350, 340, 40)
	v2 = draft:line({400, 330, 420, 310, 440, 270, 420, 240})
	draft:linkTangleWebs(v1, v2)

end
