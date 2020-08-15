Main Module
===========

::

  HC = require 'HC'

The purpose of the main modules is to connect shapes with the spatial hash -- a
data structure to quickly look up neighboring shapes -- and to provide
utilities to tell which shapes intersect (collide) with each other.

Most of the time, HC will be run as a singleton; you can, however, also create
several instances, that each hold their own little worlds.

Initialization
--------------

.. function:: HC.new([cell_size = 100])

   :param number cell_size: Resolution of the internal search structure (optional).
   :returns: Collider instance.

Creates a new collider instance that holds a separate spatial hash.
Collider instances carry the same methods as the main module.
The only difference is that function calls must use the colon-syntax (see
below).

Useful if you want to maintain several collision layers or several separate
game worlds.

The ``cell_size`` somewhat governs the performance of :func:`HC.neighbors` and
:func:`HC.collisions`. How this parameter affects the performance depends on
how many shapes there are, how big these shapes are and (somewhat) how the
shapes are distributed.
A rule of thumb would be to set ``cell_size`` to be about four times the size
of the average object.
Or just leave it as is and worry about it only if you run into performance
problems that can be traced back to the spatial hash.

**Example**::

  collider = HC.new(150) -- create separate world

  -- method calls with colon syntax
  ball = collider:circle(100,100,20)
  rect = collider:rectangle(110,90,20,100)

  for shape, delta in pairs(collider:collisions(ball)) do
      shape:move(delta.x, delta.y)
  end


.. function:: HC.resetHash([cell_size = 100])

   :param number cell_size: Resolution of the internal search structure (optional).

Reset the internal search structure, the spatial hash.
This clears *all* shapes that were registered beforehand, meaning that HC will
not be able to find any collisions with those shapes anymore.

**Example**::

  function new_stage()
      actors = {} -- clear the stage on our side
      HC.resetHash() -- as well as on HC's side
  end



Shapes
------

See also the :doc:`Shapes` sub-module.

.. note::

  HC will only keep `weak references
  <https://www.lua.org/manual/5.1/manual.html#2.10.2>`_ to the shapes you add
  to the world. This means that if you don't store the shapes elsewhere, the
  garbage collector will eventually come around and remove these shapes.See
  also `this issue <https://github.com/vrld/HC/issues/44>`_ on github.


.. function:: HC.rectangle(x, y, w, h)

   :param numbers x,y: Upper left corner of the rectangle.
   :param numbers w,h: Width and height of the rectangle.
   :returns: The rectangle :class:`Shape` added to the scene.

Add a rectangle shape to the scene.

.. note::
    :class:`Shape` transformations, e.g. :func:`Shape.moveTo` and
    :func:`Shape.rotate` will be with respect to the *center, not* the upper left
    corner of the rectangle!

**Example**::

   rect = HC.rectangle(100, 120, 200, 40)
   rect:rotate(23)


.. function:: HC.polygon(x1,y1,...,xn,yn)

   :param numbers x1,y1,...,xn,yn: The corners of the polygon. At least three
                                   corners that do not lie on a straight line
                                   are required.
   :returns: The polygon :class:`Shape` added to the scene.

Add a polygon to the scene. Any non-self-intersection polygon will work.
The polygon will be closed; the first and the last point do not need to be the
same.

.. note::
    If three consecutive points lie on a line, the middle point will be discarded.
    This means you cannot construct polygon shapes that are lines.

.. note::
    :class:`Shape` transformations, e.g. :func:`Shape.moveTo` and
    :func:`Shape.rotate` will be with respect to the center of the polygon.

**Example**::

   shape = HC.polygon(10,10, 40,50, 70,10, 40,30)
   shape:move(42, 5)


.. function:: HC.circle(cx, cy, radius)

   :param numbers cx,cy: Center of the circle.
   :param number radius: Radius of the circle.
   :returns: The circle :class:`Shape` added to the scene.

Add a circle shape to the scene.

**Example**::

   circle = HC.circle(400, 300, 100)


.. function:: HC.point(x, y)

   :param numbers x, y: Position of the point.
   :returns: The point :class:`Shape` added to the scene.

Add a point shape to the scene.

Point shapes are most useful for bullets and such, because detecting collisions
between a point and any other shape is a little faster than detecting collision
between two non-point shapes. In case of a collision, the separating vector
will not be valid.

**Example**::

    bullets[#bulltes+1] = HC.point(player.pos.x, player.pos.y)


.. function:: HC.register(shape)

   :param Shape shape: The :class:`Shape` to add to the spatial hash.

Add a shape to the bookkeeping system.
:func:`HC.neighbors` and :func:`Hc.collisions` works only with registered
shapes.
You don't need to (and should not) register any shapes created with the above
functions.

Overwrites :func:`Shape.move`, :func:`Shape.rotate`, and :func:`Shape.scale`
with versions that update the :doc:`SpatialHash`.

This function is mostly only useful if you provide a custom shape.
See :ref:`custom-shapes`.


.. function:: HC.remove(shape)

   :param Shape shape: The :class:`Shape` to remove from the spatial hash.

Remove a shape to the bookkeeping system.

.. warning::
    This will also invalidate the functions :func:`Shape.move`,
    :func:`Shape.rotate`, and :func:`Shape.scale`.
    Make sure you delete the shape from your own actor list(s).

**Example**::

    for i = #bullets,1,-1 do
        if bullets[i]:collidesWith(player)
            player:takeDamage()

            HC.remove(bullets[i]) -- remove bullet from HC
            table.remove(bullets, i) -- remove bullet from own actor list
        end
    end


Collision Detection
-------------------

.. function:: HC.collisions(shape)

   :param Shape shape: Query shape.
   :returns: Table of colliding shapes and separating vectors.


Get shapes that are colliding with ``shape`` and the vector to separate the shapes.
The separating vector points away from ``shape``.

The table is a *set*, meaning that the shapes are stored in *keys* of the table.
The *values* are the separating vector.
You can iterate over the shapes using ``pairs`` (see example).

**Example**::

    local collisions = HC.collisions(shape)
    for other, separating_vector in pairs(collisions)
        shape:move(-separating_vector.x/2, -separating_vector.y/2)
        other:move( separating_vector.x/2,  separating_vector.y/2)
    end


.. function:: HC.neighbors(shape)

   :param Shape shape: Query shape.
   :returns: Table of neighboring shapes, where the keys of the table are the shape.

Get other shapes in that are close to ``shape``.
The table is a *set*, meaning that the shapes are stored in *keys* of the table.
You can iterate over the shapes using ``pairs`` (see example).

.. note::
    The result depends on the size and position of ``shape`` as well as the
    grid size of the spatial hash: :func:`HC.neighbors` returns the shapes that
    are in the same cell(s) as ``shape``.

**Example**::

    local candidates = HC.neighbors(shape)
    for other in pairs(candidates)
        local collides, dx, dy = shape:collidesWith(other)
        if collides then
            other:move(dx, dy)
        end
    end


.. attribute:: HC.hash

Reference to the :class:`SpatialHash` instance.
