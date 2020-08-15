HC.shapes
=========

::

  shapes = require 'HC.shapes'

Shape classes with collision detection methods.

This module defines methods to move, rotate and draw shapes created with the
main module.

As each shape is at it's core a Lua table, you can attach values and add
functions to it. Be careful not to use keys that name a function or start with
an underscore, e.g. `move` or `_rotation`, since these are used internally.
Everything else is fine.

If you don't want to use the full blown module, you can still use these classes
to test for colliding shapes.
This may be useful for scenes where the shapes don't move very much and only
few collisions are of interest - for example graphical user interfaces.


.. _shape-baseclass:

Base Class
----------

.. class:: Shape(type)

   :param any type: Arbitrary type identifier of the shape's type.

Base class for all shapes. All shapes must conform to the interface defined below.

.. function:: Shape:move(dx, dy)

   :param numbers dx,dy: Coordinates to move the shape by.

Move the shape *by* some distance.

**Example**::

    circle:move(10, 15) -- move the circle 10 units right and 15 units down.


.. function:: Shape:moveTo(x, y)

   :param numbers x,y: Coordinates to move the shape to.

Move the shape *to* some point. Most shapes will be *centered* on the point
``(x,y)``.

.. note::
    Equivalent to::

        local cx,cy = shape:center()
        shape:move(x-cx, y-cy)

**Example**::

    local x,y = love.mouse.getPosition()
    circle:moveTo(x, y) -- move the circle with the mouse


.. function:: Shape:center()

   :returns: ``x, y`` - The center of the shape.

Get the shape's center.

**Example**::

    local cx, cy = circle:center()
    print("Circle at:", cx, cy)

.. function:: Shape:rotate(angle[, cx, cy])

   :param number angle: Amount of rotation in radians.
   :param numbers cx, cy: Rotation center; defaults to the shape's center if omitted (optional).

Rotate the shape *by* some angle. A rotation center can be specified. If no
center is given, rotate around the center of the shape.

**Example**::

    rectangle:rotate(math.pi/4)


.. function:: Shape:setRotation(angle[, cx, cy])

   :param number angle: Amount of rotation in radians.
   :param numbers cx, cy: Rotation center; defaults to the shape's center if omitted (optional).

Set the rotation of a shape. A rotation center can be specified. If no center
is given, rotate around the center of the shape.

.. note::
    Equivalent to::

        shape:rotate(angle - shape:rotation(), cx,cy)

**Example**::

    rectangle:setRotation(math.pi, 100,100)


.. function:: Shape:rotation()

   :returns: The shape's rotation in radians.

Get the rotation of the shape in radians.


.. function:: Shape:scale(s)

   :param number s: Scale factor; must be > 0.

Scale the shape relative to it's center.

.. note::

    There is no way to query the scale of a shape.

**Example**::

    circle:scale(2) -- double the size


.. function:: Shape:outcircle()

   :returns: ``x, y, r`` - Parameters of the outcircle.

Get parameters of a circle that fully encloses the shape.

**Example**::

    if player:hasShield() then
        love.graphics.circle('line', player:outcircle())
    end

.. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. ..

.. function:: Shape:bbox()

   :returns: ``x1, y1, x2, y2`` - Corners of the counding box.

Get axis aligned bounding box.
``x1, y1`` defines the upper left corner, while ``x2, y2`` define the lower
right corner.

**Example**::

    -- draw bounding box
    local x1,y1, x2,y2 = shape:bbox()
    love.graphics.rectangle('line', x1,y1, x2-x1,y2-y1)


.. function:: Shape:draw(mode)

    :param DrawMode mode: How to draw the shape. Either 'line' or 'fill'.

Draw the shape either filled or as outline. Mostly for debug-purposes.

**Example**::

    circle:draw('fill')

.. function:: Shape:support(dx,dy)

   :param numbers dx, dy: Search direction.
   :returns: The furthest vertex in direction `dx, dy`.

Get furthest vertex of the shape with respect to the direction ``dx, dy``.

Used in the collision detection algorithm, but may be useful for other things -
e.g. lighting - too.

**Example**::

    -- get vertices that produce a shadow volume
    local x1,y1 = circle:support(lx, ly)
    local x2,y2 = circle:support(-lx, -ly)


.. function:: Shape:collidesWith(other)

   :param Shape other: Test for collision with this shape.
   :returns: ``collide, dx, dy`` - Collision indicator and separating vector.

Test if two shapes collide.

The separating vector ``dx, dy`` will only be defined if ``collide`` is ``true``.
If defined, the separating vector will point in the direction of ``other``,
i.e. ``dx, dy`` is the direction and magnitude to move ``other`` so that the
shapes do not collide anymore.

**Example**::

    if circle:collidesWith(rectangle) then
        print("collision detected!")
    end


.. function:: Shape:contains(x, y)

    :param numbers x, y: Point to test.
    :returns: ``true`` if ``x,y`` lies in the interior of the shape.

Test if the shape contains a given point.

**Example**::

    if unit.shape:contains(love.mouse.getPosition) then
        unit:setHovered(true)
    end


.. function:: Shape:intersectionsWithRay(x, y, dx, dy)

   :param numbers x, y: Starting point of the ray.
   :param numbers dx, dy: Direction of the ray.
   :returns: Table of ray parameters.

Test if the shape intersects the given ray.
The ray parameters of the intersections are returned as a table.
The position of the intersections can be computed as
``(x,y) + ray_parameter * (dx, dy)``.


**Example**::

    local ts = player:intersectionsWithRay(x,y, dx,dy)
    for _, t in ipairs(t) do
        -- find point of intersection
        local vx,vy = vector.add(x, y, vector.mul(t, dx, dy))
        player:addMark(vx,vy)
    end


.. function:: Shape:intersectsRay(x, y, dx, dy)

   :param numbers x, y: Starting point of the ray.
   :param numbers dx, dy: Direction of the ray.
   :returns: ``intersects, ray_parameter`` - intersection indicator and ray paremter.

Test if the shape intersects the given ray.
If the shape intersects the ray, the point of intersection can be computed by
``(x,y) + ray_parameter * (dx, dy)``.


**Example**::

    local intersecting, t = player:intersectsRay(x,y, dx,dy)
    if intersecting then
        -- find point of intersection
        local vx,vy = vector.add(x, y, vector.mul(t, dx, dy))
        player:addMark(vx,vy)
    end



.. _custom-shapes:

Custom Shapes
-------------

Custom shapes must implement at least the following methods (as defined above)

- :func:`Shape:move`
- :func:`Shape:rotate`
- :func:`Shape:scale`
- :func:`Shape:bbox`
- :func:`Shape:collidesWith`


.. _builtin-shapes:

Built-in Shapes
---------------

.. class:: ConcavePolygonShape

.. class:: ConvexPolygonShape

.. class:: CircleShape

.. class:: PointShape

.. function:: newPolygonShape(...)

   :param numbers ...: Vertices of the :class:`Polygon`.
   :returns: :class:`ConcavePolygonShape` or :class:`ConvexPolygonShape`.

.. function:: newCircleShape(cx, cy, radius)

   :param numbers cx,cy: Center of the circle.
   :param number radius: Radius of the circle.
   :returns: :class:`CircleShape`.

.. function:: newPointShape

   :param numbers x, y: Position of the point.
   :returns: :class:`PointShape`.
