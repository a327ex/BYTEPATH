hump.camera
===========

::

    Camera = require "hump.camera"

A camera utility for LÖVE. A camera can "look" at a position. It can zoom in
and out and it can rotate it's view. In the background, this is done by
actually moving, scaling and rotating everything in the game world. But don't
worry about that.

**Example**::

    function love.load()
        camera = Camera(player.pos.x, player.pos.y)
    end
    
    function love.update(dt)
        local dx,dy = player.x - cam.x, player.y - cam.y
        camera:move(dx/2, dy/2)
    end


Function Reference
------------------

.. function:: Camera.new(x,y, zoom, rot)

   :param numbers x,y:  Point for the camera to look at. (optional)
   :param number zoom:  Camera zoom. (optional)
   :param number rot:  Camera rotation in radians. (optional)
   :returns: A new camera.


Creates a new camera. You can access the camera position using ``camera.x,
camera.y``, the zoom using ``camera.scale`` and the rotation using ``camera.rot``.

The module variable name can be used at a shortcut to ``new()``.

**Example**::

    camera = require 'hump.camera'
    -- camera looking at (100,100) with zoom 2 and rotated by 45 degrees
    cam = camera(100,100, 2, math.pi/2)


.. function:: camera:move(dx,dy)

   :param numbers dx,dy:  Direction to move the camera.
   :returns: The camera.


Move the camera *by* some vector. To set the position, use
:func:`camera:lookAt`.

This function is shortcut to ``camera.x,camera.y = camera.x+dx, camera.y+dy``.

**Examples**::

    function love.update(dt)
        camera:move(dt * 5, dt * 6)
    end

::

    function love.update(dt)
        camera:move(dt * 5, dt * 6):rotate(dt)
    end


.. function:: camera:lookAt(x,y)

   :param numbers x,y:  Position to look at.
   :returns: The camera.


Let the camera look at a point. In other words, it sets the camera position. To
move the camera *by* some amount, use :func:`camera:move`.

This function is shortcut to ``camera.x,camera.y = x, y``.

**Examples**::

    function love.update(dt)
        camera:lookAt(player.pos:unpack())
    end

::

    function love.update(dt)
        camera:lookAt(player.pos:unpack()):rotate(player.rot)
    end

.. function:: camera:position()

   :returns: ``x,y`` -- Camera position.


Returns ``camera.x, camera.y``.

**Example**::

    -- let the camera fly!
    local cam_dx, cam_dy = 0, 0
    
    function love.mousereleased(x,y)
        local cx,cy = camera:position()
        dx, dy = x-cx, y-cy
    end
    
    function love.update(dt)
        camera:move(dx * dt, dy * dt)
    end


.. function:: camera:rotate(angle)

   :param number angle: Rotation angle in radians
   :returns: The camera.


Rotate the camera by some angle. To set the angle use :func:`camera:rotateTo`.

This function is shortcut to ``camera.rot = camera.rot + angle``.

**Examples**::

    function love.update(dt)
        camera:rotate(dt)
    end

::

    function love.update(dt)
        camera:rotate(dt):move(dt,dt)
    end


.. function:: camera:rotateTo(angle)

   :param number angle: Rotation angle in radians
   :returns: The camera.

Set rotation: ``camera.rot = angle``.

**Example**::

    camera:rotateTo(math.pi/2)


.. function:: camera:zoom(mul)

   :param number mul:  Zoom change. Should be > 0.
   :returns: The camera.


*Multiply* zoom: ``camera.scale = camera.scale * mul``.

**Examples**::

    camera:zoom(2)   -- make everything twice as big

::

    camera:zoom(0.5) -- ... and back to normal

::

    camera:zoom(-1)  -- mirror and flip everything upside down


.. function:: camera:zoomTo(zoom)

   :param number zoom:  New zoom.
   :returns: The camera.


Set zoom: ``camera.scale = zoom``.

**Example**::

    camera:zoomTo(1) -- reset zoom


.. function:: camera:attach()

Start looking through the camera.

Apply camera transformations, i.e. move, scale and rotate everything until
``camera:detach()`` as if looking through the camera.

**Example**::

    function love.draw()
        camera:attach()
        draw_world()
        camera:detach()

        draw_hud()
    end


.. function:: camera:detach()

Stop looking through the camera.

**Example**::

    function love.draw()
        camera:attach()
        draw_world()
        camera:detach()

        draw_hud()
    end


.. function:: camera:draw(func)

   :param function func:  Drawing function to be wrapped.

Wrap a function between a ``camera:attach()``/``camera:detach()`` pair.
Equivalent to::

    camera:attach()
    func()
    camera:detach()


