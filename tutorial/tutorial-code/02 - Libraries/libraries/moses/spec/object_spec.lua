require 'luacov'
local _ = require 'moses'

context('Object functions specs', function()

  context('keys', function()
  
    test('collects a given object attributes',function()
      assert_true(_.isEqual(_.keys({1,2,3}),{1,2,3}))
      assert_true(_.isEqual(_.keys({4,5,6}),{1,2,3}))
      assert_true(_.same(_.keys({x = 1, y = 2, 3}),{'x','y',1}))
    end)
    
  end)
  
  context('values', function()
  
    test('collects an given object values',function()
      assert_true(_.isEqual(_.values({1,2,3}),{1,2,3}))
      assert_true(_.isEqual(_.values({4,5,6}),{4,5,6}))
      assert_true(_.same(_.values({x = 1, y = 2, 3}),{1,2,3}))
    end)
   
  end)  
	
  context('kvpairs', function()
  
    test('converts key-values pairs in object to array-list of k,v pairs',function()
			local obj = _.kvpairs({x = 1, y = 2, z = 3})
			table.sort(obj, function(a,b) return a[1] < b[1] end)
			assert_true(_.isEqual(obj[1],{'x',1}))
			assert_true(_.isEqual(obj[2],{'y',2}))
			assert_true(_.isEqual(obj[3],{'z',3}))
    end)
   
  end)  	
	
  context('toObj', function()
  
    test('converts an array-list of {k,v} pairs to an object',function()
			local obj = _.toObj({{'x',1},{'y',2},{'z',3}})
			assert_equal(obj.x,1)
			assert_equal(obj.y,2)
			assert_equal(obj.z,3)
    end)
   
  end)  	
  
  context('property', function()
  
    test('Returns a function that will return the key property of any passed-in object.',function()
			assert_equal(_.property('sin')(math), math.sin)
			assert_equal(_.property('find')(string), string.find)
			assert_equal(_.property('insert')(table), table.insert)
			assert_equal(_.property('yield')(coroutine), coroutine.yield)
    end)
   
  end)  	
  
  context('propertyOf', function()
  
    test('Returns a function which will return the value of an object property.',function()
			assert_equal(_.propertyOf(math)('cos'), math.cos)
			assert_equal(_.propertyOf(string)('char'), string.char)
			assert_equal(_.propertyOf(table)('remove'), table.remove)	
			assert_equal(_.propertyOf(_)('propertyOf'), _.propertyOf)	
    end)
   
  end)  	
  
	
  context('toBoolean', function()
  
    test('converts a value to a boolean',function()
      assert_true(type(_.toBoolean(true)) == 'boolean')
      assert_true(type(_.toBoolean(1)) == 'boolean')
      assert_true(type(_.toBoolean(false)) == 'boolean')
      assert_true(type(_.toBoolean(nil)) == 'boolean')
      assert_true(type(_.toBoolean({})) == 'boolean')
      assert_true(type(_.toBoolean(1/0)) == 'boolean')
      
      assert_true(_.toBoolean(true))
      assert_true(_.toBoolean(1))
      assert_false(_.toBoolean(false))
      assert_false(_.toBoolean(nil))
      assert_true(_.toBoolean({}))
      assert_true(_.toBoolean(1/0))      
    end)
  
  end)  
  
  context('extend', function()
  
    test('extends a destination objects with key-values a source object',function()
      assert_true(_.isEqual(_.extend({},{a = 'b'}),{a = 'b'}))
    end)
    
    test('source properties overrides destination properties',function()
      assert_true(_.isEqual(_.extend({a = 'a'},{a = 'b'}),{a = 'b'}))
    end)   

    test('leaves source object untouched',function()
      local source = {i = 'i'}
      assert_true(_.isEqual(_.extend({a = 'a'},source),{a = 'a',i = 'i'}))
      assert_true(_.isEqual(source,{i = 'i'}))
    end)

    test('can extend destination from multiple sources',function()
      local sourceA = {a = 'a'}; local sourceBC = {b = 'b', c = 'c'} 
      assert_true(_.isEqual(_.extend({},sourceA, sourceBC),{a = 'a', b = 'b', c = 'c'}))
    end) 

    test('extending from multiple source, latter properties overrides',function()
      local sourceA = {a = 'a'}; local sourceBC = {b = 'b', a = 'c'} 
      assert_true(_.isEqual(_.extend({},sourceA, sourceBC),{a = 'c', b = 'b'}))
    end)     
    
    test('will not copy nil values',function()
      local sourceA = {a = nil}; local sourceBC = {b = 'b', c = nil} 
      assert_true(_.isEqual(_.extend({},sourceA, sourceBC),{b = 'b'}))
    end)    
  end)
  
  context('functions', function()

    test('collects function names within an object',function()
      local x = {}
      function x.a() return end; function x.b() return end    
      assert_true(_.isEqual(_.functions(x),{'a','b'}))
    end)
    
    test('collects metatable functions if "recurseMt" arg is supplied',function()
      local x = {} ; x.__index = x
      function x.a() return end; function x.b() return end
      local xx = setmetatable({},x)
      function xx.c() return end
      assert_true(_.same(_.functions(xx),{'c'}))
      assert_true(_.same(_.functions(xx,true),{'a','b','c'}))
    end)

    test('when given no obj as argument, returns all library functions',function()
      local functions = _.functions()
      _.each(functions, function(k,v)
        assert_true(_.isFunction(_[v]))
      end)
    end)
    
  end)  
  
  context('clone', function()
  
    test('clones the attributes of an object',function()
      local vector = {x = 0, y = 0}
      assert_true(_.isEqual(_.clone(vector),vector))
    end)
    
    test('By default, cloning is deep (clones nested tables)',function()
      local particle = {position = {x = 0,y=0},mass = 1}
      local particle_clone = _.clone (particle)
      assert_true(_.isEqual(particle_clone,particle))
      particle_clone.position.x = 3
      assert_false(_.isEqual(particle_clone,particle))
    end)
 
    test('Unless "shallow" arg is provided',function()
      local particle = {position = {x = 0,y=0},mass = 1}
      local particle_clone = _.clone (particle,true)
      assert_true(_.isEqual(particle_clone,particle))
      particle_clone.position.x = 3
      assert_true(_.isEqual(particle_clone,particle))
    end) 
    
    test('Non objects are simply returned',function()
      assert_equal(_.clone(1),1)
      assert_equal(_.clone(false),false)
      assert_equal(_.clone(true),true)
      assert_equal(_.clone(nil),nil)
      assert_equal(_.clone('hello'),'hello')
      assert_equal(_.clone(print),print)
    end)     
    
  end)
  
  context('tap', function()
    
    test('tap-into a method chain', function()
      local t = {}
      local catchMax = function(k) t[#t+1] = _.max(k) end
      local catchMin = function(k) t[#t+1] = _.min(k) end
      
      _.chain({1,2,3})
        :map(function(i,j) return j*2 end)
        :tap(catchMax)
        :map(function(i,k) return k^2 end)
        :tap(catchMin)
        :value()
        
      assert_equal(t[1],6)
      assert_equal(t[2],4)
    end)
  
  end)

  context('has', function()
  
    test('checks if an object has an attribute',function()
      assert_true(_.has(_,'has'))
      assert_true(_.has(table,'concat'))
      assert_true(_.has(string,'format'))
      assert_true(_.has(os,'time'))
      assert_true(_.has(math,'random'))
    end)
    
  end) 
  
  context('pick', function()
  
    test('collect specified properties',function()
      local object = {a = 1, b = 2, c = 3}
      assert_true(_.isEqual(_.pick(object,'a','c'),{a = 1, c = 3}))
    end)
    
    test('given args can be nested as well',function()
      local object = {a = 1, b = 2, c = 3}
      assert_true(_.isEqual(_.pick(object,{{'b','a'}},'c'),{a = 1,b = 2, c = 3}))
    end)

    test('will ignore properties the object do not have',function()
      local object = {a = 1, b = 2, c = 3}
      assert_true(_.isEqual(_.pick(object,{{'k'}},'c'),{c = 3}))
    end) 

    test('returns an empty table when given no properties to pick',function()
      local object = {a = 1, b = 2, c = 3}
      assert_true(_.isEqual(_.pick(object),{}))
    end)  

    test('should also pick attributes having falsy values',function()
      local object = {a = false, b = false, c = true}
      assert_true(_.isEqual(_.pick(object,'a','b'),{a = false,b = false}))
    end)  
    
  end)  
  
  context('omit', function()
  
    test('collect all properties leaving those given as args',function()
      local object = {a = 1, b = 2, c = 3}
      assert_true(_.isEqual(_.omit(object,'a','c'),{b=2}))
    end)
    
    test('given args can be nested as well',function()
      local object = {a = 1, b = 2, c = 3}
      assert_true(_.isEqual(_.omit(object,{{'b'}},'c'),{a = 1}))
    end)

    test('will ignore properties the object do not have',function()
      local object = {a = 1, b = 2, c = 3}
      assert_true(_.isEqual(_.omit(object,{{'k'}},'c'),{a = 1, b=2}))
    end) 

    test('returns the original object clone when given no properties to omit',function()
      local object = {a = 1, b = 2, c = 3}
      assert_true(_.isEqual(_.omit(object),{a = 1, b = 2, c = 3}))
    end)
    
  end)
  
  context('template', function()
  
    test('applies a template on an object',function()
      assert_true(_.isEqual(_.template({},{a = 1, b = 2, c = 3}),{a = 1, b = 2, c = 3}))
    end)
    
    test('does not override existing properies',function()
      assert_true(_.isEqual(_.template({a = 10, b = 10},{a = 1, b = 2, c = 3}),{a = 10, b = 10, c = 3}))
    end)

    test('returns the object when given no template arg',function()
      assert_true(_.isEqual(_.template({a = 10, b = 10}),{a = 10, b = 10}))
    end)
    
  end) 

  context('isEqual', function()
  
    test('compares values',function()
      assert_true(_.isEqual(1,1))
      assert_true(_.isEqual(1.0,1))
      assert_false(_.isEqual(1,2))
      assert_false(_.isEqual(2,2.0001))
    end)
    
    test('compares objects by reference and components',function()
      local oldprint = print
      assert_true(_.isEqual(print,oldprint))
      
      local t = {}
      local v = t
      assert_true(_.isEqual(t,v))
      assert_true(_.isEqual({},{}))
      
      assert_false(_.isEqual('a','b'))
      
      assert_false(_.isEqual(true, false))
      assert_false(_.isEqual(nil, false))
      assert_false(_.isEqual(true, nil))       
    
    end)

    test('compares nested properties',function()
      assert_true(_.isEqual({x = 0,{x1 = 0,{x2 =0}}}, {x = 0,{x1 = 0,{x2 =0}}}))
      assert_false(_.isEqual({x = 0,{x1 = 0,{x2 =0}}}, {x = 0,{x1 = 0,{x2 =1}}}))
    end)

    test('can compare tables on the basis of their metatable',function()
      local a, b = {x = 1, y = 2}, {x = 2, y = 1}
      setmetatable(a,{__eq = function(a,b) return (a.x and b.x and a.y and b.y)~=nil end})
      assert_false(_.isEqual(a, b))
      assert_true(_.isEqual(a, b, true))
    end)
  
    
  end)

  context('result', function()
  
    test('calls an object method, passing it as a first arg the object itself',function()
     assert_equal(_.result('a','len'),1)
     assert_equal(_.result('hello','reverse'),'olleh')
     assert_equal(_.result({'a','b','c'},table.concat),'abc')
    end)
    
    test('handles extra-args to be passed to the so-called method',function()
     assert_equal(_.result('Hello','match','%u'),'H')
     assert_equal(_.result({'a','b','c'},table.concat,' '),'a b c')
    end)    
    
    test('returns the property itself if not callable',function()
     assert_equal(_.result({size = 0},'size'),0)
    end)
     
  end)

  context('isTable', function()
  
    test('returns "true" if arg is table or array',function()
      assert_true(_.isTable({}))
      assert_true(_.isTable({1,2}))
      assert_true(_.isTable({x = 1, 2}))
      assert_true(_.isTable(string))
      assert_true(_.isTable(table))
      assert_true(_.isTable(math))
      
    end)
    
    test('returns "false" otherwise',function()
      assert_false(_.isTable(1))
      assert_false(_.isTable(''))
      assert_false(_.isTable(function() end))
      assert_false(_.isTable(print))
      assert_false(_.isTable(false))
      assert_false(_.isTable(nil))
      assert_false(_.isTable(true))      
    end)
    
  end) 

  context('isCallable', function()
  
    test('returns "true" if arg is callable',function()
      assert_true(_.isCallable(print))
      assert_true(_.isCallable(function() end))
      assert_true(_.isCallable(string.gmatch))
      assert_true(_.isCallable(setmetatable({},{__index = string}).upper))      
      assert_true(_.isCallable(setmetatable({},{__call = function() return end})))      
    end)
    
    test('returns "false" otherwise',function()
      assert_false(_.isCallable(1))
      assert_false(_.isCallable(''))
      assert_false(_.isCallable({}))
      assert_false(_.isCallable(false))
      assert_false(_.isCallable(nil))
      assert_false(_.isCallable(true))      
    end)
    
  end) 

  context('isArray', function()
  
    test('returns "true" if arg is an array',function()
      assert_true(_.isArray({}))
      assert_true(_.isArray({1,2,3}))
      assert_true(_.isArray({'a','b','c',{}}))
      assert_true(_.isArray({false,true}))
      assert_true(_.isArray({1,nil}))
    end)
   
    test('returns "false" otherwise',function()
      assert_false(_.isArray(1))
      assert_false(_.isArray(''))
      assert_false(_.isArray(false))
      assert_false(_.isArray(nil))
      assert_false(_.isArray(true))      
      assert_false(_.isArray(print))
      assert_false(_.isArray({a = 1, x = 1}))
      assert_false(_.isArray({a = 1, 1, 2,3}))
      assert_false(_.isArray({1,nil,2}))
      assert_false(_.isArray({1,nil,3,k=4}))
      assert_false(_.isArray({a=1}))
    end)   
   
    test('returns false on "sparse arrays"',function()
      assert_false(_.isArray({[1] = true, [10] = false}))
   end)   
  
  end)
  
  context('isIterable', function()
  
    test('checks if the given object is iterable with pairs',function()
      assert_true(_.isIterable({}))
      assert_false(_.isIterable(function() end))
      assert_false(_.isIterable(false))
      assert_false(_.isIterable(1))
    end)
    
  end)  
     
  context('isEmpty', function()
  
    test('returns "true" if arg is an empty array',function()
      assert_true(_.isEmpty({}))      
    end)
    
    test('returns "false" otherwise',function()
      assert_false(_.isEmpty({1,2,3}))
      assert_false(_.isEmpty({'a','b','c',{}}))
      assert_false(_.isEmpty({nil,false,true}))
    end)

    test('booleans, nil and functions are considered empty',function()
      assert_true(_.isEmpty(print))
      assert_true(_.isEmpty(nil))
      assert_true(_.isEmpty(false))
      assert_true(_.isEmpty(true))
    end)
    
    test('handles strings',function()
      assert_true(_.isEmpty(''))
      assert_false(_.isEmpty('a'))
      assert_false(_.isEmpty('bcd'))
      assert_false(_.isEmpty(' '))
    end)  
    
  end) 

  context('isString', function()
  
    test('returns "true" if arg is a string',function()
      assert_true(_.isString(''))
      assert_true(_.isString('a'))
      assert_true(_.isString(' '))
      assert_true(_.isString(type(nil)))
    end)
    
    test('returns "false" otherwise',function()
      assert_false(_.isString(false))
      assert_false(_.isString(print))
      assert_false(_.isString(nil))
      assert_false(_.isString(true))
      assert_false(_.isString({}))
    end)
    
  end)

  context('isFunction', function()
  
    test('returns "true" if arg is a function',function()
      assert_true(_.isFunction(print))
      assert_true(_.isFunction(string.match))
      assert_true(_.isFunction(function() end))
    end)

    test('returns "false" otherwise',function()
      assert_false(_.isFunction({}))
      assert_false(_.isFunction(nil))
      assert_false(_.isFunction(false))
      assert_false(_.isFunction(true))
      assert_false(_.isFunction('a'))
    end)    
    
  end)
  
  context('isNil', function()
  
    test('returns "true" if arg is nil',function()
      assert_true(_.isNil(nil))
      assert_true(_.isNil())
      assert_true(_.isNil(a))
    end)
    
    test('returns "false" otherwise',function()
      assert_false(_.isNil(false))
      assert_false(_.isNil(true))
      assert_false(_.isNil(table))
      assert_false(_.isNil(function() end))
      assert_false(_.isNil('a'))
    end)     
    
  end) 

  context('isNumber', function()
  
    test('returns "true" if arg is a number',function()
      assert_true(_.isNumber(1))
      assert_true(_.isNumber(0.5))
      assert_true(_.isNumber(math.pi))
      assert_true(_.isNumber(1/0))
      assert_true(_.isNumber(math.huge))
      assert_true(_.isNumber(0/0))
    end)
    
    test('returns "false" otherwise',function()
      assert_false(_.isNumber(print))
      assert_false(_.isNumber(nil))
      assert_false(_.isNumber(true))
      assert_false(_.isNumber(false))
      assert_false(_.isNumber({1}))
      assert_false(_.isNumber('1'))
    end)    
    
  end)

  context('isNaN', function()
  
    test('returns "true" if arg is NaN',function()
      assert_true(_.isNaN(0/0))  
    end)
    
    test('returns "false" for not NaN values',function()
      assert_false(_.isNaN(1/0))  
      assert_false(_.isNaN(math.huge))
      assert_false(_.isNaN(math.pi))
      assert_false(_.isNaN(1))
      assert_false(_.isNaN(''))
      assert_false(_.isNaN('0'))
      assert_false(_.isNaN({}))
      assert_false(_.isNaN(nil))
      assert_false(_.isNaN(false))
      assert_false(_.isNaN(true))
    end)    
    
  end) 
  
  context('isFinite', function()
  
    test('returns "true" if arg is a finite number',function()
      assert_true(_.isFinite(1))
      assert_true(_.isFinite(0))
      assert_true(_.isFinite(math.pi))
      assert_true(_.isFinite(99e99))
    end)
    
    test('returns "false" otherwise',function()
      assert_false(_.isFinite(math.huge))
      assert_false(_.isFinite(1/0))
      assert_false(_.isFinite(0/0))
    end) 

    test('returns "false" for non-numbers',function()
      assert_false(_.isFinite(''))
      assert_false(_.isFinite(function() end))
      assert_false(_.isFinite({}))
    end)    
    
  end)

  context('isBoolean', function()
 
    test('returns "true" if arg is a boolean or a thruthy statement',function()
      assert_true(_.isBoolean(true))
      assert_true(_.isBoolean(false))
      assert_true(_.isBoolean(1==1))
      assert_true(_.isBoolean(print==tostring))     
    end)
    
    test('returns "false" otherwise',function()
      assert_false(_.isBoolean(''))
      assert_false(_.isBoolean(nil))
      assert_false(_.isBoolean({}))
      assert_false(_.isBoolean(function() end))

      assert_false(_.isBoolean(0))
      assert_false(_.isBoolean('1'))
    end)    
    
  end)
  
  context('isInteger', function()
  
    test('returns "true" if arg is a integer, "false" otherwise',function()
      assert_true(_.isInteger(1))
      assert_true(_.isInteger(0))
      assert_false(_.isInteger(math.pi))
      assert_true(_.isInteger(1/0))
      assert_true(_.isInteger(math.huge))
      assert_false(_.isInteger(0/0))
    end)  
    
  end)
  
end)