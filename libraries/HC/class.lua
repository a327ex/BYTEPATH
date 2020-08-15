--[[
Copyright (c) 2010-2011 Matthias Richter

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

Except as contained in this notice, the name(s) of the above copyright holders
shall not be used in advertising or otherwise to promote the sale, use or
other dealings in this Software without prior written authorization.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]--

local function __NULL__() end

-- class "inheritance" by copying functions
local function inherit(class, interface, ...)
	if not interface then return end
	assert(type(interface) == "table", "Can only inherit from other classes.")

	-- __index and construct are not overwritten as for them class[name] is defined
	for name, func in pairs(interface) do
		if not class[name] then
			class[name] = func
		end
	end
	for super in pairs(interface.__is_a or {}) do
		class.__is_a[super] = true
	end

	return inherit(class, ...)
end

-- class builder
local function new(args)
	local super = {}
	local name = '<unnamed class>'
	local constructor = args or __NULL__
	if type(args) == "table" then
		-- nasty hack to check if args.inherits is a table of classes or a class or nil
		super = (args.inherits or {}).__is_a and {args.inherits} or args.inherits or {}
		name = args.name or name
		constructor = args[1] or __NULL__
	end
	assert(type(constructor) == "function", 'constructor has to be nil or a function')

	-- build class
	local class = {}
	class.__index = class
	class.__tostring = function() return ("<instance of %s>"):format(tostring(class)) end
	class.construct = constructor or __NULL__
	class.inherit = inherit
	class.__is_a = {[class] = true}
	class.is_a = function(self, other) return not not self.__is_a[other] end

	-- inherit superclasses (see above)
	inherit(class, unpack(super))

	-- syntactic sugar
	local meta = {
		__call = function(self, ...)
			local obj = {}
			setmetatable(obj, self)
			self.construct(obj, ...)
			return obj
		end,
		__tostring = function() return name end
	}
	return setmetatable(class, meta)
end

-- interface for cross class-system compatibility (see https://github.com/bartbes/Class-Commons).
if common_class ~= false and not common then
	common = {}
	function common.class(name, prototype, parent)
		local init = prototype.init or (parent or {}).init
		return new{name = name, inherits = {prototype, parent}, init}
	end
	function common.instance(class, ...)
		return class(...)
	end
end

-- the module
return setmetatable({new = new, inherit = inherit},
	{__call = function(_,...) return new(...) end})