**Example**::

    function love.draw()
        camera:draw(draw_world)
        draw_hud()
    end


.. function:: camera:worldCoords(x, y)

   :param numbers x, y:  Point to transform.
   :returns: ``x,y`` -- Transformed point.

Because a camera has a point it looks at, a rotation and a zoom factor, it
defines a coordinate system. A point now has two sets of coordinates: One
defines where the point is to be found in the game world, and the other
describes the position on the computer screen. The first set of coordinates is
called world coordinates, the second one camera coordinates. Sometimes it is
needed to convert between the two coordinate systems, for example to get the
position of a mouse click in the game world in a strategy game, or to see if an
object is visible on the screen.

:func:`camera:worldCoords` and :func:`camera:cameraCoords` transform points
between these two coordinate systems.

**Example**::

    x,y = camera:worldCoords(love.mouse.getPosition())
    selectedUnit:plotPath(x,y)


.. function:: camera:cameraCoords(x, y)

   :param numbers x, y:  Point to transform.
   :returns: ``x,y`` -- Transformed point.


Because a camera has a point it looks at, a rotation and a zoom factor, it
defines a coordinate system. A point now has two sets of coordinates: One
defines where the point is to be found in the game world, and the other
describes the position on the computer screen. The first set of coordinates is
called world coordinates, the second one camera coordinates. Sometimes it is
needed to convert between the two coordinate systems, for example to get the
position of a mouse click in the game world in a strategy game, or to see if an
object is visible on the screen.

:func:`camera:worldCoords` and :func:`camera:cameraCoords` transform points
between these two coordinate systems.

**Example**::

    x,y = camera:cameraCoords(player.pos.x, player.pos.y)
    love.graphics.line(x, y, love.mouse.getPosition())


.. function:: camera:mousePosition()

   :returns: Mouse position in world coordinates.


Shortcut to ``camera:worldCoords(love.mouse.getPosition())``.

**Example**::

    x,y = camera:mousePosition()
    selectedUnit:plotPath(x,y)


Camera Movement Control
-----------------------

Camera movement is one of these things that go almost unnoticed when done well,
but add a lot to the overall experience.
The article `Scroll Back: The Theory and Practice of Cameras in SideScrollers
<http://gamasutra.com/blogs/ItayKeren/20150511/243083/Scroll_Back_The_Theory_and_Practice_of_Cameras_in_SideScrollers.php>`_
by Itay Keren gives a lot of insight into how to design good camera systems.

**hump.camera** offers functions that help to implement most of the techniques
discussed in the article. The functions :func:`camera:lockX`,
:func:`camera:lockY`, :func:`camera:lockPosition`, and :func:`camera:lockWindow`
move the camera so that the interesting content stays in frame.
Note that the functions must be called every frame::

    function love.update()
       -- vertical locking
       camera:lockX(player.pos.x)
    end


All movements are subject to smoothing (see :ref:`Movement Smoothers
<movement-smoothers>`).
You can specify a default movement smoother by assigning the variable
:attr:`camera.smoother`::

    cam.smoother = Camera.smooth.linear(100)



.. function:: camera:lockX(x, smoother, ...)

   :param number x: X coordinate (in world coordinates) to lock to.
   :param function smoother: Movement smoothing override. (optional)
   :param mixed ...: Additional parameters to the smoothing function. (optional)

Horizontal camera locking: Keep the camera locked on the defined ``x``-position
(in *world coordinates*). The ``y``-position is not affected.

You can define an off-center locking position by "aiming" the camera left or
right of your actual target. For example, to center the player 20 pixels to the
*left* of the screen, aim 20 pixels to it's *right* (see examples).

**Examples**::

    -- lock on player vertically
    camera:lockX(player.x)

::

    -- ... with linear smoothing at 25 px/s
    camera:lockX(player.x, Camera.smooth.linear(25))

::

    -- lock player 20px left of center
    camera:lockX(player.x + 20)



.. function:: camera:lockY(y, smoother, ...)

   :param number y: Y coordinate (in world coordinates) to lock to.
   :param function smoother: Movement smoothing override. (optional)
   :param mixed ...: Additional parameters to the smoothing function. (optional)

Vertical camera locking: Keep the camera locked on the defined ``y``-position
(in *world coordinates*). The ``x``-position is not affected.

You can define an off-center locking position by "aiming" the camera above or
below your actual target. For example, to center the player 20 pixels *below* the
screen center, aim 20 pixels *above* it (see examples).

**Examples**::

    -- lock on player horizontally
    camera:lockY(player.y)

::

    -- ... with damped smoothing with a stiffness of 10
    camera:lockY(player.y, Camera.smooth.damped(10))

::

    -- lock player 20px below the screen center
    camera:lockY(player.y - 20)



