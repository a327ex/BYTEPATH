# binser - Customizable Lua Serializer

[![Build Status](https://travis-ci.org/bakpakin/binser.svg?branch=master)](https://travis-ci.org/bakpakin/binser)

There already exists a number of serializers for Lua, each with their own uses,
limitations, and quirks. binser is yet another robust, pure Lua serializer that
specializes in serializing Lua data with lots of userdata and custom classes
and types. binser is a binary serializer and does not serialize data into
human readable representation or use the Lua parser to read expressions. This
makes it safe and moderately fast, especially on LuaJIT. binser also handles
cycles, self-references, and metatables.

## How to Use

### Example
```lua
local binser = require "binser"

local mydata = binser.serialize(45, {4, 8, 12, 16}, "Hello, World!")

print(binser.deserializeN(mydata, 3))
-- 45	table: 0x7fa60054bdb0	Hello, World!
```

### Serializing and Deserializing
```lua
local str = binser.serialize(...)
```
Serialize (almost) any Lua data into a Lua string. Numbers, strings, tables,
booleans, and nil are all fully supported by default. Custom userdata and custom
types, both identified by metatables, can also be supported by specifying a
custom serialization function. Unserializable data should throw an error. Aliased to `binser.s`.

```lua
local results, len = binser.deserialize(str[, index])
```
Deserialize any string previously serialized by binser. Can optionally start at 
an index in the string (to drop leading characters). Index is 1 by default. Unrecognized data should
throw an error. Results is a list of length len. Aliased to `binser.d`.

```lua
local ... = binser.deserializeN(str, n[, index])
```
Deserializes at most n values from str. The default value for n is one,
so `binser.deserializeN(str)` will deserialize exactly one value from string, and
ignore the rest of the string. Can optionally start at a given index, which
is 1 by default. Aliased to `binser.dn`.

### Custom types
```lua
local metatable = binser.register(metatable, name, serialize, deserialize)
```
Registers a custom type, identified by its metatable, to be serialized.
Registering types has two main purposes. First, it allows custom serialization
and deserialization for userdata and tables that contain userdata, which can't
otherwise be serialized in a uniform way. Second, it allows efficient
serialization of small tables with large metatables, as registered metatables
are not serialized.

The `metatable` parameter is the metatable the identifies the type. The `name`
parameter is the type name used in serialization. The only requirement for names
is that they are unique. The `serialize` and `deserialize` parameters are
a pair of functions that construct and destruct and instance of the type.
`serialize` can return any number of serializable Lua objects, and
`deserialize` should accept the arguments returned by `serialize`.
`serialize` and `deserialize` can also be specified in `metatable._serialize`
and `metatable._deserialize` respectively.

If `serialize` and `deserialize` are omitted, then default table serializers are
used, which work very well for most tables. If your type describes userdata,
however, `serialize` and `deserialize` must be provided.

```lua
local class = binser.registerClass(class[, name])
```
Registers a class as a custom type. binser currently supports 30log and
middleclass. `name` is an optional parameter that defaults to `class.name`.

```lua
local metatable = binser.unregister(name)
```
Users should seldom need this, but to explicitly unregister a type, call this.

#### Templates

If binser's already compact serialization isn't enough, and you don't want to write
complex and error prone custom serializers, binser has a functionality called templating.
Templates specify the layout of a custom type, so that table keys don't need to be serialized
many times. To specify a template, add the `_template` key to the metatable of your type.

An example:
```lua
local template = {
	"name", "age", "salary", "email",
	nested = {"more", "nested", "keys"}
}

local Employee_MT = {
	name = "Employee",
}

local joe = setmetatable({
	name = "Joe",
	age = 11,
	salary = "$1,000,000",
	email = "joe@example.com",
	nested = {
		more = "blah",
		nested = "FUBAR",
		keys = "lost"
	}
}, Employee_MT)

-- Print length of serialized employee without templating
-- 117
binser.registerClass(Employee_MT)
print(#binser.s(joe))
binser.unregister(Employee_MT)

-- Print length of serialized employee with templating
-- 72
Employee_MT._template = template
binser.registerClass(Employee_MT)
print(#binser.s(joe))
```

In the above example, the resulting serialized value with templating is nearly half of the size of the default
table serialization.

### Resources

If there are certain objects that don't need to be serialized at all, like
images, audio, or any system resource, binser can mark them as such to only
serialize a reference to them. Resources must be registered in a similar way to
custom types and given a unique name.
```lua
local resource = binser.registerResource(resource, name)
```
Registers a resource.

```lua
local resource = binser.unregisterResource(name)
```
Resources can be unregistered in a similar manner as custom types.

### File IO
Mostly for convenience, binser has functions for writing and reading to files.
These work through Lua's built in IO.

```lua
binser.writeFile(filepath, ...)
```
Serializes Lua objects and writes them to a file. Overwrites the previous file.

```lua
binser.appendFile(filepath, ...)
```
Same as writing to a file, but doesn't overwrite the old file.

```lua
local results, len = binser.readFile(filepath)
```
Reads and deserializes a file.

The trio of file convenience function have shortened aliases as well.

| Function          | Alias    |
|-------------------|----------|
|`binser.writeFile` |`binser.w`|
|`binser.appendFile`|`binser.a`|
|`binser.readFile`  |`binser.r`|

## Why
Most Lua serializers serialize into valid Lua code, which while very useful,
makes it impossible to do things like custom serialization and
deserialization. binser was originally written as a way to save game levels
with images and other native resources, but is extremely general.

## LuaRocks
binser is available as a rock on [LuaRocks](https://luarocks.org/). Install via:
```
luarocks install binser
```

## Testing
binser uses [busted](http://olivinelabs.com/busted/) for testing. Install and
run `busted` from the command line to test.

## Notes
* Serialized strings can contain unprintable and null characters.
* Serialized data can be appended to other serialized data. (Cool :))
* The functions `binser.serialize`, `binser.deserialize`, and `binser.deserializeN` can be shortened to
`binser.s`, `binser.d`, and `binser.dn` as handy shortcuts.

## Bugs
Pull requests are welcome, please help me squash bugs!
