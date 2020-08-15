--- Utility-belt library for functional programming in Lua ([source](http://github.com/Yonaba/Moses))
-- @author [Roland Yonaba](http://github.com/Yonaba)
-- @copyright 2012-2017
-- @license [MIT](http://www.opensource.org/licenses/mit-license.php)
-- @release 1.6.0
-- @module moses

local _MODULEVERSION = '1.6.0'

-- Internalisation
local next, type, select, pcall = next, type, select, pcall
local setmetatable, getmetatable = setmetatable, getmetatable
local t_insert, t_sort = table.insert, table.sort
local t_remove,t_concat = table.remove, table.concat
local randomseed, random, huge = math.randomseed, math.random, math.huge
local floor, max, min = math.floor, math.max, math.min
local rawget = rawget
local unpack = table.unpack or unpack
local pairs,ipairs = pairs,ipairs
local _ = {}


-- ======== Private helpers

local function f_max(a,b) return a>b end
local function f_min(a,b) return a<b end
local function clamp(var,a,b) return (var<a) and a or (var>b and b or var) end
local function isTrue(_,value) return value and true end
local function iNot(value) return not value end

local function count(t)  -- raw count of items in an map-table
  local i = 0
    for k,v in pairs(t) do i = i + 1 end
  return i
end

local function extract(list,comp,transform,...) -- extracts value from a list
  local _ans
  local transform = transform or _.identity
  for index,value in pairs(list) do
    if not _ans then _ans = transform(value,...)
    else
      local value = transform(value,...)
      _ans = comp(_ans,value) and _ans or value
    end
  end
  return _ans
end

local function partgen(t, n, f, pad) -- generates array partitions
  for i = 0, #t, n do
    local s = _.slice(t, i+1, i+n)
    if #s>0 then 
			while (#s < n and pad) do s[#s+1] = pad end			
			f(s)
		end
  end
end

local function partgen2(t, n, f, pad) -- generates sliding array partitions
  for i = 0, #t, n-1 do
    local s = _.slice(t, i+1, i+n)
    if #s>0 and i+1<#t then 
			while (#s < n and pad) do s[#s+1] = pad end
			f(s)
		end
  end
end

local function permgen(t, n, f) -- taken from PiL: http://www.lua.org/pil/9.3.html
  if n == 0 then f(t) end
  for i = 1,n do
    t[n], t[i] = t[i], t[n]
    permgen(t, n-1, f)
    t[n], t[i] = t[i], t[n]
  end
end

-- Internal counter for unique ids generation
local unique_id_counter = -1

--- Table functions
-- @section Table functions

--- Iterates on key-value pairs, calling `f (k, v)` at every step.
-- <br/><em>Aliased as `forEach`</em>.
-- @name each
-- @param t a table
-- @param f a function, prototyped as `f (k, v, ...)`
-- @param[opt] ... Optional args to be passed to `f`
-- @see eachi
function _.each(t, f, ...)
  for index,value in pairs(t) do
    f(index,value,...)
  end
end

--- Iterates on integer key-value pairs, calling `f(k, v)` every step. 
-- Only applies to values located at integer keys. The table can be a sparse array. 
-- Iteration will start from the lowest integer key found to the highest one.
-- <br/><em>Aliased as `forEachi`</em>.
-- @name eachi
-- @param t a table
-- @param f a function, prototyped as `f (k, v, ...)`
-- @param[opt] ... Optional args to be passed to `f`
-- @see each
function _.eachi(t, f, ...)
  local lkeys = _.sort(_.select(_.keys(t), function(k,v)
    return _.isInteger(v)
  end))
  for k, key in ipairs(lkeys) do
    f(key, t[key],...)
  end
end

--- Collects values at given keys and return them wrapped in an array.
-- @name at
-- @param t a table
-- @param ... A variable number of keys to collect values
-- @return an array-list of values
function _.at(t, ...)
  local values = {}
  for i, key in ipairs({...}) do
    if _.has(t, key) then values[#values+1] = t[key] end
  end
  return values
end

--- Counts occurrences of a given value in a table. Uses @{isEqual} to compare values.
-- @name count
-- @param t a table
-- @param[opt] value a value to be searched in the table. If not given, the @{size} of the table will be returned
-- @return the count of occurrences of the given value
-- @see countf
-- @see size
function _.count(t, value)
  if _.isNil(value) then return _.size(t) end
  local count = 0
  _.each(t, function(k,v)
    if _.isEqual(v, value) then count = count + 1 end
  end)
  return count
end

--- Counts occurrences validating a predicate. Same as @{count}, but uses an iterator. 
-- Returns the count for values passing the test `f (k, v, ...)`
-- @name countf
-- @param t a table
-- @param f an iterator function, prototyped as `f (k, v, ...)`
-- @param[opt] ... Optional args to be passed to `f`
-- @return the count of values validating the predicate
-- @see count
-- @see size
function _.countf(t, f, ...)
  return _.count(_.map(t, f, ...), true)
end

--- Loops `n` times through a table. In case `n` is omitted, it will loop forever.
-- In case `n` is lower or equal to 0, it returns an empty function.
-- <br/><em>Aliased as `loop`</em>.
-- @name cycle
-- @param t a table
-- @param n the number of loops
-- @return an iterator function yielding key-value pairs from the passed-in table.
function _.cycle(t, n)
  n = n or 1
  if n<=0 then return _.noop end
  local k, fk
  local i = 0
  while true do
    return function()
      k = k and next(t,k) or next(t)
      fk = not fk and k or fk
      if n then
        i = (k==fk) and i+1 or i
        if i > n then
          return
        end
      end
      return k, t[k]
    end
  end
end

--- Maps `f (k, v)` on key-value pairs, collects and returns the results.
-- <br/><em>Aliased as `collect`</em>.
-- @name map
-- @param t a table
-- @param f  an iterator function, prototyped as `f (k, v, ...)`
-- @param[opt] ... Optional args to be passed to `f`
-- @return a table of results
function _.map(t, f, ...)
  local _t = {}
  for index,value in pairs(t) do
    local k, kv, v = index, f(index,value,...)
    _t[v and kv or k] = v or kv
  end
  return _t
end

--- Reduces a table, left-to-right. Folds the table from the first element to the last element
-- to a single value, using a given iterator and an initial state.
-- The iterator takes a state and a value and returns a new state.
-- <br/><em>Aliased as `inject`, `foldl`</em>.
-- @name reduce
-- @param t a table
-- @param f an iterator function, prototyped as `f (state, value)`
-- @param[opt] state an initial state of reduction. Defaults to the first value in the table.
-- @return the final state of reduction
-- @see reduceRight
-- @see reduceby
function _.reduce(t, f, state)
  for __,value in pairs(t) do
    if state == nil then state = value
    else state = f(state,value)
    end
  end
  return state
end

--- Reduces values in a table passing a given predicate. Folds the table left-to-right, considering
-- only values validating a given predicate.
-- @name reduceby
-- @param t a table
-- @param f an iterator function, prototyped as `f (state, value)`
-- @param state an initial state of reduction.
-- @param pred a predicate function `pred (k, v, ...)` to select values to be considered for reduction
-- @param[opt] ... optional args to be passed to `pred`
-- @return the final state of reduction
-- @see reduce
function _.reduceby(t, f, state, pred, ...)
	return _.reduce(_.select(t, pred, ...), f, state)
end

--- Reduces a table, right-to-left. Folds the table from the last element to the first element 
-- to single value, using a given iterator and an initial state.
-- The iterator takes a state and a value, and returns a new state.
-- <br/><em>Aliased as `injectr`, `foldr`</em>.
-- @name reduceRight
-- @param t a table
-- @param f an iterator function, prototyped as `f (state, value)`
-- @param[opt] state an initial state of reduction. Defaults to the last value in the table.
-- @return the final state of reduction
-- @see reduce
function _.reduceRight(t, f, state)
  return _.reduce(_.reverse(t),f,state)
end

--- Reduces a table while saving intermediate states. Folds the table left-to-right
-- using a given iterator and an initial state. The iterator takes a state and a value, 
-- and returns a new state. The result is an array of intermediate states.
-- <br/><em>Aliased as `mapr`</em>
-- @name mapReduce
-- @param t a table
-- @param f an iterator function, prototyped as `f (state, value)`
-- @param[opt] state an initial state of reduction. Defaults to the first value in the table.
-- @return an array of states
-- @see mapReduceRight
function _.mapReduce(t, f, state)
  local _t = {}
  for i,value in pairs(t) do
    _t[i] = not state and value or f(state,value)
    state = _t[i]
  end
  return _t
end

--- Reduces a table while saving intermediate states. Folds the table right-to-left
-- using a given iterator and an initial state. The iterator takes a state and a value, 
-- and returns a new state. The result is an array of intermediate states.
-- <br/><em>Aliased as `maprr`</em>
-- @name mapReduceRight
-- @param t a table
-- @param f an iterator function, prototyped as `f (state, value)`
-- @param[opt] state an initial state of reduction. Defaults to the last value in the table.
-- @return an array of states
-- @see mapReduce
function _.mapReduceRight(t, f, state)
  return _.mapReduce(_.reverse(t),f,state)
end

--- Performs a linear search for a value in a table. It does not work for nested tables.
-- The given value can be a function prototyped as `f (v, value)` which should return true when
-- any v in the table equals the value being searched. 
-- <br/><em>Aliased as `any`, `some`, `contains`</em>
-- @name include
-- @param t a table
-- @param value a value to search for
-- @return a boolean : `true` when found, `false` otherwise
-- @see detect
function _.include(t, value)
  local _iter = _.isFunction(value) and value or _.isEqual
  for __,v in pairs(t) do
    if _iter(v,value) then return true end
  end
  return false
end

--- Performs a linear search for a value in a table. Returns the key of the value if found.
-- The given value can be a function prototyped as `f (v, value)` which should return true when
-- any v in the table equals the value being searched. 
-- @name detect
-- @param t a table
-- @param value a value to search for
-- @return the key of the value when found or __nil__
-- @see include
function _.detect(t, value)
  local _iter = _.isFunction(value) and value or _.isEqual
  for key,arg in pairs(t) do
    if _iter(arg,value) then return key end
  end
end

--- Returns all values having specified keys `props`.
-- @name where
-- @param t a table
-- @param props a set of keys
-- @return an array of values from the passed-in table
-- @see findWhere
function _.where(t, props)
	local r = _.select(t, function(__,v)
		for key in pairs(props) do
			if v[key] ~= props[key] then return false end
		end
		return true
	end)
	return #r > 0 and r or nil
end

--- Returns the first value having specified keys `props`.
-- @name findWhere
-- @param t a table
-- @param props a set of keys
-- @return a value from the passed-in table
-- @see where
function _.findWhere(t, props)
  local index = _.detect(t, function(v)
    for key in pairs(props) do
      if props[key] ~= v[key] then return false end
    end
    return true
  end)
  return index and t[index]
end

--- Selects and returns values passing an iterator test.
-- <br/><em>Aliased as `filter`</em>.
-- @name select
-- @param t a table
-- @param f an iterator function, prototyped as `f (k, v, ...)`
-- @param[opt] ... Optional args to be passed to `f`
-- @return the selected values
-- @see reject
function _.select(t, f, ...)
  local _t = {}
  for index,value in pairs(t) do
    if f(index, value,...) then _t[#_t+1] = value end
  end
  return _t
end

--- Clones a table while dropping values passing an iterator test.
-- <br/><em>Aliased as `discard`</em>
-- @name reject
-- @param t a table
-- @param f an iterator function, prototyped as `f (k, v, ...)`
-- @param[opt] ... Optional args to be passed to `f`
-- @return the remaining values
-- @see select
function _.reject(t, f, ...)
  local _mapped = _.map(t,f,...)
  local _t = {}
  for index,value in pairs (_mapped) do
    if not value then _t[#_t+1] = t[index] end
  end
  return _t
end

--- Checks if all values in a table are passing an iterator test.
-- <br/><em>Aliased as `every`</em>
-- @name all
-- @param t a table
-- @param f an iterator function, prototyped as `f (k, v, ...)`
-- @param[opt] ... Optional args to be passed to `f`
-- @return `true` if all values passes the predicate, `false` otherwise
function _.all(t, f, ...)
  return ((#_.select(_.map(t,f,...), isTrue)) == count(t))
end

--- Invokes a method on each value in a table.
-- @name invoke
-- @param t a table
-- @param method a function, prototyped as `f (v, ...)`
-- @param[opt] ... Optional args to be passed to `method`
-- @return the result of the call `f (v, ...)`
-- @see pluck
function _.invoke(t, method, ...)
  local args = {...}
  return _.map(t, function(__,v)
    if _.isTable(v) then
      if _.has(v,method) then
        if _.isCallable(v[method]) then
          return v[method](v,unpack(args))
        else
          return v[method]
        end
      else
        if _.isCallable(method) then
          return method(v,unpack(args))
        end
      end
    elseif _.isCallable(method) then
      return method(v,unpack(args))
    end
  end)
end

--- Extracts values in a table having a given key.
-- @name pluck
-- @param t a table
-- @param key a key, will be used to index in each value: `value[key]`
-- @return an array of values having the given key
function _.pluck(t, key)
  return _.reject(_.map(t,function(__,value)
      return value[key]
    end), iNot)
end

--- Returns the max value in a collection. If an transformation function is passed, it will
-- be used to evaluate values by which all objects will be sorted.
-- @name max
-- @param t a table
-- @param[opt] transform a transformation function, prototyped as `transform (v, ...)`, defaults to @{identity}
-- @param[optchain] ... Optional args to be passed to `transform`
-- @return the max value found
-- @see min
function _.max(t, transform, ...)
  return extract(t, f_max, transform, ...)
end

--- Returns the min value in a collection. If an transformation function is passed, it will
-- be used to evaluate values by which all objects will be sorted.
-- @name min
-- @param t a table
-- @param[opt] transform a transformation function, prototyped as `transform (v, ...)`, defaults to @{identity}
-- @param[optchain] ... Optional args to be passed to `transform`
-- @return the min value found
-- @see max
function _.min(t, transform, ...)
  return extract(t, f_min, transform, ...)
end

--- Returns a shuffled copy of a given collection. If a seed is provided, it will
-- be used to init the pseudo random number generator (using `math.randomseed`).
-- @name shuffle
-- @param t a table
-- @param[opt] seed a seed
-- @return a shuffled copy of the given table
function _.shuffle(t, seed)
  if seed then randomseed(seed) end
  local _shuffled = {}
  _.each(t,function(index,value)
     local randPos = floor(random()*index)+1
    _shuffled[index] = _shuffled[randPos]
    _shuffled[randPos] = value
  end)
  return _shuffled
end

--- Checks if two tables are the same. It compares if both tables features the same values,
-- but not necessarily at the same keys.
-- @name same
-- @param a a table
-- @param b another table
-- @return `true` or `false`
function _.same(a, b)
  return _.all(a, function (i,v) return _.include(b,v) end) 
     and _.all(b, function (i,v) return _.include(a,v) end)
end

--- Sorts a table, in-place. If a comparison function is given, it will be used to sort values.
-- @name sort
-- @param t a table
-- @param[opt] comp a comparison function prototyped as `comp (a, b)`, defaults to <tt><</tt> operator.
-- @return the initial table, sorted.
-- @see sortBy
function _.sort(t, comp)
  t_sort(t, comp)
  return t
end

--- Sorts a table in-place using a transform. Values are ranked in a custom order of the results of
-- running `transform (v)` on all values. `transform` may also be a string name property  sort by. 
-- `comp` is a comparison function.
-- @name sortBy
-- @param t a table
-- @param[opt] transform a `transform` function to sort elements prototyped as `transform (v)`. Defaults to @{identity}
-- @param[optchain] comp a comparision function, defaults to the `<` operator
-- @return a new array of sorted values
-- @see sort
function _.sortBy(t, transform, comp)
	local f = transform or _.identity
	if _.isString(transform) then
		f = function(t) return t[transform] end
	end
	comp = comp or f_min	
	local _t = {}
	_.each(t, function(__,v)
		_t[#_t+1] = {value = v, transform = f(v)}
	end)
	t_sort(_t, function(a,b) return comp(a.transform, b.transform) end)
	return _.pluck(_t, 'value')
end

--- Splits a table into subsets groups.
-- @name groupBy
-- @param t a table
-- @param iter an iterator function, prototyped as `iter (k, v, ...)`
-- @param[opt] ... Optional args to be passed to `iter`
-- @return a table of subsets groups
function _.groupBy(t, iter, ...)
  local vararg = {...}
  local _t = {}
  _.each(t, function(i,v)
      local _key = iter(i,v, unpack(vararg))
      if _t[_key] then _t[_key][#_t[_key]+1] = v
      else _t[_key] = {v}
      end
    end)
  return _t
end

--- Groups values in a collection and counts them.
-- @name countBy
-- @param t a table
-- @param iter an iterator function, prototyped as `iter (k, v, ...)`
-- @param[opt] ... Optional args to be passed to `iter`
-- @return a table of subsets groups names paired with their count
function _.countBy(t, iter, ...)
  local vararg = {...}
  local stats = {}
  _.each(t,function(i,v)
      local key = iter(i,v,unpack(vararg))
      stats[key] = (stats[key] or 0) +1
    end)
  return stats
end

--- Counts the number of values in a collection. If being passed more than one argument
-- it will return the count of all passed-in arguments.
-- @name size
-- @param[opt] ... Optional variable number of arguments
-- @return a count
-- @see count
-- @see countf
function _.size(...)
  local args = {...}
  local arg1 = args[1]
  if _.isTable(arg1) then
    return count(args[1])
  else
    return count(args)
  end
end

--- Checks if all the keys of `other` table exists in table `t`. It does not
-- compares values. The test is not commutative, i.e table `t` may contains keys
-- not existing in `other`.
-- @name containsKeys
-- @param t a table
-- @param other another table
-- @return `true` or `false`
-- @see sameKeys
function _.containsKeys(t, other)
  for key in pairs(other) do
    if not t[key] then return false end
  end
  return true
end

--- Checks if both given tables have the same keys. It does not compares values.
-- @name sameKeys
-- @param tA a table
-- @param tB another table
-- @return `true` or `false`
-- @see containsKeys
function _.sameKeys(tA, tB)
  for key in pairs(tA) do
    if not tB[key] then return false end
  end
  for key in pairs(tB) do
    if not tA[key] then return false end
  end
  return true
end

--- Array functions
-- @section Array functions

--- Samples `n` random values from an array. If `n` is not specified, returns a single element.
-- It uses internally @{shuffle} to shuffle the array before sampling values. If `seed` is passed,
-- it will be used for shuffling.
-- @name sample
-- @param array an array
-- @param[opt] n a number of elements to be sampled. Defaults to 1.
-- @param[optchain] seed an optional seed for shuffling 
-- @return an array of selected values or a single value when `n` == 1
-- @see sampleProb
function _.sample(array, n, seed)
	n = n or 1
	if n < 1 then return end
	if n == 1 then
		if seed then randomseed(seed) end
		return array[random(1, #array)]
	end
	return _.slice(_.shuffle(array, seed), 1, n)
end

--- Return elements from a sequence with a given probability. It considers each value independently. 
-- Providing a seed will result in deterministic sampling. Given the same seed it will return the same sample
-- every time.
-- @name sampleProb
-- @param array an array
-- @param prob a probability for each element in array to be selected
-- @param[opt] seed an optional seed for deterministic sampling
-- @return an array of selected values
-- @see sample
function _.sampleProb(array, prob, seed)
	if seed then randomseed(seed) end
	return _.select(array, function(_,v) return random() < prob end)
end

--- Converts a list of arguments to an array.
-- @name toArray
-- @param ... a list of arguments
-- @return an array of all passed-in args
function _.toArray(...) return {...} end

--- Looks for the first occurrence of a given value in an array. Returns the value index if found.
-- Uses @{isEqual} to compare values.
-- @name find
-- @param array an array of values
-- @param value a value to lookup for
-- @param[opt] from the index from where the search will start. Defaults to 1.
-- @return the index of the value if found in the array, `nil` otherwise.
function _.find(array, value, from)
  for i = from or 1, #array do
    if _.isEqual(array[i], value) then return i end
  end
end

--- Returns an array where values are in reverse order. The passed-in array should not be sparse.
-- @name reverse
-- @param array an array
-- @return a reversed array
function _.reverse(array)
  local _array = {}
  for i = #array,1,-1 do
    _array[#_array+1] = array[i]
  end
  return _array
end

--- Replaces elements in a given array with a given value. In case `i` and `j` are given
-- it will only replaces values at indexes between `[i,j]`. In case `j` is greather than the array
-- size, it will append new values, increasing the array.
-- @name fill
-- @param array an array
-- @param value a value
-- @param[opt] i the index from which to start replacing values. Defaults to 1.
-- @param[optchain] j the index where to stop replacing values. Defaults to the array size.
-- @return the original array with values changed
function _.fill(array, value, i, j)
	j = j or _.size(array)
	for i = i or 1, j do array[i] = value end
	return array
end

--- Collects values from a given array. The passed-in array should not be sparse.
-- This function collects values as long as they satisfy a given predicate and returns on the first falsy test.
-- <br/><em>Aliased as `takeWhile`</em>
-- @name selectWhile
-- @param array an array
-- @param f an iterator function prototyped as `f (k, v, ...)`
-- @param[opt] ... Optional args to be passed to `f`
-- @return a new table containing all values collected
-- @see dropWhile
function _.selectWhile(array, f, ...)
  local t = {}
  for i,v in ipairs(array) do
    if f(i,v,...) then t[i] = v else break end
  end
  return t
end

--- Collects values from a given array. The passed-in array should not be sparse.
-- This function collects values as long as they do not satisfy a given predicate and returns on the first truthy test.
-- <br/><em>Aliased as `rejectWhile`</em>
-- @name dropWhile
-- @param array an array
-- @param f an iterator function prototyped as `f (k,v, ...)`
-- @param[opt] ... Optional args to be passed to `f`
-- @return a new table containing all values collected
-- @selectWhile
function _.dropWhile(array, f, ...)
  local _i
  for i,v in ipairs(array) do
    if not f(i,v,...) then
      _i = i
      break
    end
  end
  if _.isNil(_i) then return {} end
  return _.rest(array,_i)
end

--- Returns the index at which a value should be inserted. This index is evaluated so 
-- that it maintains the sort. If a comparison function is passed, it will be used to sort
-- values.
-- @name sortedIndex
-- @param array an array
-- @param the value to be inserted
-- @param[opt] comp an comparison function prototyped as `f (a, b)`, defaults to <tt><</tt> operator.
-- @param[optchain] sort whether or not the passed-in array should be sorted
-- @return number the index at which the passed-in value should be inserted
function _.sortedIndex(array, value, comp, sort)
  local _comp = comp or f_min
  if sort then _.sort(array,_comp) end
  for i = 1,#array do
    if not _comp(array[i],value) then return i end
  end
  return #array+1
end

--- Returns the index of the first occurence of value in an array.
-- @name indexOf
-- @param array an array
-- @param value the value to search for
-- @return the index of the passed-in value
-- @see lastIndexOf
function _.indexOf(array, value)
  for k = 1,#array do
    if array[k] == value then return k end
  end
end

--- Returns the index of the last occurrence of value in an array.
-- @name lastIndexOf
-- @param array an array
-- @param value the value to search for
-- @return the index of the last occurrence of the passed-in value or __nil__
-- @see indexOf
function _.lastIndexOf(array, value)
  local key = _.indexOf(_.reverse(array),value)
  if key then return #array-key+1 end
end

--- Returns the first index at which a predicate returns true.
-- @name findIndex
-- @param array an array
-- @param predicate a predicate function prototyped as `predicate (k, v, ...)`
-- @param[opt] ... optional arguments to `pred`
-- @return the index found or __nil__
-- @see findLastIndex
function _.findIndex(array, predicate, ...)
	for k = 1, #array do
		if predicate(k,array[k],...) then return k end
	end
end

--- Returns the last index at which a predicate returns true.
-- @name findLastIndex
-- @param array an array
-- @param predicate a predicate function prototyped as `predicate (k, v, ...)`
-- @param[opt] ... optional arguments to `pred`
-- @return the index found or __nil__
-- @see findIndex
function _.findLastIndex(array, predicate, ...)
  local key = _.findIndex(_.reverse(array),predicate,...)
  if key then return #array-key+1 end
end

--- Adds all passed-in values at the top of an array. The last elements will bubble to the
-- top of the given array.
-- @name addTop
-- @param array an array
-- @param ... a variable number of arguments
-- @return the passed-in array with new values added
-- @see push
function _.addTop(array, ...)
  _.each({...},function(i,v) t_insert(array,1,v) end)
  return array
end

--- Pushes all passed-in values at the end of an array.
-- @name push
-- @param array an array
-- @param ... a variable number of arguments
-- @return the passed-in array with new added values
-- @see addTop
function _.push(array, ...)
  _.each({...}, function(i,v) array[#array+1] = v end)
  return array
end

--- Removes and returns the values at the top of a given array.
-- <br/><em>Aliased as `shift`</em>
-- @name pop
-- @param array an array
-- @param[opt] n the number of values to be popped. Defaults to 1.
-- @return the popped values
-- @see unshift
function _.pop(array, n)
  n = min(n or 1, #array)
  local ret = {}
  for i = 1, n do 
    local retValue = array[1]
    ret[#ret + 1] = retValue
    t_remove(array,1)
  end
  return unpack(ret)
end

--- Removes and returns the values at the end of a given array.
-- @name unshift
-- @param array an array
-- @param[opt] n the number of values to be unshifted. Defaults to 1.
-- @return the values
-- @see pop
function _.unshift(array, n)
  n = min(n or 1, #array)
  local ret = {}
  for i = 1, n do
    local retValue = array[#array]
    ret[#ret + 1] = retValue
    t_remove(array)
  end
  return unpack(ret)
end

--- Removes all provided values in a given array.
-- <br/><em>Aliased as `remove`</em>
-- @name pull
-- @param array an array
-- @param ... a variable number of values to be removed from the array
-- @return the passed-in array with values removed
function _.pull(array, ...)
  for __, rmValue in ipairs({...}) do
    for i = #array, 1, -1 do
      if _.isEqual(array[i], rmValue) then
        t_remove(array, i)
      end
    end
  end
  return array
end

--- Removes values at index within the range `[start, finish]`.
-- <br/><em>Aliased as `rmRange`, `chop`</em>
-- @name removeRange
-- @param array an array
-- @param[opt] start the lower bound index, defaults to the first index in the array.
-- @param[optchain] finish the upper bound index, defaults to the array length.
-- @return the passed-in array with values removed
function _.removeRange(array, start, finish)
  local array = _.clone(array)
  local i,n = (next(array)),#array
  if n < 1 then return array end

  start = clamp(start or i,i,n)
  finish = clamp(finish or n,i,n)

  if finish < start then return array end

  local count = finish - start + 1
  local i = start
  while count > 0 do
    t_remove(array,i)
    count = count - 1
  end
  return array
end

--- Chunks together consecutive values. Values are chunked on the basis of the return
-- value of a provided predicate `f (k, v, ...)`. Consecutive elements which return 
-- the same value are chunked together. Leaves the first argument untouched if it is not an array.
-- @name chunk
-- @param array an array
-- @param f an iterator function prototyped as `f (k, v, ...)`
-- @param[opt] ... Optional args to be passed to `f`
-- @return a table of chunks (arrays)
-- @see zip
function _.chunk(array, f, ...)
  if not _.isArray(array) then return array end
  local ch, ck, prev = {}, 0
  local mask = _.map(array, f,...)
  _.each(mask, function(k,v)
    prev = (prev==nil) and v or prev
    ck = ((v~=prev) and (ck+1) or ck)
    if not ch[ck] then
      ch[ck] = {array[k]}
    else
      ch[ck][#ch[ck]+1] = array[k]
    end
    prev = v
  end)
  return ch
end

--- Slices values indexed within `[start, finish]` range.
-- <br/><em>Aliased as `_.sub`</em>
-- @name slice
-- @param array an array
-- @param[opt] start the lower bound index, defaults to the first index in the array.
-- @param[optchain] finish the upper bound index, defaults to the array length.
-- @return a new array of sliced values
function _.slice(array, start, finish)
  return _.select(array, function(index)
      return (index >= (start or next(array)) and index <= (finish or #array))
    end)
end

--- Returns the first N values in an array.
-- <br/><em>Aliased as `head`, `take`</em>
-- @name first
-- @param array an array
-- @param[opt] n the number of values to be collected, defaults to 1.
-- @return a new array
-- @see initial
-- @see last
-- @see rest
function _.first(array, n)
  local n = n or 1
  return _.slice(array,1, min(n,#array))
end

--- Returns all values in an array excluding the last N values.
-- @name initial
-- @param array an array
-- @param[opt] n the number of values to be left, defaults to the array length.
-- @return a new array
-- @see first
-- @see last
-- @see rest
function _.initial(array, n)
  if n and n < 0 then return end
  return _.slice(array,1, n and #array-(min(n,#array)) or #array-1)
end

--- Returns the last N values in an array.
-- @name last
-- @param array an array
-- @param[opt] n the number of values to be collected, defaults to the array length.
-- @return a new array
-- @see first
-- @see initial
-- @see rest
function _.last(array, n)
  if n and n <= 0 then return end
  return _.slice(array,n and #array-min(n-1,#array-1) or 2,#array)
end

--- Removes all values before index.
-- <br/><em>Aliased as `tail`</em>
-- @name rest
-- @param array an array
-- @param[opt] index an index, defaults to 1
-- @return a new array
-- @see first
-- @see initial
-- @see last
function _.rest(array,index)
  if index and index > #array then return {} end
  return _.slice(array,index and max(1,min(index,#array)) or 1,#array)
end

--- Returns the value at a given index.
-- @name nth
-- @param array an array
-- @param index an index
-- @return the value at the given index
function _.nth(array, index)
  return array[index]
end

--- Removes all falsy (false and nil) values.
-- @name compact
-- @param array an array
-- @return a new array
function _.compact(array)
  return _.reject(array, function (_,value)
    return not value
  end)
end

--- Flattens a nested array. Passing `shallow` will only flatten at the first level.
-- @name flatten
-- @param array an array
-- @param[opt] shallow specifies the flattening depth
-- @return a new array, flattened
function _.flatten(array, shallow)
  local shallow = shallow or false
  local new_flattened
  local _flat = {}
  for key,value in pairs(array) do
    if _.isTable(value) then
      new_flattened = shallow and value or _.flatten (value)
      _.each(new_flattened, function(_,item) _flat[#_flat+1] = item end)
    else _flat[#_flat+1] = value
    end
  end
  return _flat
end

--- Returns values from an array not present in all passed-in args.
-- <br/><em>Aliased as `without` and `diff`</em>
-- @name difference
-- @param array an array
-- @param another array
-- @return a new array
-- @see union
-- @see intersection
-- @see symmetricDifference
function _.difference(array, array2)
  if not array2 then return _.clone(array) end
  return _.select(array,function(i,value)
      return not _.include(array2,value)
    end)
end

--- Returns the duplicate-free union of all passed in arrays.
-- @name union
-- @param ... a variable number of arrays arguments
-- @return a new array
-- @see difference
-- @see intersection
-- @see symmetricDifference
function _.union(...)
  return _.uniq(_.flatten({...}))
end

--- Returns the  intersection of all passed-in arrays.
-- Each value in the result is present in each of the passed-in arrays.
-- @name intersection
-- @param array an array
-- @param ... a variable number of array arguments
-- @return a new array
-- @see difference
-- @see union
-- @see symmetricDifference
function _.intersection(array, ...)
  local arg = {...}
  local _intersect = {}
  for i,value in ipairs(array) do
    if _.all(arg,function(i,v)
          return _.include(v,value)
        end) then
      t_insert(_intersect,value)
    end
  end
  return _intersect
end

--- Performs a symmetric difference. Returns values from `array` not present in `array2` and also values
-- from `array2` not present in `array`.
-- <br/><em>Aliased as `symdiff`</em>
-- @name symmetricDifference
-- @param array an array
-- @param array2 another array
-- @return a new array
-- @see difference
-- @see union
-- @see intersection
function _.symmetricDifference(array, array2)
  return _.difference(
    _.union(array, array2),
    _.intersection(array,array2)
  )
end

--- Produces a duplicate-free version of a given array.
-- <br/><em>Aliased as `uniq`</em>
-- @name unique
-- @param array an array
-- @return a new array, duplicate-free
-- @see isunique
function _.unique(array)
  local ret = {}
  for i = 1, #array do
    if not _.find(ret, array[i]) then
      ret[#ret+1] = array[i]
    end
  end
  return ret
end

--- Checks if a given array contains distinct values. Such an array is made of distinct elements,
-- which only occur once in this array.
-- <br/><em>Aliased as `isuniq`</em>
-- @name isunique
-- @param array an array
-- @return `true` if the given array is unique, `false` otherwise.
-- @see unique
function _.isunique(array)
  return _.isEqual(array, _.unique(array))
end

--- Merges values of each of the passed-in arrays in subsets.
-- Only values indexed with the same key in the given arrays are merged in the same subset.
-- <br/><em>Aliased as `transpose`</em>
-- @name zip
-- @param ... a variable number of array arguments
-- @return a new array
function _.zip(...)
  local arg = {...}
  local _len = _.max(_.map(arg,function(i,v)
      return #v
    end))
  local _ans = {}
  for i = 1,_len do
    _ans[i] = _.pluck(arg,i)
  end
  return _ans
end

--- Clones `array` and appends `other` values.
-- @name append
-- @param array an array
-- @param other an array
-- @return a new array
function _.append(array, other)
  local t = {}
  for i,v in ipairs(array) do t[i] = v end
  for i,v in ipairs(other) do t[#t+1] = v end
  return t
end

--- Interleaves arrays. It returns a single array made of values from all
-- passed in arrays in their given order, interleaved.
-- @name interleave
-- @param ... a variable list of arrays
-- @return a new array
-- @see interpose
function _.interleave(...) return _.flatten(_.zip(...)) end

--- Interposes value in-between consecutive pair of values in `array`.
-- @name interpose
-- @param value a value
-- @param array an array
-- @return a new array
-- @see interleave
function _.interpose(value, array)
  return _.flatten(_.zip(array, _.rep(value, #array-1)))
end

--- Produces a flexible list of numbers. If one positive value is passed, will count from 0 to that value,
-- with a default step of 1. If two values are passed, will count from the first one to the second one, with the
-- same default step of 1. A third value passed will be considered a step value.
-- @name range
-- @param[opt] from the initial value of the range
-- @param[optchain] to the final value of the range
-- @param[optchain] step the step of count
-- @return a new array of numbers
function _.range(...)
  local arg = {...}
  local _start,_stop,_step
  if #arg==0 then return {}
  elseif #arg==1 then _stop,_start,_step = arg[1],0,1
  elseif #arg==2 then _start,_stop,_step = arg[1],arg[2],1
  elseif #arg == 3 then _start,_stop,_step = arg[1],arg[2],arg[3]
  end
  if (_step and _step==0) then return {} end
  local _ranged = {}
  local _steps = max(floor((_stop-_start)/_step),0)
  for i=1,_steps do _ranged[#_ranged+1] = _start+_step*i end
  if #_ranged>0 then t_insert(_ranged,1,_start) end
  return _ranged
end

--- Creates an array list of `n` values, repeated.
-- @name rep
-- @param value a value to be repeated
-- @param n the number of repetitions of value.
-- @return a new array of `n` values
function _.rep(value, n)
  local ret = {}
  for i = 1, n do ret[#ret+1] = value end
  return ret
end

--- Iterator returning partitions of an array. It returns arrays of length `n` 
-- made of values from the given array. If the last partition has lower elements than `n` and 
-- `pad` is supplied, it will be adjusted to `n` of elements with `pad` value.
-- @name partition
-- @param array an array
-- @param[opt] n the size of partitions. Should be greater than 0. Defaults to 1.
-- @param[optchain] pad a value to adjust the last subsequence to the `n` elements
-- @return an iterator function
function _.partition(array, n, pad)
	if n<=0 then return end
  return coroutine.wrap(function()
    partgen(array, n or 1, coroutine.yield, pad)
  end)
end

--- Iterator returning sliding partitions of an array. It returns overlapping subsequences
-- of length `n`. If the last subsequence has lower elements than `n` and `pad` is 
-- supplied, it will be adjusted to `n` elements with `pad` value.
-- @name sliding.
-- @param array an array
-- @param[opt] n the size of partitions. Should be greater than 1. Defaults to 2.
-- @param[optchain] pad a value to adjust the last subsequence to the `n` elements
-- @return an iterator function
function _.sliding(array, n, pad)
	if n<=1 then return end
  return coroutine.wrap(function()
    partgen2(array, n or 2, coroutine.yield, pad)
  end)
end

--- Iterator returning the permutations of an array. It returns arrays made of all values
-- from the passed-in array, with values permuted.
-- @name permutation
-- @param array an array
-- @return an iterator function
function _.permutation(array)
  return coroutine.wrap(function() 
    permgen(array, #array, coroutine.yield)
  end)
end

--- Swaps keys with values. Produces a new array where previous keys are now values, 
-- while previous values are now keys.
-- <br/><em>Aliased as `mirror`</em>
-- @name invert
-- @param array a given array
-- @return a new array
function _.invert(array)
  local _ret = {}
  _.each(array,function(i,v) _ret[v] = i end)
  return _ret
end

--- Concatenates values in a given array. Handles booleans as well. If `sep` string is
-- passed, it will be used as a separator. Passing `i` and `j` will result in concatenating
-- only values within `[i, j]` range.
-- <br/><em>Aliased as `join`</em>
-- @name concat
-- @param array a given array
-- @param[opt] sep a separator string, defaults to the empty string `''`.
-- @param[optchain] i the starting index, defaults to 1.
-- @param[optchain] j the final index, defaults to the array length.
-- @return a string
function _.concat(array, sep, i, j)
  local _array = _.map(array,function(i,v)
    return tostring(v)
  end)
  return t_concat(_array,sep,i or 1,j or #array)

end


--- Utility functions
-- @section Utility functions

--- The no-operation function.
-- @name noop
-- @return nothing
function _.noop() return end

--- Returns the passed-in value. This function is used internally
-- as a default iterator.
-- @name identity
-- @param value a value
-- @return the passed-in value
function _.identity(value) return value end

--- Creates a constant function which returns the same output on every call.
-- @name constant
-- @param value a constant value
-- @return a constant function
function _.constant(value) return function() return value end end

--- Returns a version of `f` that runs only once. Successive calls to `f`
-- will keep yielding the same output, no matter what the passed-in arguments are. 
-- It can be used to initialize variables.
-- @name once
-- @param f a function
-- @return a new function
-- @see after
function _.once(f)
  local _internal = 0
  local _args = {}
  return function(...)
      _internal = _internal+1
      if _internal<=1 then _args = {...} end
      return f(unpack(_args))
    end
end

--- Memoizes a given function by caching the computed result.
-- Useful for speeding-up slow-running functions. If a `hash` function is passed,
-- it will be used to compute hash keys for a set of input values for caching.
-- <br/><em>Aliased as `cache`</em>
-- @name memoize
-- @param f a function
-- @param[opt] hash a hash function, defaults to @{identity}
-- @return a new function
function _.memoize(f, hash)
  local _cache = setmetatable({},{__mode = 'kv'})
  local _hasher = hash or _.identity
  return function (...)
      local _hashKey = _hasher(...)
      local _result = _cache[_hashKey]
      if not _result then _cache[_hashKey] = f(...) end
      return _cache[_hashKey]
    end
end

--- Returns a version of `f` that runs on the `count-th` call.
-- Useful when dealing with asynchronous tasks.
-- @name after
-- @param f a function
-- @param count the number of calls before `f` will start running.
-- @return a new function
-- @see once
function _.after(f, count)
  local _limit,_internal = count, 0
  return function(...)
      _internal = _internal+1
      if _internal >= _limit then return f(...) end
    end
end

--- Composes functions. Each passed-in function consumes the return value of the function that follows.
-- In math terms, composing the functions `f`, `g`, and `h` produces the function `f(g(h(...)))`.
-- @name compose
-- @param ... a variable number of functions
-- @return a new function
-- @see pipe
function _.compose(...)
	-- See: https://github.com/Yonaba/Moses/pull/15#issuecomment-139038895
  local f = _.reverse {...}
  return function (...)
		local first, _temp = true
		for i, func in ipairs(f) do
			if first then
				first = false
				_temp = func(...)
			else
				_temp = func(_temp)
			end
		end
		return _temp
	end
end

--- Pipes a value through a series of functions. In math terms, 
-- given some functions `f`, `g`, and `h` in that order, it returns `f(g(h(value)))`.
-- @name pipe
-- @param value a value
-- @param ... a variable number of functions
-- @return the result of the composition of function calls.
-- @see compose
function _.pipe(value, ...)
  return _.compose(...)(value)
end

--- Returns the logical complement of a given function. For a given input, the returned 
-- function will output `false` if the original function would have returned `true`, 
-- and vice-versa.
-- @name complement
-- @param f a function
-- @return  the logical complement of the given function `f`.
function _.complement(f)
  return function(...) return not f(...) end
end

--- Calls a sequence of passed-in functions with the same argument.
-- Returns a sequence of results. 
-- <br/><em>Aliased as `juxt`</em>
-- @name juxtapose
-- @param value a value
-- @param ... a variable number of functions
-- @return a list of results
function _.juxtapose(value, ...)
  local res = {}
  _.each({...}, function(_,f) res[#res+1] = f(value) end)
  return unpack(res)
end

--- Wraps `f` inside of the `wrapper` function. It passes `f` as the first argument to `wrapper`.
-- This allows the wrapper to execute code before and after `f` runs,
-- adjust the arguments, and execute it conditionally.
-- @name wrap
-- @param f a function to be wrapped, prototyped as `f (...)`
-- @param wrapper a wrapper function, prototyped as `wrapper (f, ...)`
-- @return the results
function _.wrap(f, wrapper)
  return function (...) return  wrapper(f,...) end
end

--- Runs `iter` function `n` times. Collects the results of each run and returns them in an array.
-- @name times
-- @param n the number of times `iter` should be called
-- @param  iter an iterator function, prototyped as `iter (i, ...)`
-- @param ... args to be passed to `iter` function
-- @return table an array of results
function _.times(n, iter, ...)
  local results = {}
  for i = 1,n do
    results[i] = iter(i,...)
  end
  return results
end

--- Binds `v` to be the first argument to `f`. Calling `f (...)` will result to `f (v, ...)`.
-- @name bind
-- @param f a function
-- @param v a value
-- @return a function
-- @see bind2
-- @see bindn
-- @see bindAll
function _.bind(f, v)
  return function (...)
      return f(v,...)
    end
end

--- Binds `v` to be the second argument to `f`. Calling `f (a, ...)` will result to `f (a, v, ...)`.
-- @name bind2
-- @param f a function
-- @param v a value
-- @return a function
-- @see bind
-- @see bindn
-- @see bindAll
function _.bind2(f, v)
  return function (t, ...)
    return f(t, v, ...)
  end
end

--- Binds `...` to be the N-first arguments to function `f`. 
-- Calling `f (a1, a2, ..., aN)` will result to `f (..., a1, a2, ...,aN)`.
-- @name bindn
-- @param f a function
-- @param ... a variable number of arguments
-- @return a function
-- @see bind
-- @see bind2
-- @see bindAll
function _.bindn(f, ...)
  local iArg = {...}
  return function (...)
      return f(unpack(_.append(iArg,{...})))
    end
end

--- Binds methods to object. As such, whenever any of these methods is invoked, it 
-- always receives the object as its first argument.
-- @name bindAll
-- @param obj an abject
-- @param ... a variable number of method names
-- @return the passed-in object with all methods bound to the object itself.
-- @see bind
-- @see bind2
-- @see bindn
function _.bindAll(obj, ...)
	local methodNames = {...}
	for __, methodName in ipairs(methodNames) do
		local method = obj[methodName]
		if method then obj[methodName] = _.bind(method, obj) end
	end
	return obj
end

--- Generates an unique ID for the current session. If given a string `template`, it
-- will use this template for output formatting. Otherwise, if `template` is a function, it
-- will evaluate `template (id, ...)`.
-- <br/><em>Aliased as `uid`</em>.
-- @name uniqueId
-- @param[opt] template either a string or a function template to format the ID
-- @param[optchain] ... a variable number of arguments to be passed to `template`, in case it is a function.
-- @return value an ID
function _.uniqueId(template, ...)
  unique_id_counter = unique_id_counter + 1
  if template then
    if _.isString(template) then
      return template:format(unique_id_counter)
    elseif _.isFunction(template) then
      return template(unique_id_counter,...)
    end
  end
  return unique_id_counter
end

--- Produces an iterator which repeatedly apply a function `f` onto an input. 
-- Yields x, then f(x), then f(f(x)), continuously.
-- @name iterate
-- @param f a function 
-- @param x an initial input to `f`
-- @return an iterator fnction
-- <br/><em>Aliased as `iter`</em>.
function _.iterator(f, x)
	return function()
		x = f(x)
		return x
	end
end

--- Creates a function of `f` with arguments flipped in reverse order.
-- @name flip
-- @param f a function 
-- @return a function
function _.flip(f)
	return function(...)
		return f(unpack(_.reverse({...})))
	end
end

--- Creates a function that runs transforms on all arguments it receives.
-- @name over
-- @param ... a set of functions which will receive all arguments to the returned function
-- @return a function
-- @see overEvery
-- @see overSome
-- @see overArgs
function _.over(...)
	local transforms = {...}
	return function(...)
		local r = {}
		for __,transform in ipairs(transforms) do
			r[#r+1] = transform(...)
		end
		return r
	end
end

--- Creates a validation function. The returned function checks if *all* of the given predicates return 
-- truthy when invoked with the arguments it receives.
-- @name overEvery
-- @param ... a list of predicate functions
-- @return a new function
-- @see over
-- @see overSome
-- @see overArgs
function _.overEvery(...)
	local f = _.over(...)
	return function(...)
		return _.reduce(f(...),function(state,v) return state and v end)
	end
end

--- Creates a validation function. The return function checks if *any* of a given predicates return 
-- truthy when invoked with the arguments it receives.
-- @name overSome
-- @param ... a list of predicate functions
-- @return a new function
-- @see over
-- @see overEvery
-- @see overArgs
function _.overSome(...)
	local f = _.over(...)
	return function(...)
		return _.reduce(f(...),function(state,v) return state or v end)
	end
end

--- Creates a function that invokes `f` with its arguments transformed. 1rst arguments will be passed to 
-- the 1rst transform, 2nd arg to the 2nd transform, etc. Remaining arguments will not be transformed.
-- @name overArgs
-- @param f a function
-- @param ... a list of transforms funcs prototyped as `f (v)`
-- @return the result of running `f` with its transformed arguments
-- @see over
-- @see overEvery
-- @see overSome
function _.overArgs(f,...)
	local _argf = {...}
	return function(...)
		local _args = {...}
		for i = 1,#_argf do
			local f = _argf[i]
			if _args[i] then _args[i] = f(_args[i]) end
		end
		return f(unpack(_args))
	end
end

--- Partially apply a function by filling in any number of its arguments. 
-- One may pass a string `'_'` as a placeholder in the list of arguments to specify an argument 
-- that should not be pre-filled, but left open to be supplied at call-time. 
-- @name partial
-- @param f a function
-- @param ... a list of partial arguments to `f`
-- @return a new version of function f having some of it original arguments filled
-- @see partialRight
-- @see curry
function _.partial(f,...)
	local partial_args = {...}
	return function (...)
		local n_args = {...}	
		local f_args = {}
		for k,v in ipairs(partial_args) do
			f_args[k] = (v == '_') and _.pop(n_args) or v
		end
		return f(unpack(_.append(f_args,n_args)))
	end
end

--- Similar to @{partial}, but from the right.
-- @name partialRight
-- @param f a function
-- @param ... a list of partial arguments to `f`
-- @return a new version of function f having some of it original arguments filled
-- @see partialRight
-- @see curry
function _.partialRight(f,...)
	local partial_args = {...}
	return function (...)
		local n_args = {...}	
		local f_args = {}
		for k = 1,#partial_args do
			f_args[k] = (partial_args[k] == '_') and _.pop(n_args) or partial_args[k]
		end
		return f(unpack(_.append(n_args, f_args)))
	end
end

--- Curries a function. If the given function `f` takes multiple arguments, it returns another version of 
-- `f` that takes a single argument (the first of the arguments to the original function) and returns a new 
-- function that takes the remainder of the arguments and returns the result. 
-- @name curry
-- @param f a function
-- @param[opt] n_args the number of arguments expected for `f`. Defaults to 2.
-- @return a curried version of `f`
-- @see partial
-- @see partialRight
function _.curry(f, n_args)
	n_args = n_args or 2
	local _args = {}
	local function scurry(v)
		if n_args == 1 then return f(v) end
		if v ~= nil then _args[#_args+1] = v end
		if #_args < n_args then
			return scurry
		else
			local r = {f(unpack(_args))}
			_args = {}
			return unpack(r)
		end
	end
	return scurry
end

--- Object functions
--@section Object functions

--- Returns the keys of the object properties.
-- @name keys
-- @param obj an object
-- @return an array
function _.keys(obj)
  local _oKeys = {}
  _.each(obj,function(key) _oKeys[#_oKeys+1]=key end)
  return _oKeys
end

--- Returns the values of the object properties.
-- @name values
-- @param obj an object
-- @return an array
function _.values(obj)
  local _oValues = {}
  _.each(obj,function(_,value) _oValues[#_oValues+1]=value end)
  return _oValues
end

--- Converts keys and values a an array-list of [k, v].
-- @name kvpairs
-- @param obj an object
-- @return an array list of key-values pairs
-- @see toObj
function _.kvpairs(obj)
	local t = {}
	_.each(obj, function(k,v) t[#t+1] = {k,v} end)
	return t
end

--- Converts an array list of `kvpairs` to an object. Keys are taken
-- from the 1rst column in the `kvpairs` sequence, associated with values in the 2nd
-- column
-- @name toObj
-- @param kvpairs an array-list of `kvpairs`
-- @return an object
-- @see kvpairs
function _.toObj(kvpairs)
	local obj = {}
	for __, v in ipairs(kvpairs) do
		obj[v[1]] = v[2]
	end
	return obj
end

--- Returns a function that will return the key property of any passed-in object.
-- @name property
-- @param key a key property name
-- @return a function which should accept an object as argument
-- @see propertyOf
function _.property(key)
	return function(obj) return obj[key] end
end

--- Returns a function which will return the value of an object property. 
-- @name propertyOf
-- @param obj an object
-- @return a function which should accept a key property argument
-- @see property
function _.propertyOf(obj)
	return function(key) return obj[key] end
end

--- Converts any given value to a boolean
-- @name toBoolean
-- @param value a value. Can be of any type
-- @return `true` if value is true, `false` otherwise (false or nil).
function _.toBoolean(value)
  return not not value
end

--- Extends an object properties. It copies the properties of extra passed-in objects
-- into the destination object, and returns the destination object. The last objects
-- will override properties of the same name.
-- @name extend
-- @param destObj a destination object
-- @param ... a list of objects
-- @return the destination object extended
function _.extend(destObj, ...)
  local sources = {...}
  _.each(sources,function(__,source)
    if _.isTable(source) then
      _.each(source,function(key,value)
        destObj[key] = value
      end)
    end
  end)
  return destObj
end

--- Returns a sorted list of all methods names found in an object. If the given object
-- has a metatable implementing an `__index` field pointing to another table, will also recurse on this
-- table if `recurseMt` is provided. If `obj` is omitted, it defaults to the library functions.
-- <br/><em>Aliased as `methods`</em>.
-- @name functions
-- @param[opt] obj an object. Defaults to Moses library functions.
-- @return an array-list of methods names
function _.functions(obj, recurseMt)
  obj = obj or _
  local _methods = {}
  _.each(obj,function(key,value)
    if _.isFunction(value) then
      _methods[#_methods+1]=key
    end
  end)
  if not recurseMt then 
    return _.sort(_methods)
  end
  local mt = getmetatable(obj)
  if mt and mt.__index then
    local mt_methods = _.functions(mt.__index)
    _.each(mt_methods, function(k,fn)
      _methods[#_methods+1] = fn
    end)
  end
  return _.sort(_methods)
end

--- Clones a given object properties. If `shallow` is passed will also clone nested array properties.
-- @name clone
-- @param obj an object
-- @param[opt] shallow whether or not nested array-properties should be cloned, defaults to false.
-- @return a copy of the passed-in object
function _.clone(obj, shallow)
  if not _.isTable(obj) then return obj end
  local _obj = {}
  _.each(obj,function(i,v)
    if _.isTable(v) then
      if not shallow then
        _obj[i] = _.clone(v,shallow)
      else _obj[i] = v
      end
    else
      _obj[i] = v
    end
  end)
  return _obj
end

--- Invokes interceptor with the object, and then returns object.
-- The primary purpose of this method is to "tap into" a method chain, in order to perform operations 
-- on intermediate results within the chain.
-- @name tap
-- @param obj an object
-- @param f an interceptor function, should be prototyped as `f (obj, ...)`
-- @param[opt] ... args to be passed to `f`
-- @return the passed-in object
function _.tap(obj, f, ...)
  f(obj,...)
  return obj
end

--- Checks if a given object implements a property.
-- @name has
-- @param obj an object
-- @param key a key property to be checked
-- @return `true` or `false`
function _.has(obj, key)
  return obj[key]~=nil
end

--- Returns an object copy having white-listed properties.
-- <br/><em>Aliased as `choose`</em>.
-- @name pick
-- @param obj an object
-- @param ... a variable number of string keys
-- @return the filtered object
function _.pick(obj, ...)
  local whitelist = _.flatten {...}
  local _picked = {}
  _.each(whitelist,function(key,property)
      if not _.isNil(obj[property]) then
        _picked[property] = obj[property]
      end
    end)
  return _picked
end

--- Returns an object copy without black-listed properties.
-- <br/><em>Aliased as `drop`</em>.
-- @name omit
-- @param obj an object
-- @param ... a variable number of string keys
-- @return the filtered object
function _.omit(obj, ...)
  local blacklist = _.flatten {...}
  local _picked = {}
  _.each(obj,function(key,value)
      if not _.include(blacklist,key) then
        _picked[key] = value
      end
    end)
  return _picked
end

--- Applies a template to an object, preserving non-nil properties.
-- <br/><em>Aliased as `defaults`</em>.
-- @name template
-- @param obj an object
-- @param[opt] template a template object. Defaults to an empty table `{}`.
-- @return the passed-in object filled
function _.template(obj, template)
  _.each(template or {},function(i,v)
  if not obj[i] then obj[i] = v end
  end)
  return obj
end

--- Performs a deep comparison test between two objects. Can compare strings, functions 
-- (by reference), nil, booleans. Compares tables by reference or by values. If `useMt` 
-- is passed, the equality operator `==` will be used if one of the given objects has a 
-- metatable implementing `__eq`.
-- <br/><em>Aliased as `_.compare`</em>
-- @name isEqual
-- @param objA an object
-- @param objB another object
-- @param[opt] useMt whether or not `__eq` should be used, defaults to false.
-- @return `true` or `false`
function _.isEqual(objA, objB, useMt)
  local typeObjA = type(objA)
  local typeObjB = type(objB)

  if typeObjA~=typeObjB then return false end
  if typeObjA~='table' then return (objA==objB) end

  local mtA = getmetatable(objA)
  local mtB = getmetatable(objB)

  if useMt then
    if (mtA or mtB) and (mtA.__eq or mtB.__eq) then
      return mtA.__eq(objA, objB) or mtB.__eq(objB, objA) or (objA==objB)
    end
  end

  if _.size(objA)~=_.size(objB) then return false end

  for i,v1 in pairs(objA) do
    local v2 = objB[i]
    if _.isNil(v2) or not _.isEqual(v1,v2,useMt) then return false end
  end

  for i,v1 in pairs(objB) do
    local v2 = objA[i]
    if _.isNil(v2) then return false end
  end

  return true
end

--- Invokes an object method. It passes the object itself as the first argument. if `method` is not
-- callable, will return `obj[method]`.
-- @name result
-- @param obj an object
-- @param method a string key to index in object `obj`.
-- @param[opt] ... Optional args to be passed to `method`
-- @return the returned value of `method (obj, ...)` call
function _.result(obj, method, ...)
  if obj[method] then
    if _.isCallable(obj[method]) then
      return obj[method](obj,...)
    else return obj[method]
    end
  end
  if _.isCallable(method) then
    return method(obj,...)
  end
end

--- Checks if the given arg is a table.
-- @name isTable
-- @param t a value to be tested
-- @return `true` or `false`
function _.isTable(t)
  return type(t) == 'table'
end

--- Checks if the given argument is callable. Assumes `obj` is callable if
-- it is either a function or a table having a metatable implementing `__call` metamethod.
-- @name isCallable
-- @param obj an object
-- @return `true` or `false`
function _.isCallable(obj)
  return (_.isFunction(obj) or
     (_.isTable(obj) and getmetatable(obj)
                   and getmetatable(obj).__call~=nil) or false)
end

--- Checks if the given argument is an array. Assumes `obj` is an array
-- if is a table with consecutive integer keys starting at 1.
-- @name isArray
-- @param obj an object
-- @return `true` or `false`
function _.isArray(obj)
  if not _.isTable(obj) then return false end
  -- Thanks @Wojak and @Enrique García Cota for suggesting this
  -- See : http://love2d.org/forums/viewtopic.php?f=3&t=77255&start=40#p163624
  local i = 0
  for __ in pairs(obj) do
     i = i + 1
     if _.isNil(obj[i]) then return false end
  end
  return true
end

--- Checks if the given object is iterable with `pairs` (or `ipairs`).
-- @name isIterable
-- @param obj an object
-- @return `true` if the object can be iterated with `pairs` (or `ipairs`), `false` otherwise
function _.isIterable(obj)
  return _.toBoolean((pcall(pairs, obj)))
end

--- Checks if the given pbject is empty. If `obj` is a string, will return `true`
-- if `#obj == 0`. Otherwise, if `obj` is a table, will return whether or not this table
-- is empty. If `obj` is `nil`, it will return true.
-- @name isEmpty
-- @param[opt] obj an object
-- @return `true` or `false`
function _.isEmpty(obj)
  if _.isNil(obj) then return true end
  if _.isString(obj) then return #obj==0 end
  if _.isTable(obj) then return next(obj)==nil end
  return true
end

--- Checks if the given argument is a string.
-- @name isString
-- @param obj an object
-- @return `true` or `false`
function _.isString(obj)
  return type(obj) == 'string'
end

--- Checks if the given argument is a function.
-- @name isFunction
-- @param obj an object
-- @return `true` or `false`
function _.isFunction(obj)
   return type(obj) == 'function'
end

--- Checks if the given argument is nil.
-- @name isNil
-- @param obj an object
-- @return `true` or `false`
function _.isNil(obj)
  return obj==nil
end

--- Checks if the given argument is a number.
-- @name isNumber
-- @param obj an object
-- @return `true` or `false`
-- @see isNaN
function _.isNumber(obj)
  return type(obj) == 'number'
end

--- Checks if the given argument is NaN (see [Not-A-Number](http://en.wikipedia.org/wiki/NaN)).
-- @name isNaN
-- @param obj an object
-- @return `true` or `false`
-- @see isNumber
function _.isNaN(obj)
  return _.isNumber(obj) and obj~=obj
end

--- Checks if the given argument is a finite number.
-- @name isFinite
-- @param obj an object
-- @return `true` or `false`
function _.isFinite(obj)
  if not _.isNumber(obj) then return false end
  return obj > -huge and obj < huge
end

--- Checks if the given argument is a boolean.
-- @name isBoolean
-- @param obj an object
-- @return `true` or `false`
function _.isBoolean(obj)
  return type(obj) == 'boolean'
end

--- Checks if the given argument is an integer.
-- @name isInteger
-- @param obj an object
-- @return `true` or `false`
function _.isInteger(obj)
  return _.isNumber(obj) and floor(obj)==obj
end

-- Aliases

do

  -- Table functions aliases
  _.forEach     = _.each
  _.forEachi    = _.eachi
  _.loop        = _.cycle
  _.collect     = _.map
  _.inject      = _.reduce
  _.foldl       = _.reduce
  _.injectr     = _.reduceRight
  _.foldr       = _.reduceRight
  _.mapr        = _.mapReduce
  _.maprr       = _.mapReduceRight
  _.any         = _.include
  _.some        = _.include
  _.contains    = _.include
  _.filter      = _.select
  _.discard     = _.reject
  _.every       = _.all
  
  -- Array functions aliases
  _.takeWhile   = _.selectWhile
  _.rejectWhile = _.dropWhile
  _.shift       = _.pop
  _.remove      = _.pull
  _.rmRange     = _.removeRange
  _.chop        = _.removeRange
  _.sub         = _.slice
  _.head        = _.first
  _.take        = _.first
  _.tail        = _.rest
  _.skip        = _.last
  _.without     = _.difference
  _.diff        = _.difference
  _.symdiff     = _.symmetricDifference
  _.xor         = _.symmetricDifference
  _.uniq        = _.unique
  _.isuniq      = _.isunique
	_.transpose   = _.zip
  _.part        = _.partition
  _.perm        = _.permutation
  _.mirror      = _.invert
  _.join        = _.concat
  
  -- Utility functions aliases
  _.cache       = _.memoize
  _.juxt        = _.juxtapose
  _.uid         = _.uniqueId
  _.iter        = _.iterator
	
  -- Object functions aliases
  _.methods     = _.functions
  _.choose      = _.pick
  _.drop        = _.omit
  _.defaults    = _.template
  _.compare     = _.isEqual
  
end

-- Setting chaining and building interface

do

  -- Wrapper to Moses
  local f = {}

  -- Will be returned upon requiring, indexes into the wrapper
  local __ = {}
  __.__index = f

  -- Wraps a value into an instance, and returns the wrapped object
  local function new(value)
    local i = {_value = value, _wrapped = true}
    return setmetatable(i, __)
  end

  setmetatable(__,{
    __call  = function(self,v) return new(v) end, -- Calls returns to instantiation
    __index = function(t,key,...) return f[key] end  -- Redirects to the wrapper
  })

  --- Returns a wrapped object. Calling library functions as methods on this object
  -- will continue to return wrapped objects until @{obj:value} is used. Can be aliased as `_(value)`.
  -- @class function
  -- @name chain
  -- @param value a value to be wrapped
  -- @return a wrapped object
  function __.chain(value)
    return new(value)
  end

  --- Extracts the value of a wrapped object. Must be called on an chained object (see @{chain}).
  -- @class function
  -- @name obj:value
  -- @return the value previously wrapped
  function __:value()
    return self._value
  end

  -- Register chaining methods into the wrapper
  f.chain, f.value = __.chain, __.value

  -- Register all functions into the wrapper
  for fname,fct in pairs(_) do
    f[fname] = function(v, ...)
      local wrapped = _.isTable(v) and v._wrapped or false
      if wrapped then
        local _arg = v._value
        local _rslt = fct(_arg,...)
        return new(_rslt)
      else
        return fct(v,...)
      end
    end
  end

  --- Imports all library functions into a context.
  -- @name import
  -- @param[opt] context a context. Defaults to `_G` (global environment) when not given.
  -- @param[optchain] noConflict if supplied, will not import functions having a key existing in the destination context.
  -- @return the passed-in context
  f.import = function(context, noConflict)
    context = context or _ENV or _G
    local funcs = _.functions()
    _.each(funcs, function(k, fname)  
      if rawget(context, fname) then
        if not noConflict then
          context[fname] = _[fname]        
        end
      else
        context[fname] = _[fname]
      end
    end)
    return context
  end

  -- Descriptive tags
  __._VERSION     = 'Moses v'.._MODULEVERSION
  __._URL         = 'http://github.com/Yonaba/Moses'
  __._LICENSE     = 'MIT <http://raw.githubusercontent.com/Yonaba/Moses/master/LICENSE>'
  __._DESCRIPTION = 'utility-belt library for functional programming in Lua'
  
  return __
  
end