.. function:: camera:lockPosition(x,y, smoother, ...)

   :param numbers x,y: Position (in world coordinates) to lock to.
   :param function smoother: Movement smoothing override. (optional)
   :param mixed ...: Additional parameters to the smoothing function. (optional)

Horizontal and vertical camera locking: Keep the camera locked on the defined
position (in *world coordinates*).

You can define an off-center locking position by "aiming" the camera to the
opposite direction away from your real target.
For example, to center the player 10 pixels to the *left* and 20 pixels *above*
the screen center, aim 10 pixels to the *right* and 20 pixels *below*.

**Examples**::

    -- lock on player
    camera:lockPosition(player.x, player.y)

::

    -- lock 50 pixels into player's aiming direction
    camera:lockPosition(player.x - player.aiming.x * 50, player.y - player.aiming.y * 50)



.. function:: camera:lockWindow(x,y, x_min, x_max, y_min, y_max, smoother, ...)

   :param numbers x,y: Position (in world coordinates) to lock to.
   :param numbers x_min: Upper left X coordinate of the camera window *(in camera coordinates!)*.
   :param numbers x_max: Lower right X coordinate of the camera window *(in camera coordinates!)*.
   :param numbers y_min: Upper left Y coordinate of the camera window *(in camera coordinates!)*.
   :param numbers y_max: Lower right Y coordinate of the camera window *(in camera coordinates!)*.
   :param function smoother: Movement smoothing override. (optional)
   :param mixed ...: Additional parameters to the smoothing function. (optional)

The most powerful locking method: Lock camera to ``x,y``, but only move the
camera if the position would be out of the screen-rectangle defined by ``x_min``,
``x_max``, ``y_min``, ``y_max``.

.. note::
   The locking window is defined in camera coordinates, whereas the position to
   lock to is defined in world coordinates!

All of the other locking methods can be implemented by window locking. For
position locking, set ``x_min = x_max`` and ``y_min = y_max``.
Off-center locking can be done by defining the locking window accordingly.

**Examples**::

    -- lock on player
    camera:lock(player.x, player.y)

.. attribute:: camera.smoother

The default smoothing operator. Must be a ``function`` with the following
prototype::

    function customSmoother(dx,dy, ...)
        do_stuff()
        return new_dx,new_dy
    end

where ``dx,dy`` is the offset the camera would move before smoothing and
``new_dx, new_dy`` is the offset the camera should move after smoothing.


.. _movement-smoothers:

Movement Smoothers
^^^^^^^^^^^^^^^^^^

It is not always desirable that the camera instantly locks on a target.
`Platform snapping
<http://gamasutra.com/blogs/ItayKeren/20150511/243083/Scroll_Back_The_Theory_and_Practice_of_Cameras_in_SideScrollers.php#h.rncuomopycy0>`_,
for example, would look terrible if the camera would instantly jump to the
focussed platform.
Smoothly moving the camera to the locked position can also give the illusion of
a camera operator an add to the overall feel of your game.

**hump.camera** allows to smooth the movement by either passing movement
smoother functions to the locking functions or by setting a default smoother
(see :attr:`camera.smoother`).

Smoothing functions must have the following prototype::

    function customSmoother(dx,dy, ...)
        do_stuff()
        return new_dx,new_dy
    end

where ``dx,dy`` is the offset the camera would move before smoothing and
``new_dx, new_dy`` is the offset the camera should move after smoothing.

This is a simple "rubber-band" smoother::

    function rubber_band(dx,dy)
        local dt = love.timer.getDelta()
        return dx*dt, dy*dt
    end

**hump.camera** defines generators for the most common smoothers:

.. function:: Camera.smooth.none()

   :returns: Smoothing function.

Dummy smoother: does not smooth the motion.

**Example**::

    cam.smoother = Camera.smooth.none()


.. function:: Camera.smooth.linear(speed)

   :param number speed: Smoothing speed.
   :returns: Smoothing function.

Smoothly moves the camera towards to snapping goal with constant speed.

**Examples**::

   cam.smoother = Camera.smooth.linear(100)

::

    -- warning: creates a function every frame!
    camera:lockX(player.x, Camera.smooth.linear(25))


.. function:: Camera.smooth.damped(stiffness)

   :param number stiffness: Speed of the camera movement.
   :returns: Smoothing function.

Smoothly moves the camera towards the goal with a speed proportional to the
distance to the target.
Stiffness defines the speed of the motion: Higher values mean that the camera
moves more quickly.

**Examples**::

   cam.smoother = Camera.smooth.damped(10)

::

    -- warning: creates a function every frame!
    camera:lockPosition(player.x, player.y, Camera.smooth.damped(2))
