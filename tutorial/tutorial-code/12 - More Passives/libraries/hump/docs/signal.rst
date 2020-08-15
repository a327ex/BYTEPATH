hump.signal
===========

::

    Signal = require 'hump.signal'

A simple yet effective implementation of `Signals and Slots
<http://en.wikipedia.org/wiki/Signals_and_slots>`_, aka the `Observer pattern
<http://en.wikipedia.org/wiki/Observer_pattern>`_: Functions can be dynamically
bound to signals. When a *signal* is *emitted*, all registered functions will
be invoked. Simple as that.

``hump.signal`` makes things a little more interesing by allowing to emit all
signals that match a `Lua string pattern
<http://www.lua.org/manual/5.1/manual.html#5.4.1>`_.

**Example**::

    -- in AI.lua
    Signal.register('shoot', function(x,y, dx,dy)
        -- for every critter in the path of the bullet:
        -- try to avoid being hit
        for critter in pairs(critters) do
            if critter:intersectsRay(x,y, dx,dy) then
                critter:setMoveDirection(-dy, dx)
            end
        end
    end)
    
    -- in sounds.lua
    Signal.register('shoot', function()
        Sounds.fire_bullet:play()
    end)
    
    -- in main.lua
    function love.keypressed(key)
        if key == ' ' then
            local x,y   = player.pos:unpack()
            local dx,dy = player.direction:unpack()
            Signal.emit('shoot', x,y, dx,dy)
        end
    end

Function Reference
------------------

.. function:: Signal.new()

   :returns: A new signal registry.

Creates a new signal registry that is independent of the default registry: It
will manage it's own list of signals and does not in any way affect the the
global registry. Likewise, the global registry does not affect the instance.

.. note::
    If you don't need multiple independent registries, you can use the
    global/default registry (see examples).

.. note::
    Unlike the default one, signal registry instances use the colon-syntax,
    i.e., you need to call ``instance:emit('foo', 23)`` instead of
    ``Signal.mit('foo', 23)``.

**Example**::

    player.signals = Signal.new()


.. function:: Signal.register(s, f)

   :param string s:  The signal identifier.
   :param function f:  The function to register.
   :returns: A function handle to use in :func:`Signal.remove()`.


Registers a function ``f`` to be called when signal ``s`` is emitted.

**Examples**::

    Signal.register('level-complete', function() self.fanfare:play() end)

::

    handle = Signal.register('level-load', function(level) level.show_help() end)

::

    menu:register('key-left', select_previous_item)


.. function:: Signal.emit(s, ...)

   :param string s: The signal identifier.
   :param mixed ...: Arguments to pass to the bound functions. (optional)


Calls all functions bound to signal ``s`` with the supplied arguments.


**Examples**::

    function love.keypressed(key)
        -- using a signal instance
        if key == 'left' then menu:emit('key-left') end
    end

::

    if level.is_finished() then
        -- adding arguments
        Signal.emit('level-load', level.next_level)
    end


.. function:: Signal.remove(s, ...)

   :param string s:  The signal identifier.
   :param functions ...:  Functions to unbind from the signal.


Unbinds (removes) functions from signal ``s``.

**Example**::

    Signal.remove('level-load', handle)


.. function:: Signal.clear(s)

   :param string s: The signal identifier.


Removes all functions from signal ``s``.

**Example**::

    Signal.clear('key-left')


.. function:: Signal.emitPattern(p, ...)

   :param string p: The signal identifier pattern.
   :param mixed ...:  Arguments to pass to the bound functions. (optional)


Emits all signals that match a `Lua string pattern
<http://www.lua.org/manual/5.1/manual.html#5.4.1>`_.

**Example**::

    -- emit all update signals
    Signal.emitPattern('^update%-.*', dt)


.. function:: Signal.removePattern(p, ...)

   :param string p:  The signal identifier pattern.
   :param functions ...:  Functions to unbind from the signals.


Removes functions from all signals that match a `Lua string pattern
<http://www.lua.org/manual/5.1/manual.html#5.4.1>`_.

**Example**::

    Signal.removePattern('key%-.*', play_click_sound)


.. function:: Signal.clearPattern(p)

   :param string p: The signal identifier pattern.


Removes **all** functions from all signals that match a `Lua string pattern
<http://www.lua.org/manual/5.1/manual.html#5.4.1>`_.

**Examples**::

    Signal.clearPattern('sound%-.*')

::

    player.signals:clearPattern('.*') -- clear all signals

