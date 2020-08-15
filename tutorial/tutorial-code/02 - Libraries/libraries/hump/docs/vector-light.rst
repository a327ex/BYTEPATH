hump.vector-light
=================

::

    vector = require "hump.vector-light"

An table-free version of :doc:`hump.vector <vector>`. Instead of a vector type,
``hump.vector-light`` provides functions that operate on numbers.

.. note::

    Using this module instead of :doc:`hump.vector <vector>` may result in
    faster code, but does so at the expense of speed of development and code
    readability.  Unless you are absolutely sure that your code is
    significantly slowed down by :doc:`hump.vector <vector>`, I recommend using
    it instead.

**Example**::

    function player:update(dt)
        local dx,dy = 0,0
        if love.keyboard.isDown('left') then
            dx = -1
        elseif love.keyboard.isDown('right') then
            dx =  1
        end
        if love.keyboard.isDown('up') then
            dy = -1
        elseif love.keyboard.isDown('down') then
            dy =  1
        end
        dx,dy = vector.normalize(dx, dy)

        player.velx, player.vely = vector.add(player.velx, player.vely,
                                        vector.mul(dy, dx, dy))

        if vector.len(player.velx, player.vely) > player.max_velocity then
            player.velx, player.vely = vector.mul(player.max_velocity,
                                vector.normalize(player.velx, player.vely)
        end

        player.x = player.x + dt * player.velx
        player.y = player.y + dt * player.vely
    end


Function Reference
------------------

.. function:: vector.str(x,y)

   :param numbers x,y:  The vector.
   :returns: The string representation.


Produce a human-readable string of the form ``(x,y)``.
Useful for debugging.

**Example**::

    print(vector.str(love.mouse.getPosition()))


.. function:: vector.fromPolar(angle, radius)

   :param number angle: Angle of the vector in radians.
   :param number radius: Length of the vector.
   :returns: ``x``, ``y``: The vector in cartesian coordinates.


Convert polar coordinates to cartesian coordinates.
The ``angle`` is measured against the vector (1,0), i.e., the x axis.

**Examples**::

    x,y = vector.polar(math.pi,10)


.. function:: vector.toPolar(x, y)

   :param  numbers x,y: A vector.
   :returns: ``angle``, ``radius``: The vector in polar coordinates.

Convert the vector to polar coordinates, i.e., the angle and the radius/lenth.

**Example**::

   -- complex multiplication
   phase1, abs1 = vector.toPolar(re1, im1)
   phase2, abs2 = vector.toPolar(re2, im2)

   vector.fromPolar(phase1+phase2, abs1*abs2)


.. function:: vector.mul(s, x,y)

   :param number s: A scalar.
   :param  numbers x,y: A vector.
   :returns: ``x*s, y*s``.


Computes ``x*s,y*s``. The order of arguments is chosen so that it's possible to
chain operations (see example).

**Example**::

    velx,vely = vec.mul(dt, vec.add(velx,vely, accx,accy))


.. function:: vector.div(s, x,y)

   :param number s: A scalar.
   :param  numbers x,y: A vector.
   :returns: ``x/s, y/s``.


Computes ``x/s,y/s``. The order of arguments is chosen so that it's possible to
chain operations (see example).

**Example**::

    x,y = vec.div(self.zoom, x-w/2, y-h/2)


.. function:: vector.add(x1,y1, x2,y2)

   :param numbers x1,y1: First vector.
   :param  numbers x2,y2: Second vector.
   :returns: ``x1+x2, x1+x2``.


Computes the sum \\((x1+x2, y1+y2)\\)`` of two vectors. Meant to be used in
conjunction with other functions like :func:`vector.mul`.

**Example**::

    player.x,player.y = vector.add(player.x,player.y, vector.mul(dt, dx,dy))


.. function:: vector.sub(x1,y1, x2,y2)

   :param numbers x1,y1: First vector.
   :param  numbers x2,y2: Second vector.
   :returns: ``x1-x2, x1-x2``.


Computes the difference \\((x1-x2, y1-y2)\\) of two vectors. Meant to be used in
conjunction with other functions like :func:`vector.mul`.

**Example**::

    dx,dy = vector.sub(400,300, love.mouse.getPosition())


.. function:: vector.permul(x1,y1, x2,y2)

   :param numbers x1,y1: First vector.
   :param numbers x2,y2: Second vector.
   :returns: ``x1*x2, y1*y2``.


Component-wise multiplication, i.e.: ``x1*x2, y1*y2``.

**Example**::

    x,y = vector.permul(x,y, 1,1.5)


.. function:: vector.dot(x1,y1, x2,y2)

   :param numbers x1,y1: First vector.
   :param numbers x2,y2: Second vector.
   :returns: ``x1*x2 + y1*y2``.


Computes the `dot product <http://en.wikipedia.org/wiki/Dot_product>`_ of two
vectors: ``x1*x2 + y1*y2``.

**Example**::

    cosphi = vector.dot(rx,ry, vx,vy)


.. function:: vector.cross(x1,y1, x2,y2)

   :param numbers x1,y1:  First vector.
   :param numbers x2,y2:  Second vector.
   :returns: ``x1*y2 - y1*x2``.


Computes the `cross product <http://en.wikipedia.org/wiki/Cross_product>`_ of
two vectors: ``x1*y2 - y1*x2``.

**Example**::

    parallelogram_area = vector.cross(ax,ay, bx,by)


.. function:: vector.vector.det(x1,y1, x2,y2)

   :param numbers x1,y1:  First vector.
   :param numbers x2,y2:  Second vector.
   :returns: ``x1*y2 - y1*x2``.


Alias to :func:`vector.cross`.

**Example**::

    parallelogram_area = vector.det(ax,ay, bx,by)


.. function:: vector.eq(x1,y1, x2,y2)

   :param numbers x1,y1: First vector.
   :param numbers x2,y2: Second vector.
   :returns: ``x1 == x2 and y1 == y2``

Test for equality.

**Example**::

    if vector.eq(x1,y1, x2,y2) then be.happy() end


.. function:: vector.le(x1,y1, x2,y2)

   :param numbers x1,y1: First vector.
   :param numbers x2,y2: Second vector.
   :returns: ``x1 <= x2 and y1 <= y2``.

Test for partial lexicographical order, ``<=``.

**Example**::

    if vector.le(x1,y1, x2,y2) then be.happy() end


.. function:: vector.lt(x1,y1, x2,y2)

   :param numbers x1,y1:  First vector.
   :param numbers x2,y2:  Second vector.
   :returns: ``x1 < x2 or (x1 == x2) and y1 <= y2``.


Test for strict lexicographical order, ``<``.

**Example**::

    if vector.lt(x1,y1, x2,y2) then be.happy() end


.. function:: vector.len(x,y)

   :param numbers x,y: The vector.
   :returns: Length of the vector.

Get length of a vector, i.e. ``math.sqrt(x*x + y*y)``.

**Example**::

    distance = vector.len(love.mouse.getPosition())


.. function:: vector.len2(x,y)

   :param numbers x,y: The vector.
   :returns: Squared length of the vector.

Get squared length of a vector, i.e. ``x*x + y*y``.

**Example**::

    -- get closest vertex to a given vector
    closest, dsq = vertices[1], vector.len2(px-vertices[1].x, py-vertices[1].y)
    for i = 2,#vertices do
        local temp = vector.len2(px-vertices[i].x, py-vertices[i].y)
        if temp < dsq then
            closest, dsq = vertices[i], temp
        end
    end


.. function:: vector.dist(x1,y1, x2,y2)

   :param numbers x1,y1:  First vector.
   :param numbers x2,y2:  Second vector.
   :returns: The distance of the points.


Get distance of two points. The same as ``vector.len(x1-x2, y1-y2)``.

**Example**::

    -- get closest vertex to a given vector
    -- slightly slower than the example using len2()
    closest, dist = vertices[1], vector.dist(px,py, vertices[1].x,vertices[1].y)
    for i = 2,#vertices do
        local temp = vector.dist(px,py, vertices[i].x,vertices[i].y)
        if temp < dist then
            closest, dist = vertices[i], temp
        end
    end


.. function:: vector.dist2(x1,y1, x2,y2)

   :param numbers x1,y1:  First vector.
   :param numbers x2,y2:  Second vector.
   :returns: The squared distance of two points.

Get squared distance of two points. The same as ``vector.len2(x1-x2, y1-y2)``.

**Example**::

    -- get closest vertex to a given vector
    closest, dsq = vertices[1], vector.dist2(px,py, vertices[1].x,vertices[1].y)
    for i = 2,#vertices do
        local temp = vector.dist2(px,py, vertices[i].x,vertices[i].y)
        if temp < dsq then
            closest, dsq = vertices[i], temp
        end
    end


.. function:: vector.normalize(x,y)

   :param numbers x,y:  The vector.
   :returns: Vector with same direction as the input vector, but length 1.


Get normalized vector, i.e. a vector with the same direction as the input
vector, but with length 1.

**Example**::

    dx,dy = vector.normalize(vx,vy)


.. function:: vector.rotate(phi, x,y)

   :param number phi:  Rotation angle in radians.
   :param numbers x,y:  The vector.
   :returns: The rotated vector


Get a rotated vector.

**Example**::

    -- approximate a circle
    circle = {}
    for i = 1,30 do
        local phi = 2 * math.pi * i / 30
        circle[i*2-1], circle[i*2] = vector.rotate(phi, 0,1)
    end


.. function:: vector.perpendicular(x,y)

   :param numbers x,y:  The vector.
   :returns: A vector perpendicular to the input vector


Quick rotation by 90°. The same (but faster) as ``vector.rotate(math.pi/2, x,y)``.

**Example**::

    nx,ny = vector.normalize(vector.perpendicular(bx-ax, by-ay))


.. function:: vector.project(x,y, u,v)

   :param numbers x,y:  The vector to project.
   :param numbers u,v:  The vector to project onto.
   :returns: The projected vector.


Project vector onto another vector.

**Example**::

    vx_p,vy_p = vector.project(vx,vy, ax,ay)


.. function:: vector.mirror(x,y, u,v)

   :param numbers x,y:  The vector to mirror.
   :param numbers u,v:  The vector defining the axis.
   :returns: The mirrored vector.


Mirrors vector on the axis defined by the other vector.

**Example**::

    vx,vy = vector.mirror(vx,vy, surface.x,surface.y)


.. function:: vector.angleTo(ox,y, u,v)

   :param numbers x,y:  Vector to measure the angle.
   :param numbers u,v (optional):  Reference vector.
   :returns: Angle in radians.


Measures the angle between two vectors. ``u`` and ``v`` default to ``0`` if omitted,
i.e. the function returns the angle to the coordinate system.

**Example**::

    lean = vector.angleTo(self.upx, self.upy, 0,1)
    if lean > .1 then self:fallOver() end


.. function:: vector.trim(max_length, x,y)

   :param number max_length: Maximum allowed length of the vector.
   :param numbers x,y:  Vector to trum.
   :returns: The trimmed vector.

Trim the vector to ``max_length``, i.e. return a vector that points in the same
direction as the source vector, but has a magnitude smaller or equal to
``max_length``.

**Example**::

    vel_x, vel_y = vector.trim(299792458,
                               vector.add(vel_x, vel_y,
                                          vector.mul(mass * dt, force_x, force_y)))
