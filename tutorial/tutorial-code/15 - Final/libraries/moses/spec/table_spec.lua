require 'luacov'
local _ = require 'moses'

context('Table functions specs', function()

  context('each', function()
  
    test('provides values and iteration count ', function()
      local t = {1,2,3}
      local inc = 0
      _.each(t,function(i,v)
        inc = inc+1
        assert_equal(i,inc)
        assert_equal(t[i],v)
      end)
    end)  
  
    test('can reference the given table', function()
      local t = {1,2,3}
      _.each(t,function(i,v,mul)
        t[i] = v*mul
      end,5)
      assert_true(_.isEqual(t,{5,10,15}))
    end)
    
    test('iterates over non-numeric keys and objects', function()
      local t = {one = 1, two = 2, three = 3}
      local copy = {}
      _.each(t,function(i,v) copy[i] = v end)
      assert_true(_.isEqual(t,copy))
    end)
    
  end)  

  context('eachi', function()
  
    test('provides values and iteration count for integer keys only, in a sorted way', function()
      local t = {1,2,3}
      local inc = 0
      _.eachi(t,function(i,v)
        inc = inc+1
        assert_equal(i,inc)
        assert_equal(t[i],v)
      end)
    end)  

    test('ignores non-integer keys', function()
      local t = {a = 1, b = 2, [0] = 1, [-1] = 6, 3, x = 4, 5}
      local rk = {-1, 0, 1, 2}
      local rv = {6, 1, 3, 5}
      local inc = 0
      _.eachi(t,function(i,v)
        inc = inc+1
        assert_equal(i,rk[inc])
        assert_equal(v,rv[inc])
      end)
    end)  
    
  end)  
 
  context('at', function()
  
    test('returns an array of values at numeric keys', function()
      local t = {4,5,6}
      local values = _.at(t,1,2,3)
      assert_true(_.isEqual(values, t))
      
      local t = {a = 4, bb = true, ccc = false}
      local values = _.at(t,'a', 'ccc')
      assert_true(_.isEqual(values, {4, false}))       
    end)
    
  end)
  
  context('count', function()
    
    test('count the occurences of value in a list', function()
      assert_equal(_.count({1,1,2,3,3,3,2,4,3,2},1),2)
      assert_equal(_.count({1,1,2,3,3,3,2,4,3,2},2),3)
      assert_equal(_.count({1,1,2,3,3,3,2,4,3,2},3),4)
      assert_equal(_.count({1,1,2,3,3,3,2,4,3,2},4),1)
      assert_equal(_.count({1,1,2,3,3,3,2,4,3,2},5),0)
      assert_equal(_.count({false, false, true},false),2)
      assert_equal(_.count({false, false, true},true),1)
      assert_equal(_.count({{1,1},{1,1},{1,1},{2,2}},{1,1}),3)
      assert_equal(_.count({{1,1},{1,1},{1,1},{2,2}},{2,2}),1)    
    end)
    
    test('defaults to size when value is not given', function()
      assert_equal(_.count({1,1,2,3,3,3,2,4,3,2}),_.size({1,1,2,3,3,3,2,4,3,2}))
      assert_equal(_.count({false, false, true}),_.size({false, false, true}))  
    end)
  end)
  
  context('countf', function()
    
    test('count the occurences of values passing an iterator test in a list', function()
      assert_equal(_.countf({1,2,3,4,5,6}, function(i,v)
        return v%2==0
      end),3)
      assert_equal(_.countf({print, pairs, os, assert, ipairs}, function(i,v)
        return type(v)=='function'
      end),4)      
    end)
  end)
  
  context('cycle', function()
    
    test('loops n times on a list', function()
      local times = 3
      local t = {1,2,3,4,5}
      local kv = {}
      for k,v in _.cycle(t,times) do
        assert_equal(t[k],v)
        kv[#kv+1] = v
      end
      for k,v in ipairs(kv) do
        assert_equal(_.count(kv,v),times)
      end
    end)
    
    test('support array-like and map-like tables', function()
      local times = 10
      local t = {x = 1, z = 2}
      local keys = {}
      local values = {}
      for k,v in _.cycle(t,times) do
        assert_equal(t[k],v)
        keys[#keys+1] = k
        values[#values+1] = v
      end
      for k,v in ipairs(keys) do
        assert_equal(_.count(keys,v),times)
      end
      for k,v in ipairs(values) do
        assert_equal(_.count(values,v),times)
      end      
    end)
    
    test('n defaults to 1, if not supplied', function()
      local t = {1,2,3,4,5}
      for k,v in _.cycle(t) do
        t[k] = v + 1
      end
      _.each(t, function(k, v)
        assert_equal(v, k + 1)
      end)
    end)   
    
    test('if n is negative or equal to 0, it does nothing', function()
      local t = {1,2,3,4,5}
      for k,v in _.cycle(t, 0) do
        t[k] = v + 1
      end
      for k,v in _.cycle(t, -2) do
        t[k] = v + 1
      end      
      _.each(t, function(k, v)
        assert_equal(v, k)
      end)
    end)     
  end)
  
  context('map', function()
  
    test('applies an iterator function over each key-value pair ', function()
      assert_true(_.isEqual(_.map({1,2,3},function(i,v) 
          return v+10 
        end),{11,12,13}))
    end)

    test('iterates over non-numeric keys and objects', function()
      assert_true(_.isEqual(_.map({a = 1, b = 2},function(k,v) 
          return k..v 
        end),{a = 'a1',b = 'b2'}))
    end)

    test('maps key-value pairs to key-value pairs', function()
      assert_true(_.isEqual(_.map({a = 1, b = 2}, function(k, v)
          return k .. k, v + 10
        end), {aa = 11, bb = 12}))
    end)
    
  end)
  
  context('reduce', function()
  
    test('folds a collection (left to right) from an initial state', function()
      assert_equal(_.reduce({1,2,3,4},function(memo,v) return memo+v end,0),10)
    end)
    
    test('initial state defaults to the first value when not given', function()
      assert_equal(_.reduce({'a','b','c'},function(memo,v) return memo..v end),'abc')
    end)    
  
    test('supports arrays of booleans', function()
      assert_equal(_.reduce({true, false, true, true},function(memo,v) return memo and v end), false)
      assert_equal(_.reduce({true, true, true},function(memo,v) return memo and v end), true)
      assert_equal(_.reduce({false, false, false},function(memo,v) return memo and v end), false)
      assert_equal(_.reduce({false, false, true},function(memo,v) return memo or v end), true)
    end)
    
  end)
	
  context('reduceby', function()
  
    test('folds a collection (left to right) for specific values', function()
			local function even(_,v) return v%2==0 end
			local function odd(_,v) return v%2~=0 end
      assert_equal(_.reduceby({1,2,3,4},function(memo,v) return memo+v end,0,even), 6)
      assert_equal(_.reduceby({1,2,3,4},function(memo,v) return memo+v end,0,odd), 4)
    end)
   
  end)	
  
  context('reduceRight', function()
  
    test('folds a collection (right to left) from an initial state', function()
      assert_equal(_.reduceRight({1,2,4,16},function(memo,v) return memo/v end,256),2)
    end)
    
    test('initial state defaults to the first value when not given', function()
      assert_equal(_.reduceRight({'a','b','c'},function(memo,v) return memo..v end),'cba')
    end)
    
  end)

  context('mapReduce', function()
  
    test('folds a collection (left to right) saving intermediate states', function()
      assert_true(_.isEqual(_.mapReduce({1,2,4,16},function(memo,v) 
          return memo*v 
        end,0),{0,0,0,0}))
    end)
    
    test('initial state defaults to the first value when not given', function()
      assert_true(_.isEqual(_.mapReduce({'a','b','c'},function(memo,v) 
          return memo..v 
        end),{'a','ab','abc'}))
    end)  
  
  end)

  context('mapReduceRight', function()
  
    test('folds a collection (right to left) saving intermediate states', function()
      assert_true(_.isEqual(_.mapReduceRight({1,2,4,16},function(memo,v) 
          return memo/v 
        end,256),{16,4,2,2}))
    end)
    
    test('initial state defaults to the first value when not given', function()
      assert_true(_.isEqual(_.mapReduceRight({'a','b','c'},function(memo,v) 
          return memo..v 
        end),{'c','cb','cba'}))
    end)
    
  end)  

  context('include', function()
  
    test('looks for a value in a collection, returns true when found', function()
      assert_true(_.include({6,8,10,16,29},16))
    end)
    
    test('returns false when value was not found', function()
      assert_false(_.include({6,8,10,16,29},1))
    end)
    
    test('can lookup for a object', function()
      assert_true(_.include({6,{18,{2,6}},10,{18,{2,{3}}},29},{18,{2,{3}}}))
    end)    
    
    test('given an iterator, return the first value passing a truth test', function()
      assert_true(_.include({'a','B','c'}, function(array_value)
        return (array_value:upper() == array_value)
      end))
    end) 
    
  end)  
    
  context('detect', function()
  
    test('looks for the first occurence of value, returns the key where it was found', function()
      assert_equal(_.detect({6,8,10,16},8),2)
    end)
    
    test('returns nil when value was not found', function()
      assert_nil(_.detect({nil,true,0,true,true},false))
    end)
    
    test('can lookup for a object', function()
      assert_equal(_.detect({6,{18,{2,6}},10,{18,{2,{3}}},29},{18,{2,6}}),2)
    end)    
    
    test('given an iterator, return the key of the first value passing a truth test', function()
      assert_equal(_.detect({'a','B','c'}, function(array_value)
        return (array_value:upper() == array_value)
      end),2)
    end)   
  
  end) 
 
	context('where', function()
	
    test('Returns all values in a list having all of a given set of properties', function()
      local set = {
				{a = 1, b = 2},
				{a = 2, b = 2},
				{a = 2, b = 4},
				{a = 3, b = 4}
			}
      assert_true(_.isEqual(_.where(set, {a = 2}), {set[2],set[3]}))
      assert_true(_.isEqual(_.where(set, {b = 4}), {set[3],set[4]}))
      assert_true(_.isEqual(_.where(set, {a = 2, b = 2}), {set[2]}))
    end)
    
    test('returns nil when value was not found', function()
      local set = {
				{a = 1, b = 2},
				{a = 2, b = 2},
			}
      assert_nil(_.where(set, {a = 3}))
      assert_nil(_.where(set, {b = 1}))
    end) 	
	
	end)
	
  context('findWhere', function()
  
    test('Returns the first value in a list having all of a given set of properties', function()
      local a = {a = 1, b = 2}
      local b = {a = 2, b = 3}
      local c = {a = 3, b = 4}
      assert_equal(_.findWhere({a, b, c}, {a = 3, b = 4}), c)
    end)
    
    test('returns nil when value was not found', function()
      local a = {a = 1, b = 2}
      local b = {a = 2, b = 3}
      local c = {a = 3, b = 4}
      assert_nil(_.findWhere({a, b, c}, {a = 3, b = 0}))
    end) 
  
  end) 
   
  context('select', function()
  
    test('collects all values passing a truth test with an iterator', function()
      assert_true(_.isEqual(_.select({1,2,3,4,5,6,7}, function(key,value) 
          return (value%2==0)
        end),{2,4,6}))
        
      assert_true(_.isEqual(_.select({1,2,3,4,5,6,7}, function(key,value) 
          return (value%2~=0)
        end),{1,3,5,7}))        
    end)
    
  end) 
   
  context('reject', function()
  
    test('collects all values failing a truth test with an iterator', function()
      assert_true(_.isEqual(_.reject({1,2,3,4,5,6,7}, function(key,value) 
          return (value%2==0)
        end),{1,3,5,7}))
        
      assert_true(_.isEqual(_.reject({1,2,3,4,5,6,7}, function(key,value) 
          return (value%2~=0)
        end),{2,4,6}))        
    end)
    
  end) 
    
  context('all', function()
  
    test('returns whether all elements matches a truth test', function()
      assert_true(_.all({2,4,6}, function(key,value) 
          return (value%2==0)
        end))
        
      assert_false(_.all({false,true,false}, function(key,value) 
          return value == false
        end))        
    end) 
    
  end) 
 
  context('invoke', function()
  
    test('calls an iterator over each object, passing it as a first arg', function()
      assert_true(_.isEqual(_.invoke({'a','bea','cdhza'},string.len),
        {1,3,5}))

      assert_true(_.isEqual(_.invoke({{2,3,2},{13,8,10},{0,-5}},_.sort),
        {{2,2,3},{8,10,13},{-5,0}}))
        
      assert_true(_.isEqual(_.invoke({{x = 1, y = 2},{x = 3, y=4}},'x'), {1,3}))
    end)
   
    test('given a string, calls the matching object property the same way', function()
      local a = {}; function a:call() return self end
      local b, c, d = {}, {}, {}
      b.call, c.call, d.call = a.call, a.call, a.call
      assert_true(_.isEqual(_.invoke({a,b,c,d},'call'),
        {a,b,c,d}))        
    end)      
    
  end) 

  context('pluck', function()
  
    test('fetches a property value in a collection of objects', function()
    
      local peoples = {
        {name = 'John', age = 23},{name = 'Peter', age = 17},
        {name = 'Steve', age = 15},{age = 33}}
        
      assert_true(_.isEqual(_.pluck(peoples,'age'),
        {23,17,15,33}))
      assert_true(_.isEqual(_.pluck(peoples,'name'),
        {'John','Peter','Steve'}))
        
    end)
   
  end) 
   
  context('max', function()
  
    test('returns the maximum targetted property value in a collection of objects', function()    
      local peoples = {
        {name = 'John', age = 23},{name = 'Peter', age = 17},
        {name = 'Steve', age = 15},{age = 33}}        
      assert_equal(_.max(_.pluck(peoples,'age')),33)
      assert_equal(_.max(peoples,function(people) return people.age end),33)        
    end)
    
    test('directly compares items when given no iterator', function()
        assert_equal(_.max({'a','b','c'}),'c')        
    end)    
   
  end) 

  context('min', function()
  
    test('returns the maximum targetted property value in a collection of objects', function()    
      local peoples = {
        {name = 'John', age = 23},{name = 'Peter', age = 17},
        {name = 'Steve', age = 15},{age = 33}}        
      assert_equal(_.min(_.pluck(peoples,'age')),15)
      assert_equal(_.min(peoples,function(people) return people.age end),15)        
    end)
    
    test('directly compares items when given no iterator', function()
        assert_equal(_.min({'a','b','c'}),'a')        
    end)    
  
  end)
  
  context('shuffle', function()
  
    test('shuffles values and objects in a collection', function()    
      local values = {'a','b','c','d'}       
      assert_true(_.same(_.shuffle (values),values))
    end)
    
    test('can accept a seed value to init randomization', function()    
      local values = {'a','b','c','d'}
      local seed = os.time()
      assert_true(_.same(_.shuffle(values,seed),values))
    end)   

    test('shuffled table has the same elements in a different order', function()    
      local values = {'a','b','c','d'}
      assert_true(_.same(_.shuffle(values),values))
      assert_true(_.same(_.shuffle(values),values))
    end)   
  
  end)   

  context('same', function()
  
    test('returns whether all objects from both given tables exists in each other', function()    
      local a = {'a','b','c','d'}      
      local b = {'b','a','d','c'}      
      assert_true(_.same(a,b))
      b[#b+1] = 'e'
      assert_false(_.same(a,b))
    end)  
  
  end)   
   
  context('sort', function()
  
    test('sorts a collection with respect to a given comparison function', function()            
      assert_true(_.isEqual(_.sort({'b','a','d','c'}, function(a,b) 
          return a:byte() < b:byte() 
        end),{'a','b','c','d'}))
    end)

    test('uses "<" operator when no comparison function is given', function()            
      assert_true(_.isEqual(_.sort({'b','a','d','c'}),{'a','b','c','d'}))
    end)     
  
  end)

	context('sortBy', function()
	
		test('sort values on the result of a transform function', function()
			assert_true(_.isEqual(_.sortBy({1,2,3,4,5}, math.sin), {5,4,3,1,2}))
		end)
		
		test('the transform function defaults to _.identity', function()
			assert_true(_.isEqual(_.sortBy({1,2,3,4,5}), {1,2,3,4,5}))
		end)

		test('transform function can be a string name property', function()
			local unsorted = {{item = 1, value = 10},{item = 2, value = 5},{item = 3, value = 8}}
			local sorted = {{item = 2, value = 5},{item = 3, value = 8},{item = 1, value = 10}}
			assert_true(_.isEqual(_.sortBy(unsorted, 'value'), sorted))
		end)
		
		test('can use a custom comparison function', function()
			local unsorted = {{item = 1, value = 10},{item = 2, value = 5},{item = 3, value = 8}}
			local sorted = {{item = 1, value = 10},{item = 3, value = 8},{item = 2, value = 5}}
			local function comp(a,b) return a > b end
			assert_true(_.isEqual(_.sortBy(unsorted, 'value', comp), sorted))
		end)		
	
	end)
  
  context('groupBy', function()
  
    test('splits a collection into subsets of items behaving the same', function()

      assert_true(_.isEqual(_.groupBy({0,1,2,3,4,5,6},function(i,value) 
          return value%2==0 and 'even' or 'odd'
        end),{even = {0,2,4,6},odd = {1,3,5}}))
        
      assert_true(_.isEqual(_.groupBy({0,'a',true, false,nil,b,0.5},function(i,value) 
          return type(value) 
        end),{number = {0,0.5},string = {'a'},boolean = {true,false}}))
        
      assert_true(_.isEqual(_.groupBy({'one','two','three','four','five'},function(i,value) 
          return value:len()
        end),{[3] = {'one','two'},[4] = {'four','five'},[5] = {'three'}}))
        
    end)
    
    test('can takes extra-args', function()
    
      assert_true(_.isEqual(_.groupBy({3,9,10,12,15}, function(k,v,x) return v%x == 0 end,2), {[false] = {3,9,15}, [true] = {10,12}}))
      assert_true(_.isEqual(_.groupBy({3,9,10,12,15}, function(k,v,x) return v%x == 0 end,3), {[false] = {10}, [true] = {3,9,12,15}}))
      
    end)
  
  end)   

  context('countBy', function()
  
    test('splits a collection in subsets and counts items inside', function()

      assert_true(_.isEqual(_.countBy({0,1,2,3,4,5,6},function(i,value) 
          return value%2==0 and 'even' or 'odd'
        end),{even = 4,odd = 3}))
        
      assert_true(_.isEqual(_.countBy({0,'a',true, false,nil,b,0.5},function(i,value) 
          return type(value) 
        end),{number = 2,string = 1,boolean = 2}))
        
      assert_true(_.isEqual(_.countBy({'one','two','three','four','five'},function(i,value) 
          return value:len()
        end),{[3] = 2,[4] = 2,[5] = 1}))
        
    end)     
  
  end)   

  context('size', function()
  
    test('counts the very number of objects in a collection', function()      
      assert_equal(_.size {1,2,3},3)        
    end)
    
    test('counts nested tables elements as an unique value', function()      
      assert_equal(_.size {1,2,3,{4,5}},4)        
    end)

    test('leaves nil values', function()      
      assert_equal(_.size {1,2,3,nil,8},4)        
    end)
    
    test('counts objects', function()      
      assert_equal(_.size {one = 1,2,b = 3, [{}] = 'nil', 'c', [function() end] = 'foo'},6)   
    end)
    
    test('returns the size of the first arg when it is a table', function()      
      assert_equal(_.size ({1,2},3,4,5),2)   
    end)    

    test('counts the number of non-nil args when the first one is not a table', function()      
      assert_equal(_.size (1,3,4,5),4)
      assert_equal(_.size (nil,1,3,4,5),4)
      assert_equal(_.size (nil,1,3,4,nil,5),4)
    end)  
 
    test('handles nil', function()      
      assert_equal(_.size(),0)
      assert_equal(_.size(nil),0)
    end)

		
  end)   

  context('containsKeys', function()
  
    test('returns whether a table has all the keys from a given list', function()      
      assert_true(_.containsKeys({1,2,3},{1,2,3}))
      assert_true(_.containsKeys({x = 1, y = 2},{x = 1,y =2}))
    end)
    
    test('does not compare values', function()      
      assert_true(_.containsKeys({1,2,3},{4,5,6}))
      assert_true(_.containsKeys({x = 1, y = 2},{x = 4,y = -1}))
    end)

    test('is not commutative', function()      
      assert_true(_.containsKeys({1,2,3,4},{4,5,6}))      
      assert_true(_.containsKeys({x = 1, y = 2,z = 5},{x = 4,y = -1}))
      assert_false(_.containsKeys({1,2,3},{4,5,6,7}))
      assert_false(_.containsKeys({x = 1, y = 2},{x = 4,y = -1,z = 0}))
    end)
    
  end) 

  context('sameKeys', function()
  
    test('returns whether both tables features the same keys', function()      
      assert_true(_.sameKeys({1,2,3},{1,2,3}))
      assert_true(_.sameKeys({x = 1, y = 2},{x = 1,y =2}))
    end)
    
    test('does not compare values', function()      
      assert_true(_.sameKeys({1,2,3},{4,5,6}))
      assert_true(_.sameKeys({x = 1, y = 2},{x = 4,y = -1}))
    end)

    test('is commutative', function()      
      assert_false(_.sameKeys({1,2,3,4},{4,5,6}))      
      assert_false(_.sameKeys({x = 1, y = 2,z = 5},{x = 4,y = -1}))
      assert_false(_.sameKeys({1,2,3},{4,5,6,7}))
      assert_false(_.sameKeys({x = 1, y = 2},{x = 4,y = -1,z = 0}))
    end)
    
  end) 
   
end)
