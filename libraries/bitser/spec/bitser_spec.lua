local ffi = require 'ffi'

_G.love = {filesystem = {newFileData = function()
	return {getPointer = function()
		local buf = ffi.new("uint8_t[?]", #love.s)
		ffi.copy(buf, love.s, #love.s)
		return buf
	end, getSize = function()
		return #love.s
	end}
end, write = function(_, s)
	love.s = s
end}}

local bitser = require 'bitser'

local function serdeser(value)
	return bitser.loads(bitser.dumps(value))
end

local function test_serdeser(value)
	assert.are.same(serdeser(value), value)
end

describe("bitser", function()
	it("serializes simple values", function()
		test_serdeser(true)
		test_serdeser(false)
		test_serdeser(nil)
		test_serdeser(1)
		test_serdeser(-1)
		test_serdeser(0)
		test_serdeser(100000000)
		test_serdeser(1.234)
		test_serdeser(10 ^ 20)
		test_serdeser(1/0)
		test_serdeser(-1/0)
		test_serdeser("")
		test_serdeser("hullo")
		test_serdeser([[this
			is a longer string
			such a long string
			that it won't fit
			in the "short string" representation
			no it won't
			listen to me
			it won't]])
		local nan = serdeser(0/0)
		assert.is_not.equal(nan, nan)
	end)
	it("serializes simple tables", function()
		test_serdeser({})
		test_serdeser({10, 11, 12})
		test_serdeser({foo = 10, bar = 99, [true] = false})
		test_serdeser({[1000] = 9000})
		test_serdeser({{}})
	end)
	it("serializes tables with tables as keys", function()
		local thekey = {"Heyo"}
		assert.are.same(thekey, (next(serdeser({[thekey] = 12}))))
	end)
	it("serializes cyclic tables", function()
		local cthulhu = {{}, {}, {}}
		cthulhu.fhtagn = cthulhu
		--note: this does not test tables as keys because assert.are.same doesn't like that
		cthulhu[1].cthulhu = cthulhu[3]
		cthulhu[2].cthulhu = cthulhu[2]
		cthulhu[3].cthulhu = cthulhu

		test_serdeser(cthulhu)
	end)
	it("serializes resources", function()
		local temp_resource = {}
		bitser.register("temp_resource", temp_resource)
		assert.are.equal(serdeser({this = temp_resource}).this, temp_resource)
		bitser.unregister("temp_resource")
	end)
	it("serializes many resources", function()
		local max = 1000
		local t = {}
		for i = 1, max do
			bitser.register(tostring(i), i)
			t[i] = i
		end
		test_serdeser(t)
		for i = 1, max do
			bitser.unregister(tostring(i))
		end
	end)
	it("serializes deeply nested tables", function()
		local max = 1000
		local t = {}
		for _ = 1, max do
			t.t = {}
			t = t.t
		end
		test_serdeser(t)
	end)
	it("serializes MiddleClass instances", function()
		local class = require("middleclass")
		local Horse = bitser.registerClass(class('Horse'))
		function Horse:initialize(name)
			self.name = name
			self[1] = 'instance can be sequence'
		end
		local bojack = Horse('Bojack Horseman')
		test_serdeser(bojack)
		assert.is_true(serdeser(bojack):isInstanceOf(Horse))
		bitser.unregisterClass('Horse')
	end)
	it("serializes SECL instances", function()
		local class_mt = {}

		function class_mt:__index(key)
			return self.__baseclass[key]
		end

		local class = setmetatable({ __baseclass = {} }, class_mt)

		function class:new(...)
			local c = {}
			c.__baseclass = self
			setmetatable(c, getmetatable(self))
			if c.init then
				c:init(...)
			end
			return c
		end

		local Horse = bitser.registerClass('Horse', class:new())
		function Horse:init(name)
			self.name = name
			self[1] = 'instance can be sequence'
		end
		local bojack = Horse:new('Bojack Horseman')
		test_serdeser(bojack)
		assert.are.equal(serdeser(bojack).__baseclass, Horse)
		bitser.unregisterClass('Horse')
	end)
	it("serializes hump.class instances", function()
		local class = require("class")
		local Horse = bitser.registerClass('Horse', class{})
		function Horse:init(name)
			self.name = name
			self[1] = 'instance can be sequence'
		end
		local bojack = Horse('Bojack Horseman')
		test_serdeser(bojack)
		assert.are.equal(getmetatable(serdeser(bojack)), Horse)
		bitser.unregisterClass('Horse')
	end)
	it("serializes Slither instances", function()
		local class = require("slither")
		local Horse = class.private 'Horse' {
			__attributes__ = {bitser.registerClass},
			__init__ = function(self, name)
				self.name = name
				self[1] = 'instance can be sequence'
			end
		}
		local bojack = Horse('Bojack Horseman')
		test_serdeser(bojack)
		assert.is_true(class.isinstance(serdeser(bojack), Horse))
		bitser.unregisterClass('Horse')
	end)
	it("serializes Moonscript class instances", function()
		local Horse
		do
			local _class_0
			local _base_0 = {}
			_base_0.__index = _base_0
			_class_0 = setmetatable({
				__init = function(self, name)
					self.name = name
					self[1] = 'instance can be sequence'
				end,
				__base = _base_0,
				__name = "Horse"}, {
				__index = _base_0,
				__call = function(cls, ...)
						local _self_0 = setmetatable({}, _base_0)
						cls.__init(_self_0, ...)
						return _self_0
					end
				})
			_base_0.__class = _class_0
			Horse = _class_0
		end
		assert.are.same(Horse.__name, "Horse") -- to shut coveralls up
		bitser.registerClass(Horse)
		local bojack = Horse('Bojack Horseman')
		test_serdeser(bojack)
		local new_bojack = serdeser(bojack)
		assert.are.equal(new_bojack.__class, Horse)
		bitser.unregisterClass('Horse')
	end)
	it("serializes custom class instances", function()
		local Horse_mt = bitser.registerClass('Horse', {__index = {}}, nil, setmetatable)
		local function Horse(name)
			local self = {}
			self.name = name
			self[1] = 'instance can be sequence'
			return setmetatable(self, Horse_mt)
		end
		local bojack = Horse('Bojack Horseman')
		test_serdeser(bojack)
		assert.are.equal(getmetatable(serdeser(bojack)), Horse_mt)
		bitser.unregisterClass('Horse')
	end)
	it("serializes classes that repeat keys", function()
		local my_mt  = {"hi"}
		local works  = { foo = 'a', bar = {baz = 'b'}, }
		local broken = { foo = 'a', bar = {foo = 'b'}, }
		local more_broken = {
			foo = 'a',
			baz = {foo = 'b', bar = 'c'},
			quz = {bar = 'd', bam = 'e'}
		}
		setmetatable(works,  my_mt)
		setmetatable(broken, my_mt)
		setmetatable(more_broken, my_mt)
		bitser.registerClass("Horse", my_mt, nil, setmetatable)
		test_serdeser(works)
		test_serdeser(broken)
		test_serdeser(more_broken)
		bitser.unregisterClass('Horse')
	end)
	it("serializes big data", function()
		local text = "this is a lot of nonsense, please disregard, we need a lot of data to get past 4 KiB (114 characters should do it)"
		local t = {}
		for i = 1, 40 do
			t[i] = text .. i -- no references allowed!
		end
		test_serdeser(t)
	end)
	it("serializes many references", function()
		local max = 1000
		local t = {}
		local t2 = {}
		for i = 1, max do
			t.t = {}
			t = t.t
			t2[i] = t
		end
		test_serdeser({t, t2})
	end)
	it("serializes resources with long names", function()
		local temp_resource = {}
		bitser.register("temp_resource_or_whatever", temp_resource)
		assert.are.equal(serdeser({this = temp_resource}).this, temp_resource)
		bitser.unregister("temp_resource_or_whatever")
	end)
	it("serializes resources with the same name as serialized strings", function()
	    local temp_resource = {}
	    bitser.register('temp', temp_resource)
	    test_serdeser({temp='temp', {temp_resource}})
	    bitser.unregister('temp')
	end)
	it("serializes resources with the same long name as serialized strings", function()
	    local temp_resource = {}
	    bitser.register('temp_resource_or_whatever', temp_resource)
	    test_serdeser({temp_resource_or_whatever='temp_resource_or_whatever', {temp_resource}})
	    bitser.unregister('temp_resource_or_whatever')
	end)
	it("cannot serialize functions", function()
		assert.has_error(function() bitser.dumps(function() end) end, "cannot serialize type function")
	end)
	it("cannot serialize unsupported class libraries without explicit deserializer", function()
		assert.has_error(function() bitser.registerClass('Horse', {mane = 'majestic'}) end, "no deserializer given for unsupported class library")
	end)
	it("cannot deserialize values from unassigned type bytes", function()
		assert.has_error(function() bitser.loads("\251") end, "unsupported serialized type 251")
		assert.has_error(function() bitser.loads("\252") end, "unsupported serialized type 252")
		assert.has_error(function() bitser.loads("\253") end, "unsupported serialized type 253")
		assert.has_error(function() bitser.loads("\254") end, "unsupported serialized type 254")
		assert.has_error(function() bitser.loads("\255") end, "unsupported serialized type 255")
	end)
	it("can load from raw data", function()
		assert.are.same(bitser.loadData(ffi.new("uint8_t[4]", 195, 103, 118, 120), 4), "gvx")
	end)
	it("will not read past the end of the buffer", function()
		assert.has_error(function() bitser.loadData(ffi.new("uint8_t[4]", 196, 103, 118, 120), 4) end)
	end)
	it("can clear the buffer", function()
		bitser.clearBuffer()
	end)
	it("can write to new buffer after reading from read-only buffer", function()
		test_serdeser("bitser")
		bitser.loadData(ffi.new("uint8_t[4]", 195, 103, 118, 120), 4)
		test_serdeser("bitser")
	end)
	it("it can dump and load LÖVE files", function()
		local v = {value = "value"}
		bitser.dumpLoveFile("some_file_name", v)
		assert.are.same(v, bitser.loadLoveFile("some_file_name"))
	end)
end)
