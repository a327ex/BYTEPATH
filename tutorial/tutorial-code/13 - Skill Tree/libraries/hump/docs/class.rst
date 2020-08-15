hump.class
==========

::

    Class = require "hump.class"

A small, fast class/prototype implementation with multiple inheritance.

Implements `class commons <https://github.com/bartbes/Class-Commons>`_.

**Example**::

    Critter = Class{
        init = function(self, pos, img)
            self.pos = pos
            self.img = img
        end,
        speed = 5
    }
    
    function Critter:update(dt, player)
        -- see hump.vector
        local dir = (player.pos - self.pos):normalize_inplace()
        self.pos = self.pos + dir * Critter.speed * dt
    end
    
    function Critter:draw()
        love.graphics.draw(self.img, self.pos.x, self.pos.y)
    end

Function Reference
------------------

.. function:: Class.new()
.. function:: Class.new({init = constructor, __includes = parents, ...})

   :param function constructor:  Class constructor. Can be accessed with ``theclass.init(object, ...)``. (optional)
   :param class or table of classes parents: Classes to inherit from. Can either be a single class or a table of classes. (optional)
   :param mixed ...:  Any other fields or methods common to all instances of this class. (optional)
   :returns: The class.


Declare a new class.

``init()`` will receive the new object instance as first argument. Any other
arguments will also be forwarded (see examples), i.e. ``init()`` has the
following signature::

    function init(self, ...)

If you do not specify a constructor, an empty constructor will be used instead.

The name of the variable that holds the module can be used as a shortcut to
``new()`` (see example).

**Examples**::

    Class = require 'hump.class' -- `Class' is now a shortcut to new()
    
    -- define a class class
    Feline = Class{
        init = function(self, size, weight)
            self.size = size
            self.weight = weight
        end;
        -- define a method
        stats = function(self)
            return string.format("size: %.02f, weight: %.02f", self.size, self.weight)
        end;
    }
    
    -- create two objects
    garfield = Feline(.7, 45)
    felix = Feline(.8, 12)
    
    print("Garfield: " .. garfield:stats(), "Felix: " .. felix:stats())

::

    Class = require 'hump.class'
    
    -- same as above, but with 'external' function definitions
    Feline = Class{}
    
    function Feline:init(size, weight)
        self.size = size
        self.weight = weight
    end
    
    function Feline:stats()
        return string.format("size: %.02f, weight: %.02f", self.size, self.weight)
    end
    
    garfield = Feline(.7, 45)
    print(Feline, garfield)

::

    Class = require 'hump.class'
    A = Class{
        foo = function() print('foo') end
    }
    
    B = Class{
        bar = function() print('bar') end
    }
    
    -- single inheritance
    C = Class{__includes = A}
    instance = C()
    instance:foo() -- prints 'foo'
    instance:bar() -- error: function not defined
    
    -- multiple inheritance
    D = Class{__includes = {A,B}}
    instance = D()
    instance:foo() -- prints 'foo'
    instance:bar() -- prints 'bar'

::

    -- class attributes are shared across instances
    A = Class{ foo = 'foo' } -- foo is a class attribute/static member
    
    one, two, three = A(), A(), A()
    print(one.foo, two.foo, three.foo) --> prints 'foo    foo    foo'
    
    one.foo = 'bar' -- overwrite/specify for instance `one' only
    print(one.foo, two.foo, three.foo) --> prints 'bar    foo    foo'
    
    A.foo = 'baz' -- overwrite for all instances without specification
    print(one.foo, two.foo, three.foo) --> prints 'bar    baz    baz'


.. function:: class.init(object, ...)

   :param Object object: The object. Usually ``self``.
   :param mixed ...: Arguments to pass to the constructor.
   :returns: Whatever the parent class constructor returns.


Calls class constructor of a class on an object.

Derived classes should use this function their constructors to initialize the
parent class(es) portions of the object.

**Example**::

    Class = require 'hump.class'
    
    Shape = Class{
        init = function(self, area)
            self.area = area
        end;
        __tostring = function(self)
            return "area = " .. self.area
        end
    }
    
    Rectangle = Class{__includes = Shape,
        init = function(self, width, height)
            Shape.init(self, width * height)
            self.width  = width
            self.height = height
        end;
        __tostring = function(self)
            local strs = {
                "width = " .. self.width,
                "height = " .. self.height,
                Shape.__tostring(self)
            }
            return table.concat(strs, ", ")
        end
    }
    
    print( Rectangle(2,4) ) -- prints 'width = 2, height = 4, area = 8'


