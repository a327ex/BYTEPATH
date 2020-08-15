package = "moses"
version = "1.3-0"
source = {
   url = "https://github.com/Yonaba/Moses/archive/Moses-1.3.0.tar.gz",
   dir = "Moses-Moses-1.3.0"
}
description = {
   summary = "Utility library for functional programming in Lua",
   detailed = [[
      A utility library provinding handy resources for common programming tasks and support for functional 
	  programming. It complements the built-in Lua table library, making easier operations on arrays, lists, 
	  collections and objects, through 85 weird, bizarre and odd functions.
   ]],
   homepage = "http://yonaba.github.com/Moses/",
   maintainer = "Roland Yonaba <roland.yonaba@gmail.com>",
   license = "MIT <http://www.opensource.org/licenses/mit-license.php>"
}
dependencies = {
   "lua >= 5.1"
}
build = {
  type = "builtin",
  modules = {
    ["moses"] = "moses.lua"
  }
}