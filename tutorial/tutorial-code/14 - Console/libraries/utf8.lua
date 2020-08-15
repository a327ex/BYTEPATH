-- $Id: utf8.lua 179 2009-04-03 18:10:03Z pasta $
--
-- Provides UTF-8 aware string functions implemented in pure lua:
-- * string.utf8len(s)
-- * string.utf8sub(s, i, j)
-- * string.utf8reverse(s)
-- * string.utf8char(unicode)
-- * string.utf8unicode(s, i, j)
-- * string.utf8gensub(s, sub_len)
--
-- If utf8data.lua (containing the lower<->upper case mappings) is loaded, these
-- additional functions are available:
-- * string.utf8upper(s)
-- * string.utf8lower(s)
--
-- All functions behave as their non UTF-8 aware counterparts with the exception
-- that UTF-8 characters are used instead of bytes for all units.

--[[
Copyright (c) 2006-2007, Kyle Smith
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the author nor the names of its contributors may be
      used to endorse or promote products derived from this software without
      specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]

-- ABNF from RFC 3629
-- 
-- UTF8-octets = *( UTF8-char )
-- UTF8-char   = UTF8-1 / UTF8-2 / UTF8-3 / UTF8-4
-- UTF8-1      = %x00-7F
-- UTF8-2      = %xC2-DF UTF8-tail
-- UTF8-3      = %xE0 %xA0-BF UTF8-tail / %xE1-EC 2( UTF8-tail ) /
--               %xED %x80-9F UTF8-tail / %xEE-EF 2( UTF8-tail )
-- UTF8-4      = %xF0 %x90-BF 2( UTF8-tail ) / %xF1-F3 3( UTF8-tail ) /
--               %xF4 %x80-8F 2( UTF8-tail )
-- UTF8-tail   = %x80-BF
-- 

-- returns the number of bytes used by the UTF-8 character at byte i in s
-- also doubles as a UTF-8 character validator
local function utf8charbytes (s, i)
	-- argument defaults
	i = i or 1

	-- argument checking
	if type(s) ~= "string" then
		error("bad argument #1 to 'utf8charbytes' (string expected, got ".. type(s).. ")")
	end
	if type(i) ~= "number" then
		error("bad argument #2 to 'utf8charbytes' (number expected, got ".. type(i).. ")")
	end

	local c = s:byte(i)

	-- determine bytes needed for character, based on RFC 3629
	-- validate byte 1
	if c > 0 and c <= 127 then
		-- UTF8-1
		return 1

	elseif c >= 194 and c <= 223 then
		-- UTF8-2
		local c2 = s:byte(i + 1)

		if not c2 then
			error("UTF-8 string terminated early")
		end

		-- validate byte 2
		if c2 < 128 or c2 > 191 then
			error("Invalid UTF-8 character")
		end

		return 2

	elseif c >= 224 and c <= 239 then
		-- UTF8-3
		local c2 = s:byte(i + 1)
		local c3 = s:byte(i + 2)

		if not c2 or not c3 then
			error("UTF-8 string terminated early")
		end

		-- validate byte 2
		if c == 224 and (c2 < 160 or c2 > 191) then
			error("Invalid UTF-8 character")
		elseif c == 237 and (c2 < 128 or c2 > 159) then
			error("Invalid UTF-8 character")
		elseif c2 < 128 or c2 > 191 then
			error("Invalid UTF-8 character")
		end

		-- validate byte 3
		if c3 < 128 or c3 > 191 then
			error("Invalid UTF-8 character")
		end

		return 3

	elseif c >= 240 and c <= 244 then
		-- UTF8-4
		local c2 = s:byte(i + 1)
		local c3 = s:byte(i + 2)
		local c4 = s:byte(i + 3)

		if not c2 or not c3 or not c4 then
			error("UTF-8 string terminated early")
		end

		-- validate byte 2
		if c == 240 and (c2 < 144 or c2 > 191) then
			error("Invalid UTF-8 character")
		elseif c == 244 and (c2 < 128 or c2 > 143) then
			error("Invalid UTF-8 character")
		elseif c2 < 128 or c2 > 191 then
			error("Invalid UTF-8 character")
		end
		
		-- validate byte 3
		if c3 < 128 or c3 > 191 then
			error("Invalid UTF-8 character")
		end

		-- validate byte 4
		if c4 < 128 or c4 > 191 then
			error("Invalid UTF-8 character")
		end

		return 4

	else
		error("Invalid UTF-8 character")
	end
end

-- returns the number of characters in a UTF-8 string
local function utf8len (s)
	-- argument checking
	if type(s) ~= "string" then
		error("bad argument #1 to 'utf8len' (string expected, got ".. type(s).. ")")
	end

	local pos = 1
	local bytes = s:len()
	local len = 0

	while pos <= bytes do
		len = len + 1
		pos = pos + utf8charbytes(s, pos)
	end

	return len
end

-- functions identically to string.sub except that i and j are UTF-8 characters
-- instead of bytes
local function utf8sub (s, i, j)
	-- argument defaults
	j = j or -1

	local pos = 1
	local bytes = s:len()
	local len = 0

	-- only set l if i or j is negative
	local l = (i >= 0 and j >= 0) or s:utf8len()
	local startChar = (i >= 0) and i or l + i + 1
	local endChar   = (j >= 0) and j or l + j + 1

	-- can't have start before end!
	if startChar > endChar then
		return ""
	end

	-- byte offsets to pass to string.sub
	local startByte,endByte = 1,bytes
	
	while pos <= bytes do
		len = len + 1

		if len == startChar then
			startByte = pos
		end

		pos = pos + utf8charbytes(s, pos)

		if len == endChar then
			endByte = pos - 1
			break
		end
	end
	
	if startChar > len then startByte = bytes+1   end
	if endChar   < 1   then endByte   = 0         end
	
	return s:sub(startByte, endByte)
end


-- replace UTF-8 characters based on a mapping table
local function utf8replace (s, mapping)
	-- argument checking
	if type(s) ~= "string" then
		error("bad argument #1 to 'utf8replace' (string expected, got ".. type(s).. ")")
	end
	if type(mapping) ~= "table" then
		error("bad argument #2 to 'utf8replace' (table expected, got ".. type(mapping).. ")")
	end

	local pos = 1
	local bytes = s:len()
	local charbytes
	local newstr = ""

	while pos <= bytes do
		charbytes = utf8charbytes(s, pos)
		local c = s:sub(pos, pos + charbytes - 1)

		newstr = newstr .. (mapping[c] or c)

		pos = pos + charbytes
	end

	return newstr
end


-- identical to string.upper except it knows about unicode simple case conversions
local function utf8upper (s)
	return utf8replace(s, utf8_lc_uc)
end

-- identical to string.lower except it knows about unicode simple case conversions
local function utf8lower (s)
	return utf8replace(s, utf8_uc_lc)
end

-- identical to string.reverse except that it supports UTF-8
local function utf8reverse (s)
	-- argument checking
	if type(s) ~= "string" then
		error("bad argument #1 to 'utf8reverse' (string expected, got ".. type(s).. ")")
	end

	local bytes = s:len()
	local pos = bytes
	local charbytes
	local newstr = ""

	while pos > 0 do
		c = s:byte(pos)
		while c >= 128 and c <= 191 do
			pos = pos - 1
			c = s:byte(pos)
		end

		charbytes = utf8charbytes(s, pos)

		newstr = newstr .. s:sub(pos, pos + charbytes - 1)

		pos = pos - 1
	end

	return newstr
end

-- http://en.wikipedia.org/wiki/Utf8
-- http://developer.coronalabs.com/code/utf-8-conversion-utility
local function utf8char(unicode)
	if unicode <= 0x7F then return string.char(unicode) end
	
	if (unicode <= 0x7FF) then
		local Byte0 = 0xC0 + math.floor(unicode / 0x40);
		local Byte1 = 0x80 + (unicode % 0x40);
		return string.char(Byte0, Byte1);
	end;
	
	if (unicode <= 0xFFFF) then
		local Byte0 = 0xE0 +  math.floor(unicode / 0x1000);
		local Byte1 = 0x80 + (math.floor(unicode / 0x40) % 0x40);
		local Byte2 = 0x80 + (unicode % 0x40);
		return string.char(Byte0, Byte1, Byte2);
	end;
	
	if (unicode <= 0x10FFFF) then
		local code = unicode
		local Byte3= 0x80 + (code % 0x40);
		code       = math.floor(code / 0x40)
		local Byte2= 0x80 + (code % 0x40);
		code       = math.floor(code / 0x40)
		local Byte1= 0x80 + (code % 0x40);
		code       = math.floor(code / 0x40)  
		local Byte0= 0xF0 + code;
		
		return string.char(Byte0, Byte1, Byte2, Byte3);
	end;
	
	error 'Unicode cannot be greater than U+10FFFF!'
end

local shift_6  = 2^6
local shift_12 = 2^12
local shift_18 = 2^18

local utf8unicode
utf8unicode = function(str, i, j, byte_pos)
	i = i or 1
	j = j or i
	
	if i > j then return end
	
	local char,bytes
	
	if byte_pos then 
		bytes = utf8charbytes(str,byte_pos)
		char  = str:sub(byte_pos,byte_pos-1+bytes)
	else
		char,byte_pos = utf8sub(str,i,i)
		bytes         = #char
	end
	
	local unicode
	
	if bytes == 1 then unicode = string.byte(char) end
	if bytes == 2 then
		local byte0,byte1 = string.byte(char,1,2)
		local code0,code1 = byte0-0xC0,byte1-0x80
		unicode = code0*shift_6 + code1
	end
	if bytes == 3 then
		local byte0,byte1,byte2 = string.byte(char,1,3)
		local code0,code1,code2 = byte0-0xE0,byte1-0x80,byte2-0x80
		unicode = code0*shift_12 + code1*shift_6 + code2
	end
	if bytes == 4 then
		local byte0,byte1,byte2,byte3 = string.byte(char,1,4)
		local code0,code1,code2,code3 = byte0-0xF0,byte1-0x80,byte2-0x80,byte3-0x80
		unicode = code0*shift_18 + code1*shift_12 + code2*shift_6 + code3
	end
	
	return unicode,utf8unicode(str, i+1, j, byte_pos+bytes)
end

-- Returns an iterator which returns the next substring and its byte interval
local function utf8gensub(str, sub_len)
	sub_len        = sub_len or 1
	local byte_pos = 1
	local len      = #str
	return function()
		local char_count = 0
		local start      = byte_pos
		repeat
			if byte_pos > len then return end
			char_count  = char_count + 1
			local bytes = utf8charbytes(str,byte_pos)
			byte_pos    = byte_pos+bytes
			
		until char_count == sub_len
		
		local last  = byte_pos-1
		local sub   = str:sub(start,last)
		return sub, start, last
	end
end

string.utf8len       = utf8len
string.utf8sub       = utf8sub
string.utf8reverse   = utf8reverse
string.utf8char      = utf8char
string.utf8unicode   = utf8unicode
string.utf8gensub    = utf8gensub