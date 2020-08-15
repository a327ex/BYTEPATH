# bitser

[![Build Status](https://travis-ci.org/gvx/bitser.svg?branch=master)](https://travis-ci.org/gvx/bitser)
[![Coverage Status](https://coveralls.io/repos/github/gvx/bitser/badge.svg?branch=master)](https://coveralls.io/github/gvx/bitser?branch=master)

Serializes and deserializes Lua values with LuaJIT.

```lua
local bitser = require 'bitser'

bitser.register('someResource', someResource)
bitser.registerClass(SomeClass)

serializedString = bitser.dumps(someValue)
someValue = bitser.loads(serializedString)
```

Documentation can be found in [USAGE.md](USAGE.md).

Pull requests, bug reports and other feedback welcome! :heart:

Bitser is released under the ISC license (functionally equivalent to the BSD
2-Clause and MIT licenses).

Please note that bitser requires LuaJIT for its `ffi` library and JIT compilation. Without JIT, it may or may not run, but it will be much slower than usual. This primarily affects Android and iOS, because JIT is disabled on those platforms.

## Why would I use this?

Because it's fast. Because it produces tiny output. Because the name means "snappier"
or "unfriendlier" in Dutch. Because it's safe to use with untrusted data.

Because it's inspired by [binser](https://github.com/bakpakin/binser), which is great.

## How do I use the benchmark thingy?

Download zero or more of [binser.lua](https://raw.githubusercontent.com/bakpakin/binser/master/binser.lua),
[ser.lua](https://raw.githubusercontent.com/gvx/Ser/master/ser.lua),
[smallfolk.lua](https://raw.githubusercontent.com/gvx/Smallfolk/master/smallfolk.lua),
[serpent.lua](https://raw.githubusercontent.com/pkulchenko/serpent/master/src/serpent.lua) and
[MessagePack.lua](https://raw.githubusercontent.com/fperrad/lua-MessagePack/master/src/MessagePack.lua), and run:

    love .

You do need [LÖVE](https://love2d.org/) for that.

You can add more cases in the folder `cases/` (check out `_new.lua`), and add other
serializers to the benchmark in `main.lua`. If you do either of those things, please
send me a pull request!

## You can register classes?

Yes. At the moment, bitser supports MiddleClass, SECL, hump.class, Slither and Moonscript classes (and
probably some other class libraries by accident).
