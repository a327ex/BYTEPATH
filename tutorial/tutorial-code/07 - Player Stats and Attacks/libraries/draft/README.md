# draft

## About

draft is a simple drafting module for [LÖVE 2D](https://love2d.org/). It makes it easy to draft primitive shapes, and some more luxurious ones.

## Loading the module

To load the module, use the following code.

```lua
-- modify the path depending where draft resides
local Draft = require('draft')
local draft = Draft(modeOption)
```

Setting _mode_ is optional. The default is _fill_.

The drafting functions can then be called inside the `love.draw()` function.

## Usage example

```lua
local Draft = require('draft')
local draft = Draft()

function love.draw()
    draft:rectangle(300, 100, 50, 30)
    draft:rectangle(500, 100, 50, 30)
    draft:rhombus(400, 200, 65, 65)
    draft:bow(390, 280, 100, 2.5, 0, 10, 'line')
end
```

## Notes

 - The _mode_ can be set when initializing the module, but it can also be overwritten with each drafting function. If you want to overwrite it for many functions, you can use the `draft:getMode` and `draft:setMode` functions.

 - You can also set the _mode_ to _false_ if you only want to get the vertices, and not draw the shape. For example, using the following code would get the vertices for a rectangle without drawing it.

    `local vertices = draft:rectangle(100, 100, 50, 80, false)`

 - Look at the file _main.lua_ for examples on how the functions can be called. This file draws all the possible shapes.

 - The `draft:compass` function is a powerful function used to draw curves. Notably, it accepts a function for the scale parameter which permits the drawing of complex shapes. You can look at the code for `draft:star` and `draft:egg` for examples of usage. You can also look at the `draft:compass` function too see how it is called.

 - The linkers create line between points. Try them, they are quite powerful!

## Draft function list

### Initialization
draft(mode)  

### Getters and Setters
draft:getMode()  
draft:setMode(mode)  

### Shapes

#### Primary Shapes (using core drawing functions)

draft:line(points, mode)  
draft:triangleIsosceles(cx, cy, width, height, mode)  
draft:triangleRight(cx, cy, width, height, mode)  
draft:rectangle(cx, cy, width, height, mode)  
draft:polygon(vertices, mode)  

#### Secondary Shapes (using primary shape functions)

draft:triangleEquilateral(cx, cy, width, mode)  
draft:square(cx, cy, length, mode)  
draft:trapezoid(cx, cy, width, height, widthTop, widthTopOffset, mode)  
draft:rhombus(cx, cy, width, height, mode)  
draft:trapezium(cx, cy, widthLeft, widthRight, height, depth, mode)  
draft:gem(cx, cy, widthTop, widthMiddle, height, depth, mode)  
draft:diamond(cx, cy, width, mode)  

#### Tertiary Shapes (using secondary shape functions)

draft:rhombusEquilateral(cx, cy, length, mode)  
draft:lozenge(cx, cy, width, mode)  
draft:kite(cx, cy, width, height, depth, mode)  
draft:trapezoidIsosceles(cx, cy, width, height, widthTop, mode)  
draft:parallelogram(cx, cy, width, height, widthOffset, mode)  

#### Curved Shapes

draft:compass(cx, cy, width, arcAngle, startAngle, numSegments, wrap, scale, mode)  
draft:circle(cx, cy, radius, numSegments, mode)  
draft:arc(cx, cy, radius, arcAngle, startAngle, numSegments, mode)  
draft:bow(cx, cy, radius, arcAngle, startAngle, numSegments, mode)  
draft:pie(cx, cy, radius, arcAngle, startAngle, numSegments, mode)  
draft:ellipse(cx, cy, width, height, numSegments, mode)  
draft:ellipticArc(cx, cy, width, height, arcAngle, startAngle, numSegments, mode)  
draft:ellipticBow(cx, cy, width, height, arcAngle, startAngle, numSegments, mode)  
draft:ellipticPie(cx, cy, width, height, arcAngle, startAngle, numSegments, mode)  
draft:semicircle(cx, cy, width, startAngle, numSegments, mode)  
draft:dome(cx, cy, width, startAngle, numSegments, mode)  

#### Complex Shapes

draft:star(cx, cy, width, widthInner, numPoints, startAngle, mode)  
draft:egg(cx, cy, width, syBottom, syTop, numSegments, mode)

### Linkers
draft:linkLadder(v1, v2, mode)  
draft:linkTangle(v1, v2, mode)  
draft:linkWeb(v, mode)  
draft:linkTangleWebs(v1, v2, mode)  

## example_linker.lua (shows off linking)

```lua
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
```