.. function:: Class:include(other)

   :param tables other: Parent classes/mixins.
   :returns: The class.


Inherit functions and variables of another class, but only if they are not
already defined. This is done by (deeply) copying the functions and variables
over to the subclass.

.. note::
    ``class:include()`` doesn't actually care if the arguments supplied are
    hump classes. Just any table will work.

.. note::
    You can use ``Class.include(a, b)`` to copy any fields from table ``a``
    to table ``b`` (see second example).

**Examples**::

    Class = require 'hump.class'
    
    Entity = Class{
        init = function(self)
            GameObjects.register(self)
        end
    }
    
    Collidable = {
        dispatch_collision = function(self, other, dx, dy)
            if self.collision_handler[other.type])
                return collision_handler[other.type](self, other, dx, dy)
            end
            return collision_handler["*"](self, other, dx, dy)
        end,
    
        collision_handler = {["*"] = function() end},
    }
    
    Spaceship = Class{
        init = function(self)
            self.type = "Spaceship"
            -- ...
        end
    }
    
    -- make Spaceship collidable
    Spaceship:include(Collidable)
    
    Spaceship.collision_handler["Spaceship"] = function(self, other, dx, dy)
        -- ...
    end

::

    -- using Class.include()
    Class = require 'hump.class'
    a = {
        foo = 'bar',
        bar = {one = 1, two = 2, three = 3},
        baz = function() print('baz') end,
    }
    b = {
        foo = 'nothing to see here...'
    }
    
    Class.include(b, a) -- copy values from a to b
                        -- note that neither a nor b are hump classes!

    print(a.foo, b.foo) -- prints 'bar    nothing to see here...'
    
    b.baz() -- prints 'baz'
    
    b.bar.one = 10 -- changes only values in b
    print(a.bar.one, b.bar.one) -- prints '1    10'


.. function:: class:clone()

   :returns: A deep copy of the class/table.


Create a clone/deep copy of the class.

.. note::
    You can use ``Class.clone(a)`` to create a deep copy of any table (see
    second example).

**Examples**::

    Class = require 'hump.class'
    
    point = Class{ x = 0, y = 0 }
    
    a = point:clone()
    a.x, a.y = 10, 10
    print(a.x, a.y) --> prints '10    10'
    
    b = point:clone()
    print(b.x, b.y) --> prints '0    0'
    
    c = a:clone()
    print(c.x, c.y) --> prints '10    10'

::

    -- using Class.clone() to copy tables
    Class = require 'hump.class'
    a = {
        foo = 'bar',
        bar = {one = 1, two = 2, three = 3},
        baz = function() print('baz') end,
    }
    b = Class.clone(a)
    
    b.baz() -- prints 'baz'
    b.bar.one = 10
    print(a.bar.one, b.bar.one) -- prints '1    10'



Caveats
-------

Be careful when using metamethods like ``__add`` or ``__mul``: If a subclass
inherits those methods from a superclass, but does not overwrite them, the
result of the operation may be of the type superclass. Consider the following::

    Class = require 'hump.class'

    A = Class{init = function(self, x) self.x = x end}
    function A:__add(other) return A(self.x + other.x) end
    function A:show() print("A:", self.x) end
    
    B = Class{init = function(self, x, y) A.init(self, x) self.y = y end}
    function B:show() print("B:", self.x, self.y) end
    function B:foo() print("foo") end
    B:include(A)
    
    one, two = B(1,2), B(3,4)
    result = one + two -- result will be of type A, *not* B!
    result:show()      -- prints "A:    4"
    result:foo()       -- error: method does not exist

Note that while you can define the ``__index`` metamethod of the class, this is
not a good idea: It will break the class mechanism. To add a custom ``__index``
metamethod without breaking the class system, you have to use ``rawget()``. But
beware that this won't affect subclasses::

    Class = require 'hump.class'
    
    A = Class{}
    function A:foo() print('bar') end
    
    function A:__index(key)
        print(key)
        return rawget(A, key)
    end
    
    instance = A()
    instance:foo() -- prints foo  bar
    
    B = Class{__includes = A}
    instance = B()
    instance:foo() -- prints only foo

