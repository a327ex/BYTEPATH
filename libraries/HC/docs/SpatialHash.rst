HC.spatialhash
==============

::

  spatialhash = require 'HC.spatialhash'

A spatial hash implementation that supports scenes of arbitrary size. The hash
is sparse, which means that cells will only be created when needed.


.. class:: Spatialhash([cellsize = 100])

   :param number cellsize: Width and height of a cell (optional).

Create a new spatial hash with a given cell size.

Choosing a good cell size depends on your application. To get a decent speedup,
the average cell should not contain too many objects, nor should a single
object occupy too many cells. A good rule of thumb is to choose the cell size
so that the average object will occupy only one cell.

.. note::
    The syntax depends on used class system. The shown syntax works when using
    the bundled `hump.class <http://vrld.github.com/hump/#hump.class>`_ or
    `slither <https://bitbucket.org/bartbes/slither>`_.

**Example**::

    Spatialhash = require 'hardoncollider.spatialhash'
    hash = Spatialhash(150)


.. function:: Spatialhash:cellCoords(x,y)

   :param numbers x, y: The position to query.
   :returns: Coordinates of the cell which would contain ``x,y``.

Get coordinates of a given value, i.e. the cell index in which a given point
would be placed.

**Example**::

    local mx,my = love.mouse.getPosition()
    cx, cy = hash:cellCoords(mx, my)


.. function:: Spatialhash:cell(i,k)

   :param numbers i, k: The cell index.
   :returns: Set of objects contained in the cell.

Get the cell with given coordinates.

A cell is a table which's keys and value are the objects stored in the cell,
i.e.::

    cell = {
        [obj1] = obj1,
        [obj2] = obj2,
        ...
    }

You can iterate over the objects in a cell using ``pairs()``::

    for object in pairs(cell) do stuff(object) end

**Example**::

    local mx,my = love.mouse.getPosition()
    cx, cy = hash:cellCoords(mx, my)
    cell = hash:cell(cx, cy)


.. function:: Spatialhash:cellAt(x,y)

   :param numbers x, y: The position to query.
   :returns: Set of objects contained in the cell.

Get the cell that contains point x,y.

Same as ``hash:cell(hash:cellCoords(x,y))``

**Example**::

    local mx,my = love.mouse.getPosition()
    cell = hash:cellAt(mx, my)


.. function:: Spatialhash:shapes()

   :returns: Set of all shapes in the hash.

Get *all* shapes that are recorded in the hash.


.. function:: Spatialhash:inSameCells(x1,y1, x2,y2)

   :param numbers x1,y1: Upper left corner of the query bounding box.
   :param numbers x2,y2: Lower right corner of the query bounding box.
   :returns: Set of all shapes in the same cell as the bbox.

Get the shapes that are in the same cell as the defined bounding box.


.. function:: Spatialhash:register(obj, x1,y1, x2,y2)

   :param mixed obj: Object to place in the hash. It can be of any type except `nil`.
   :param numbers x1,y1: Upper left corner of the bounding box.
   :param numbers x2,y2: Lower right corner of the bounding box.

Insert an object into the hash using a given bounding box.

**Example**::

    hash:register(shape, shape:bbox())


.. function:: Spatialhash:remove(obj[, x1,y1[, x2,y2]])

   :param mixed obj: The object to delete
   :param numbers x1,y1: Upper left corner of the bounding box (optional).
   :param numbers x2,y2: Lower right corner of the bounding box (optional).

Remove an object from the hash using a bounding box.

If no bounding box is given, search the whole hash to delete the object.

**Example**::

    hash:remove(shape, shape:bbox())
    hash:remove(object_with_unknown_position)


.. function:: Spatialhash:update(obj, x1,y1, x2,y2, x3,y3, x4,y4)

   :param mixed obj: The object to be updated.
   :param numbers x1,y1: Upper left corner of the bounding box before the object was moved.
   :param numbers x2,y2: Lower right corner of the bounding box before the object was moved.
   :param numbers x3,y3: Upper left corner of the bounding box after the object was moved.
   :param numbers x4,y4: Lower right corner of the bounding box after the object was moved.

Update an objects position given the old bounding box and the new bounding box.

**Example**::

    hash:update(shape, -100,-30, 0,60, -100,-70, 0,20)


.. function:: Spatialhash:draw(draw_mode[, show_empty = true[, print_key = false]])

   :param string draw_mode: Either 'fill' or 'line'. See the LÖVE wiki.
   :param boolean show_empty: Wether to draw empty cells (optional).
   :param boolean print_key: Wether to print cell coordinates (optional).

Draw hash cells on the screen, mostly for debug purposes

**Example**::

    love.graphics.setColor(160,140,100,100)
    hash:draw('line', true, true)
    hash:draw('fill', false)


