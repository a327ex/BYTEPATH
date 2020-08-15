HC.polygon
==============

::

  polygon = require 'HC.polygon'

Polygon class with some handy algorithms. Does not provide collision detection
- this functionality is provided by :func:`newPolygonShape` instead.

.. class:: Polygon(x1,y1, ..., xn,yn)

   :param numbers x1,y1, ..., xn,yn: The corners of the polygon. At least three corners are needed.
   :returns: The polygon object.

Construct a polygon.

At least three points that are not collinear (i.e. not lying on a straight
line) are needed to construct the polygon. If there are collinear points, these
points will be removed. The shape of the polygon is not changed.

.. note::
    The syntax depends on used class system. The shown syntax works when using
    the bundled `hump.class <http://vrld.github.com/hump/#hump.class>`_ or
    `slither <https://bitbucket.org/bartbes/slither>`_.

**Example**::

    Polygon = require 'HC.polygon'
    poly = Polygon(10,10, 40,50, 70,10, 40,30)


.. function:: Polygon:unpack()

   :returns: ``x1,y1, ..., xn,yn`` - The vertices of the polygon.

Get the polygon's vertices. Useful for drawing with ``love.graphics.polygon()``.

**Example**::

    love.graphics.draw('line', poly:unpack())


.. function:: Polygon:clone()

   :returns: A copy of the polygon.

Get a copy of the polygon.

.. note::
    Since Lua uses references when simply assigning an existing polygon to a
    variable, unexpected things can happen when operating on the variable. Consider
    this code::

        p1 = Polygon(10,10, 40,50, 70,10, 40,30)
        p2 = p1         -- p2 is a reference
        p3 = p1:clone() -- p3 is a clone
        p2:rotate(math.pi) -- p1 will be rotated, too!
        p3:rotate(-math.pi) -- only p3 will be rotated

**Example**::

    copy = poly:clone()
    copy:move(10,20)


.. function:: Polygon:bbox()

   :returns: ``x1, y1, x2, y2`` - Corners of the counding box.

Get axis aligned bounding box.
``x1, y1`` defines the upper left corner, while ``x2, y2`` define the lower
right corner.

**Example**::

    x1,y1,x2,y2 = poly:bbox()
    -- draw bounding box
    love.graphics.rectangle('line', x1,y2, x2-x1, y2-y1)


.. function:: Polygon:isConvex()

   :returns: ``true`` if the polygon is convex, ``false`` otherwise.

Test if a polygon is convex, i.e. a line line between any two points inside the
polygon will lie in the interior of the polygon.

**Example**::

    -- split into convex sub polygons
    if not poly:isConvex() then
        list = poly:splitConvex()
    else
        list = {poly:clone()}
    end


.. function:: Polygon:move(x,y)

   :param numbers x, y: Coordinates of the direction to move.

Move a polygon in a direction..

**Example**::

    poly:move(10,-5) -- move 10 units right and 5 units up


.. function:: Polygon:rotate(angle[, cx, cy])

   :param number angle: The angle to rotate in radians.
   :param numbers cx, cy: The rotation center (optional).

Rotate the polygon. You can define a rotation center. If it is omitted, the
polygon will be rotated around it's centroid.

**Example**::

    p1:rotate(math.pi/2)          -- rotate p1 by 90° around it's center
    p2:rotate(math.pi/4, 100,100) -- rotate p2 by 45° around the point 100,100


.. function:: Polygon:triangulate()

   :returns: ``table`` of Polygons: Triangles that the polygon is composed of.

Split the polygon into triangles.

**Example**::

    triangles = poly:triangulate()
    for i,triangle in ipairs(triangles) do
        triangles.move(math.random(5,10), math.random(5,10))
    end


.. function:: Polygon:splitConvex()

   :returns: ``table`` of Polygons: Convex polygons that form the original polygon.

Split the polygon into convex sub polygons.

**Example**::

    convex = concave_polygon:splitConvex()
    function love.draw()
        for i,poly in ipairs(convex) do
            love.graphics.polygon('fill', poly:unpack())
        end
    end


.. function:: Polygon:mergedWith(other)

   :param Polygon other: The polygon to merge with.
   :returns: The merged polygon, or nil if the two polygons don't share an edge.

Create a merged polygon of two polygons **if, and only if** the two polygons
share one complete edge. If the polygons share more than one edge, the result
may be erroneous.

This function does not change either polygon, but rather creates a new one.

**Example**::

    merged = p1:mergedWith(p2)


.. function:: Polygon:contains(x, y)

   :param numbers x, y: Point to test.
   :returns: ``true`` if ``x,y`` lies in the interior of the polygon.

Test if the polygon contains a given point.

**Example**::

    if button:contains(love.mouse.getPosition()) then
        button:setHovered(true)
    end


.. function:: Polygon:intersectionsWithRay(x, y, dx, dy)

   :param numbers x, y: Starting point of the ray.
   :param numbers dx, dy: Direction of the ray.
   :returns: Table of ray parameters.

Test if the polygon intersects the given ray.
The ray parameters of the intersections are returned as a table.
The position of the intersections can be computed as
``(x,y) + ray_parameter * (dx, dy)``.


.. function:: Polygon:intersectsRay(x, y, dx, dy)

   :param numbers x, y: Starting point of the ray.
   :param numbers dx, dy: Direction of the ray.
   :returns: ``intersects, ray_parameter`` - intersection indicator and ray paremter.

Test if the polygon intersects a ray.
If the shape intersects the ray, the point of intersection can be computed by
``(x,y) + ray_parameter * (dx, dy)``.


**Example**::

    if poly:intersectsRay(400,300, dx,dy) then
        love.graphics.setLine(2) -- highlight polygon
    end


