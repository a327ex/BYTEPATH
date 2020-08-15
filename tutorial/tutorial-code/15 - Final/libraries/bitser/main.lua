local found_bitser, bitser = pcall(require, 'bitser')
local found_binser, binser = pcall(require, 'binser')
local found_ser, ser = pcall(require, 'ser')
local found_serpent, serpent = pcall(require, 'serpent')
local found_smallfolk, smallfolk = pcall(require, 'smallfolk')
local found_msgpack, msgpack = pcall(require, 'MessagePack')

local cases
local selected_case = 1

local sers = {}
local desers = {}

if found_bitser then
	sers.bitser = bitser.dumps
	desers.bitser = bitser.loads
	bitser.reserveBuffer(1024 * 1024)
end

if found_binser then
	sers.binser = binser.s
	desers.binser = binser.d
end

if found_ser then
	sers.ser = ser
	desers.ser = loadstring
end

if found_serpent then
	sers.serpent = serpent.dump
	desers.serpent = loadstring
end

if found_smallfolk then
	sers.smallfolk = smallfolk.dumps
	desers.smallfolk = smallfolk.loads
end

if found_msgpack then
	sers.msgpack = msgpack.pack
	desers.msgpack = msgpack.unpack
end

local view_absolute = true
local resultname = "serialisation time in seconds"

function love.load()
	cases = love.filesystem.getDirectoryItems("cases")
	state = 'select_case'
	love.graphics.setBackgroundColor(255, 230, 220)
	love.graphics.setColor(40, 30, 0)
	love.window.setTitle("Select a benchmark testcase")
end

function love.keypressed(key)
	if state == 'select_case' then
		if key == 'up' then
			selected_case = (selected_case - 2) % #cases + 1
		elseif key == 'down' then
			selected_case = selected_case % #cases + 1
		elseif key == 'return' then
			state = 'calculate_results'
			love.window.setTitle("Running benchmark...")
		end
	elseif state == 'results' then
		if key == 'r' then
			view_absolute = not view_absolute
		elseif key == 'right' then
			if results == results_ser then
				results = results_deser
				resultname = "deserialisation time in seconds"
			elseif results == results_deser then
				results = results_size
				resultname = "size of output in bytes"
			elseif results == results_size then
				results = results_ser
				resultname = "serialisation time in seconds"
			end
		elseif key == 'left' then
			if results == results_ser then
				results = results_size
				resultname = "size of output in bytes"
			elseif results == results_deser then
				results = results_ser
				resultname = "serialisation time in seconds"
			elseif results == results_size then
				results = results_deser
				resultname = "deserialisation time in seconds"
			end
		elseif key == 'escape' then
			state = 'select_case'
			love.window.setTitle("Select a benchmark testcase")
		end
	end
end

function love.draw()
	if state == 'select_case' then
		for i, case in ipairs(cases) do
			love.graphics.print(case, selected_case == i and 60 or 20, i * 20)
		end
	elseif state == 'calculate_results' then
		love.graphics.print("Running benchmark...", 20, 20)
		love.graphics.print("This may take a while", 20, 40)
		state = 'calculate_results_2'
	elseif state == 'calculate_results_2' then
		local data, iters, tries = love.filesystem.load("cases/" .. cases[selected_case])()
		results_ser = {}
		results = results_ser
		resultname = "serialisation time in seconds"
		results_size = {}
		results_deser = {}
		for sername, serializer in pairs(sers) do
			results_ser[sername] = math.huge
			results_deser[sername] = math.huge
		end
		local outputs = {}
		for try = 1, tries do
			for sername, serializer in pairs(sers) do
				local output
				local success, diff = pcall(function()
					local t = os.clock()
					for i = 1, iters do
						output = serializer(data)
					end
					return os.clock() - t
				end)
				if success and diff < results_ser[sername] then
					results_ser[sername] = diff
				end
				if try == 1 then
					outputs[sername] = output
					results_size[sername] = output and #output or math.huge
				end
			end
		end
		for try = 1, tries do
			for sername, deserializer in pairs(desers) do
				local input = outputs[sername]
				local success, diff = pcall(function()
					local t = os.clock()
					for i = 1, iters / 10 do
						deserializer(input)
					end
					return os.clock() - t
				end)
				if success and diff < results_deser[sername] then
					results_deser[sername] = diff
				end
			end
		end
		state = 'results'
		love.window.setTitle("Results for " .. cases[selected_case])
	elseif state == 'results' then
		local results_min = math.huge
		local results_max = -math.huge
		for sername, result in pairs(results) do
			if result < results_min then
				results_min = result
			end
			if result > results_max and result < math.huge then
				results_max = result
			end
		end
		if view_absolute then results_min = 0 end
		local i = 1
		for sername, result in pairs(results) do
			love.graphics.print(sername, 20, i * 20)
			if result == math.huge then
				love.graphics.setColor(220, 30, 0)
				love.graphics.rectangle('fill', 100, i * 20, 780 - 100, 18)
				love.graphics.setColor(40, 30, 0)
			else
				love.graphics.rectangle('fill', 100, i * 20, (780 - 100) * (result - results_min) / (results_max - results_min), 18)
			end
			i = i + 1
		end
		love.graphics.print(results_min, 100, i * 20)
		love.graphics.print(results_max, 780 - love.graphics.getFont():getWidth(results_max), i * 20)
		love.graphics.print(resultname .." (smaller is better; try left, right, R, escape)", 100, i * 20 + 20)
	end
end