> Since 2016-02-16, Ser is **deprecated**. I will still fix reported bugs, but for new projects, I recommend [bitser](https://github.com/gvx/bitser) if you're using LuaJIT, and [binser](https://github.com/bakpakin/binser)
otherwise.

Ser
===

Ser is a fast, robust, richly-featured table serialization library for Lua. It
was specifically written to store configuration and save files for
[LÖVE](http://love2d.org/) games, but can be used anywhere.

Originally, this was the code to write save games for
[Space](https://github.com/gvx/space), but was released as a stand-alone
library after many much-needed improvements.

Like Space itself, you use, distribute and extend Ser under the terms of the
MIT license.

Simple
------

Ser is very simple and easy to use:

```lua
local serialize = require 'ser'

print(serialize({"Hello", world = true}))
-- prints:
-- return {"Hello", world = true}
```

Fast
----

Using Serpent's benchmark code, Ser is 33% faster than Serpent.

Robust
------

Sometimes you have strange, non-euclidean geometries in your table
constructions. It happens, I don't judge. Ser can deal with that, where some
other serialization libraries cry "Iä! Iä! Cthulhu fhtagn!" and give up &mdash;
or worse, silently produce incorrect data.

```lua
local serialize = require 'ser'

local cthulhu = {{}, {}, {}}
cthulhu.fhtagn = cthulhu
cthulhu[1][cthulhu[2]] = cthulhu[3]
cthulhu[2][cthulhu[1]] = cthulhu[2]
cthulhu[3][cthulhu[3]] = cthulhu
print(serialize(cthulhu))
-- prints:
-- local _3 = {}
-- local _2 = {}
-- local _1 = {[_2] = _3}
-- local _0 = {_1, _2, _3}
-- _0.fhtagn = _0
-- _2[_1] = _2
-- _3[_3] = _0
-- return _0
```

Tested
------

Check out `tests.lua` to see how Ser behaves with all kinds of inputs.

Other solutions
---------------

Check out the [Lua-users wiki](http://lua-users.org/wiki/TableSerialization)
for other libraries that do roughly the same thing.

See also
--------

* [Lady](https://github.com/gvx/Lady): for trusted-source savegames
* [Smallfolk](https://github.com/gvx/Smallfolk): for untrusted-source serialization
