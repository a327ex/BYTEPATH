--[[
Copyright (c) 2016, Robin Wellner

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
]]

local floor = math.floor
local pairs = pairs
local type = type
local insert = table.insert
local getmetatable = getmetatable
local setmetatable = setmetatable

local ffi = require("ffi")
local buf_pos = 0
local buf_size = -1
local buf = nil
local writable_buf = nil
local writable_buf_size = nil

local function Buffer_prereserve(min_size)
	if buf_size < min_size then
		buf_size = min_size
		buf = ffi.new("uint8_t[?]", buf_size)
	end
end

local function Buffer_clear()
	buf_size = -1
	buf = nil
	writable_buf = nil
	writable_buf_size = nil
end

local function Buffer_makeBuffer(size)
	if writable_buf then
		buf = writable_buf
		buf_size = writable_buf_size
		writable_buf = nil
		writable_buf_size = nil
	end
	buf_pos = 0
	Buffer_prereserve(size)
end

local function Buffer_newReader(str)
	Buffer_makeBuffer(#str)
	ffi.copy(buf, str, #str)
end

local function Buffer_newDataReader(data, size)
	writable_buf = buf
	writable_buf_size = buf_size
	buf_pos = 0
	buf_size = size
	buf = ffi.cast("uint8_t*", data)
end

local function Buffer_reserve(additional_size)
	while buf_pos + additional_size > buf_size do
		buf_size = buf_size * 2
		local oldbuf = buf
		buf = ffi.new("uint8_t[?]", buf_size)
		ffi.copy(buf, oldbuf, buf_pos)
	end
end

local function Buffer_write_byte(x)
	Buffer_reserve(1)
	buf[buf_pos] = x
	buf_pos = buf_pos + 1
end

local function Buffer_write_string(s)
	Buffer_reserve(#s)
	ffi.copy(buf + buf_pos, s, #s)
	buf_pos = buf_pos + #s
end

local function Buffer_write_data(ct, len, ...)
	Buffer_reserve(len)
	ffi.copy(buf + buf_pos, ffi.new(ct, ...), len)
	buf_pos = buf_pos + len
end

local function Buffer_ensure(numbytes)
	if buf_pos + numbytes > buf_size then
		error("malformed serialized data")
	end
end

local function Buffer_read_byte()
	Buffer_ensure(1)
	local x = buf[buf_pos]
	buf_pos = buf_pos + 1
	return x
end

local function Buffer_read_string(len)
	Buffer_ensure(len)
	local x = ffi.string(buf + buf_pos, len)
	buf_pos = buf_pos + len
	return x
end

local function Buffer_read_data(ct, len)
	Buffer_ensure(len)
	local x = ffi.new(ct)
	ffi.copy(x, buf + buf_pos, len)
	buf_pos = buf_pos + len
	return x
end

local resource_registry = {}
local resource_name_registry = {}
local class_registry = {}
local class_name_registry = {}
local classkey_registry = {}
local class_deserialize_registry = {}

local serialize_value

local function write_number(value, _)
	if floor(value) == value and value >= -2147483648 and value <= 2147483647 then
		if value >= -27 and value <= 100 then
			--small int
			Buffer_write_byte(value + 27)
		elseif value >= -32768 and value <= 32767 then
			--short int
			Buffer_write_byte(250)
			Buffer_write_data("int16_t[1]", 2, value)
		else
			--long int
			Buffer_write_byte(245)
			Buffer_write_data("int32_t[1]", 4, value)
		end
	else
		--double
		Buffer_write_byte(246)
		Buffer_write_data("double[1]", 8, value)
	end
end

local function write_string(value, _)
	if #value < 32 then
		--short string
		Buffer_write_byte(192 + #value)
	else
		--long string
		Buffer_write_byte(244)
		write_number(#value)
	end
	Buffer_write_string(value)
end

local function write_nil(_, _)
	Buffer_write_byte(247)
end

local function write_boolean(value, _)
	Buffer_write_byte(value and 249 or 248)
end

local function write_table(value, seen)
	local classkey
	local classname = (class_name_registry[value.class] -- MiddleClass
		or class_name_registry[value.__baseclass] -- SECL
		or class_name_registry[getmetatable(value)] -- hump.class
		or class_name_registry[value.__class__] -- Slither
		or class_name_registry[value.__class]) -- Moonscript class
	if classname then
		classkey = classkey_registry[classname]
		Buffer_write_byte(242)
		serialize_value(classname, seen)
	else
		Buffer_write_byte(240)
	end
	local len = #value
	write_number(len, seen)
	for i = 1, len do
		serialize_value(value[i], seen)
	end
	local klen = 0
	for k in pairs(value) do
		if (type(k) ~= 'number' or floor(k) ~= k or k > len or k < 1) and k ~= classkey then
			klen = klen + 1
		end
	end
	write_number(klen, seen)
	for k, v in pairs(value) do
		if (type(k) ~= 'number' or floor(k) ~= k or k > len or k < 1) and k ~= classkey then
			serialize_value(k, seen)
			serialize_value(v, seen)
		end
	end
end

local types = {number = write_number, string = write_string, table = write_table, boolean = write_boolean, ["nil"] = write_nil}

serialize_value = function(value, seen)
	if seen[value] then
		local ref = seen[value]
		if ref < 64 then
			--small reference
			Buffer_write_byte(128 + ref)
		else
			--long reference
			Buffer_write_byte(243)
			write_number(ref, seen)
		end
		return
	end
	local t = type(value)
	if t ~= 'number' and t ~= 'boolean' and t ~= 'nil' then
		seen[value] = seen.len
		seen.len = seen.len + 1
	end
	if resource_name_registry[value] then
		local name = resource_name_registry[value]
		if #name < 16 then
			--small resource
			Buffer_write_byte(224 + #name)
			Buffer_write_string(name)
		else
			--long resource
			Buffer_write_byte(241)
			write_string(name, seen)
		end
		return
	end
	(types[t] or
		error("cannot serialize type " .. t)
		)(value, seen)
end

local function serialize(value)
	Buffer_makeBuffer(4096)
	local seen = {len = 0}
	serialize_value(value, seen)
end

local function add_to_seen(value, seen)
	insert(seen, value)
	return value
end

local function reserve_seen(seen)
	insert(seen, 42)
	return #seen
end

local function deserialize_value(seen)
	local t = Buffer_read_byte()
	if t < 128 then
		--small int
		return t - 27
	elseif t < 192 then
		--small reference
		return seen[t - 127]
	elseif t < 224 then
		--small string
		return add_to_seen(Buffer_read_string(t - 192), seen)
	elseif t < 240 then
		--small resource
		return add_to_seen(resource_registry[Buffer_read_string(t - 224)], seen)
	elseif t == 240 then
		--table
		local v = add_to_seen({}, seen)
		local len = deserialize_value(seen)
		for i = 1, len do
			v[i] = deserialize_value(seen)
		end
		len = deserialize_value(seen)
		for _ = 1, len do
			local key = deserialize_value(seen)
			v[key] = deserialize_value(seen)
		end
		return v
	elseif t == 241 then
		--long resource
		local idx = reserve_seen(seen)
		local value = resource_registry[deserialize_value(seen)]
		seen[idx] = value
		return value
	elseif t == 242 then
		--instance
		local instance = add_to_seen({}, seen)
		local classname = deserialize_value(seen)
		local class = class_registry[classname]
		local classkey = classkey_registry[classname]
		local deserializer = class_deserialize_registry[classname]
		local len = deserialize_value(seen)
		for i = 1, len do
			instance[i] = deserialize_value(seen)
		end
		len = deserialize_value(seen)
		for _ = 1, len do
			local key = deserialize_value(seen)
			instance[key] = deserialize_value(seen)
		end
		if classkey then
			instance[classkey] = class
		end
		return deserializer(instance, class)
	elseif t == 243 then
		--reference
		return seen[deserialize_value(seen) + 1]
	elseif t == 244 then
		--long string
		return add_to_seen(Buffer_read_string(deserialize_value(seen)), seen)
	elseif t == 245 then
		--long int
		return Buffer_read_data("int32_t[1]", 4)[0]
	elseif t == 246 then
		--double
		return Buffer_read_data("double[1]", 8)[0]
	elseif t == 247 then
		--nil
		return nil
	elseif t == 248 then
		--false
		return false
	elseif t == 249 then
		--true
		return true
	elseif t == 250 then
		--short int
		return Buffer_read_data("int16_t[1]", 2)[0]
	else
		error("unsupported serialized type " .. t)
	end
end

local function deserialize_MiddleClass(instance, class)
	return setmetatable(instance, class.__instanceDict)
end

local function deserialize_SECL(instance, class)
	return setmetatable(instance, getmetatable(class))
end

local deserialize_humpclass = setmetatable

local function deserialize_Slither(instance, class)
	return getmetatable(class).allocate(instance)
end

local function deserialize_Moonscript(instance, class)
	return setmetatable(instance, class.__base)
end

return {dumps = function(value)
	serialize(value)
	return ffi.string(buf, buf_pos)
end, dumpLoveFile = function(fname, value)
	serialize(value)
	love.filesystem.write(fname, ffi.string(buf, buf_pos))
end, loadLoveFile = function(fname)
	local serializedData = love.filesystem.newFileData(fname)
	Buffer_newDataReader(serializedData:getPointer(), serializedData:getSize())
	return deserialize_value({})
end, loadData = function(data, size)
	Buffer_newDataReader(data, size)
	return deserialize_value({})
end, loads = function(str)
	Buffer_newReader(str)
	return deserialize_value({})
end, register = function(name, resource)
	assert(not resource_registry[name], name .. " already registered")
	resource_registry[name] = resource
	resource_name_registry[resource] = name
	return resource
end, unregister = function(name)
	resource_name_registry[resource_registry[name]] = nil
	resource_registry[name] = nil
end, registerClass = function(name, class, classkey, deserializer)
	if not class then
		class = name
		name = class.__name__ or class.name or class.__name
	end
	if not classkey then
		if class.__instanceDict then
			-- assume MiddleClass
			classkey = 'class'
		elseif class.__baseclass then
			-- assume SECL
			classkey = '__baseclass'
		end
		-- assume hump.class, Slither, Moonscript class or something else that doesn't store the
		-- class directly on the instance
	end
	if not deserializer then
		if class.__instanceDict then
			-- assume MiddleClass
			deserializer = deserialize_MiddleClass
		elseif class.__baseclass then
			-- assume SECL
			deserializer = deserialize_SECL
		elseif class.__index == class then
			-- assume hump.class
			deserializer = deserialize_humpclass
		elseif class.__name__ then
			-- assume Slither
			deserializer = deserialize_Slither
		elseif class.__base then
			-- assume Moonscript class
			deserializer = deserialize_Moonscript
		else
			error("no deserializer given for unsupported class library")
		end
	end
	class_registry[name] = class
	classkey_registry[name] = classkey
	class_deserialize_registry[name] = deserializer
	class_name_registry[class] = name
	return class
end, unregisterClass = function(name)
	class_name_registry[class_registry[name]] = nil
	classkey_registry[name] = nil
	class_deserialize_registry[name] = nil
	class_registry[name] = nil
end, reserveBuffer = Buffer_prereserve, clearBuffer = Buffer_clear}
