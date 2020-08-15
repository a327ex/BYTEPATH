package = "binser"
version = "scm-0"
source = {
   url = "git://github.com/bakpakin/binser"
}
description = {
   summary = "Customizable Lua Serializer",
   detailed = [[
Fast Lua serialization for Lua 5.1, Lua 5.2, and LuaJIT that supports
cycles, metatables, and custom types.
]],
   homepage = "https://github.com/bakpakin/binser",
   license = "MIT"
}
dependencies = {
   "lua >= 5.1"
}
build = {
   type = "builtin",
   modules = {
      binser = "binser.lua"
   }
}
