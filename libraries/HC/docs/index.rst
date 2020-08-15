.. HC documentation master file, created by
   sphinx-quickstart on Thu Oct  8 20:31:43 2015.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

HC - General purpose collision detection with LÖVE_
===================================================

HC is a Lua module to simplify one important aspect in computer games:
Collision detection.

It can detect collisions between arbitrary positioned and rotated shapes.
Built-in shapes are points, circles and polygons.
Any non-intersecting polygons are supported, even concave ones.
You can add other types of shapes if you need them.

The main interface is simple:

1. Set up your scene,
2. Check for collisions,
3. React to collisions.

First steps
-----------

This is an example on how to use HC. One shape will stick to the mouse
position, while the other will stay in the same place::

  HC = require 'HC'

  -- array to hold collision messages
  local text = {}
  
  function love.load()
      -- add a rectangle to the scene
      rect = HC.rectangle(200,400,400,20)
  
      -- add a circle to the scene
      mouse = HC.circle(400,300,20)
      mouse:moveTo(love.mouse.getPosition())
  end
  
  function love.update(dt)
      -- move circle to mouse position
      mouse:moveTo(love.mouse.getPosition())
  
      -- rotate rectangle
      rect:rotate(dt)
  
      -- check for collisions
      for shape, delta in pairs(HC.collisions(mouse)) do
          text[#text+1] = string.format("Colliding. Separating vector = (%s,%s)",
                                        delta.x, delta.y)
      end
  
      while #text > 40 do
          table.remove(text, 1)
      end
  end
  
  function love.draw()
      -- print messages
      for i = 1,#text do
          love.graphics.setColor(255,255,255, 255 - (i-1) * 6)
          love.graphics.print(text[#text - (i-1)], 10, i * 15)
      end
  
      -- shapes can be drawn to the screen
      love.graphics.setColor(255,255,255)
      rect:draw('fill')
      mouse:draw('fill')
  end


Get HC
------

You can download the latest packaged version as `zip <https://github.com/vrld/HC/zipball/master>`_- or `tar <https://github.com/vrld/HC/tarball/master>`_-archive directly
from github_.

You can also have a look at the sourcecode online `here <http://github.com/vrld/HC>`_.

If you use the Git command line client, you can clone the repository by
running::

  git clone git://github.com/vrld/HC.git

Once done, you can check for updates by running::

  git pull

from inside the directory.


Read on
-------

.. toctree::
   :maxdepth: 2

   reference
   tutorial
   license


Indices and tables
^^^^^^^^^^^^^^^^^^

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`


.. _LÖVE: http://love2d.org
.. _github: https://github.com
