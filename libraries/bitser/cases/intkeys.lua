local t = {}

for i = 1, 200 do
	t[math.random(1000)] = math.random(100)
end

return t, 30000, 5