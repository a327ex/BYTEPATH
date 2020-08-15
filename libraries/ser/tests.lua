local serialize = require 'ser'

local succeeded = 0
local failed = 0

function case(input, expected, message)
	local output = serialize(input)
	if output == expected then
		succeeded = succeeded + 1
	else
		print('test failed: ' .. message)
		print('expected:')
		print(expected)
		print('got:')
		print(output)
		failed = failed + 1
	end
end

function case_error(input, expected, message)
	local success, err = pcall(serialize, input)
	if not success and err == expected then
		succeeded = succeeded + 1
	else
		print('test failed: ' .. message)
		print('expected error:')
		print(expected)
		print('got:')
		print(success, err)
		failed = failed + 1
	end
end

case({}, 'return {}', 'empty table')

case({true}, 'return {true}', 'simple table')

case({{}}, [[
local _={}
_[1]={}
return {_[1]}]], 'empty table within a table')

local _t = {}
_t.self = _t
case(_t, [=[local _={}
_[0]={}
_[0].self=_[0]
return _[0]]=], 'simple cycle')

case_error({coroutine.create(function()end)}, './ser.lua:29: Trying to serialize unsupported type thread', 'unsupported type')

case({"a", foo = "bar", ["3f"] = true, _1 = false, ["00"] = 9}, 'return {"a",["3f"]=true,_1=false,["00"]=9,foo="bar"}', 'various')

case({'\127\230\255\254\128\12\0128\n\31'}, 'return {"\\127\\230\\255\\254\\128\\12\\0128\\n\\31"}', 'non-ASCII or control characters in string value')

case({['\127\230\255\254\128\12\0128\n\31'] = '\0'}, 'return {["\\127\\230\\255\\254\\128\\12\\0128\\n\\31"]="\\0"}', 'non-ASCII or control characters in string key')

local x = {}
case({x, {x}, x}, [=[
local _={}
_[2]={nil}
_[1]={}
_[0]={_[1],_[2],_[1]}
_[2][1]=_[1]
return _[0]]=], 'repeated table')

case({['end'] = true, ['false'] = false}, 'return {["false"]=false,["end"]=true}', 'keywords as table keys')

case({1/0, -1/0, 0/0}, 'return {1/0,-1/0,0/0}', 'representation of infinity and NaN')

print(failed .. ' tests failed')
print(succeeded .. ' tests succeeded')
