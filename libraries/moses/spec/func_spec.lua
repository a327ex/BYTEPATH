require 'luacov'
local _ = require 'moses'

context('Utility functions specs', function()

  context('noop', function()
  
    test('the no-operation function',function()
			assert_nil(_.noop())
			assert_nil(_.noop(nil))
			assert_nil(_.noop(false))
			assert_nil(_.noop({}))
			assert_nil(_.noop(function() end))
			assert_nil(_.noop(_.noop))
    end)
    
  end)
	
  context('identity', function()
  
    test('returns the received value',function()
      assert_equal(_.identity(1),1)
      local v = {x = 0}      
      assert_equal(_.identity(v),v)
      assert_not_equal(v,{x = 0})
    end)
    
  end)
	
  context('constant', function()
  
    test('creates a constant function',function()
			local gravity = _.constant(9.81)
			assert_equal(gravity(),9.81)
			assert_equal(gravity(10), 9.81)
			assert_equal(gravity(nil), 9.81)
    end)
    
  end)	
  
  context('once', function()
  
    test('returns a version of a function that runs once',function()
      local sq = _.once(function(a) return a*a end)
      assert_equal(sq(2),4)
    end)
    
    test('successive calls will keep yielding the original answer',function()
      local sq = _.once(function(a) return a*a end)
      for i = 1,10 do
        assert_equal(sq(i),1)
      end
    end)    
    
  end)
  
  context('memoize', function()
  
    local fib_time, fib_value, mfib_time, mfib_value
    local fib, mfib
    
    before(function()
      local function fib(n)
        return n < 2 and n or fib(n-1)+fib(n-2)
      end      
      local times = 10
      local mfib = _.memoize(fib)
      fib_time = os.clock()
        for i = 1, times do fib_value = (fib_value or 0)+fib(20) end
      fib_time = (os.clock()-fib_time)*1000
      
      mfib_time = os.clock()
        for i = 1, times do mfib_value = (mfib_value or 0)+mfib(20) end
      mfib_time = (os.clock()-mfib_time  )*1000    
    end)
    
    test('memoizes an expensive function by caching its results',function()
      assert_true(mfib_time<=fib_time)
    end)
    
    test('can take a hash function to compute an unique output for multiple args',function()
    
      local function hash(a,b) return (a^13+b^19) end
      local function fact(a) return a <= 1 and 1 or a*fact(a-1) end
      local diffFact = function(a,b) return fact(a)-fact(b) end
      local mdiffFact = _.memoize(function(a,b) return fact(a)-fact(b) end,hash)
      local times, rep = 100, 10
      
      local time = os.clock()
      for j = 1,times do 
        for ai = 1,rep do
          for aj = 1,rep do diffFact(ai,aj) end
        end
      end
      time = (os.clock()-time)*1000

      local mtime = os.clock()
      for j = 1,times do 
        for ai = 1,rep do
          for aj = 1,rep do mdiffFact(ai,aj) end
        end
      end
      mtime = (os.clock()-mtime)*1000

      assert_true(mtime<=time)

    end)
    
  end)  
  
  context('after', function()
  
    test('returns a function that will respond on its count-th call',function()
      local function a(r) return (r) end
      a = _.after(a,5)
      for i = 1,10 do
        if i < 5 then 
          assert_nil(a(i))
        else 
          assert_equal(a(i),i)
        end
      end
    end)
    
  end) 
  
  context('compose', function()
    
    test('can compose commutative functions',function()
      local greet = function(name) return "hi: " .. name end
      local exclaim = function(sentence) return sentence .. "!" end
      assert_equal(_.compose(greet,exclaim)('moe'),'hi: moe!')
      assert_equal(_.compose(exclaim,greet)('moe'),'hi: moe!')
    end)
    
    test('composes mutiple functions',function()
      local function f(x) return x^2 end
      local function g(x) return x+1 end
      local function h(x) return x/2 end
      local compositae = _.compose(f,g,h)
      assert_equal(compositae(10),36)
      assert_equal(compositae(20),121)
    end)   

    test('compose non commutative functions in reverse order',function()
      local function f(s) return (s or '')..'f' end
      local function g(s) return (s or '')..'g' end
      local function h(s) return (s or '')..'h' end
      assert_equal(_.compose(f,g,h)(),'hgf')
      assert_equal(_.compose(h,g,f)(),'fgh')
      assert_equal(_.compose(f,h,g)(),'ghf')
      assert_equal(_.compose(g,h,f)(),'fhg')
    end) 		
    
  end) 

  context('pipe', function()
    
    test('pipes a value through a series of functions',function()
      local function f(x) return x^2 end
      local function g(x) return x+1 end
      local function h(x) return x/2 end
      assert_equal(_.pipe(10,f,g,h),36)
      assert_equal(_.pipe(20,f,g,h),121)  
    end) 
    
  end)

  context('complement', function()
    
    test('returns a function which returns the logical complement of a given function',function()
      assert_false(_.complement(function() return true end)())
      assert_true(_.complement(function() return false end)())
      assert_true(_.complement(function() return nil end)())
      assert_false(_.complement(function() return 1 end)())
    end) 
    
  end)
  
  context('juxtapose', function()
    
    test('calls a sequence of functions with the same set of args',function()
      local function f(x) return x^2 end
      local function g(x) return x+1 end
      local function h(x) return x/2 end
      local rf, rg, rh = _.juxtapose(10, f, g, h)
      assert_equal(rf, 100)
      assert_equal(rg, 11)
      assert_equal(rh, 5)
    end) 
    
  end)
  
  context('wrap', function()
  
    test('wraps a function and passes args',function()
      local greet = function(name) return "hi: " .. name end
      local backwards = _.wrap(greet, function(f,arg)
          return f(arg) ..'\nhi: ' .. arg:reverse()
        end) 
      assert_equal(backwards('john'),'hi: john\nhi: nhoj')
    end)
    
  end)
  
  context('times', function()
  
    test('calls a given function n times',function()
      local f = ('Lua programming'):gmatch('.')
      local r = _.times(3,f)
      assert_true(_.isEqual(r,{'L','u','a'}))
      
      local count = 0
      local function counter() count = count+1 end
      _.times(10,counter)
      assert_equal(count,10)
    end)
    
  end)  
  
  context('bind', function()
  
    test('binds a value to the first arg of a function',function()
      local sqrt2 = _.bind(math.sqrt,2)
      assert_equal(sqrt2(),math.sqrt(2))
    end)
    
  end) 

  context('bind2', function()
  
    test('binds a value to the second arg of a function',function()
      local last2 = _.bind2(_.last,2)
      local r = last2({1,2,3,4,5,6})
      assert_true(_.isEqual(r, {5,6}))
    end)
    
  end)

  context('bindn', function()
  
    test('binds n values to as the n-first args of a function',function()
      local function out(...)
        return table.concat {...}
      end
      out = _.bindn(out,'OutPut',':',' ')
      assert_equal(out(1,2,3),'OutPut: 123')
      assert_equal(out('a','b','c','d'),'OutPut: abcd')
    end)
    
  end)
  
  context('bindAll', function()
  
    test('binds methods to object',function()
			local window = {
				setPos = function(w,x,y) w.x, w.y = x, y end, 
				setName = function(w,name) w.name = name end,
				getName = function(w) return w.name end,
			}
			window = _.bindAll(window, 'setPos', 'setName', 'getName')
			window.setPos(10,15)
			window.setName('fooApp')
			
			assert_equal(window.x, 10)
			assert_equal(window.y, 15)
			assert_equal(window.name, 'fooApp')
			assert_equal(window.getName(), 'fooApp')
    end)
    
  end)
	
  context('uniqueId', function()
  
    test('returns an unique (for the current session) integer Id',function()
      local ids = {}
      for i = 1,100 do
        local newId = _.uniqueId()
        assert_false(_.include(ids,newId))
        _.push(ids,newId)
      end     
    end)
    
    test('accepts a string template to format the returned id',function()
      local ids = {}
      for i = 1,100 do
        local newId = _.uniqueId('ID:%s')
        assert_equal(newId,'ID:'..newId:sub(4))
        assert_false(_.include(ids,newId))
        _.push(ids,newId)
      end        
    end)
    
    test('accepts a function as argument to format the returned id',function()
      local ids = {}
      local formatter = function(ID) return '$'..ID..'$' end
      for i = 1,100 do
        local newId = _.uniqueId(formatter)
        assert_not_nil(newId:match('^%$%d+%$$'))
        assert_false(_.include(ids,newId))
        _.push(ids,newId)
      end        
    end)
    
  end)  
  
	context('iterator', function()

		test('creates an iterator which continuously applies f on an input',function()
			local next_even = _.iterator(function(x) return x + 2 end, 0)
			assert_equal(next_even(), 2)
			assert_equal(next_even(), 4)
			assert_equal(next_even(), 6)
			assert_equal(next_even(), 8)
			assert_equal(next_even(),10)
		end)
		
	end)
	
	context('flip', function()

		test('creates a function which runs f with arguments flipped',function()
			local function f(...) return table.concat({...}) end
			local flipped = _.flip(f)
			assert_equal(flipped('a','b','c'),'cba')
		end)
		
	end)		
	
	context('over', function()

		test('returns a function which applies a set of transforms to its args',function()
			local minmax = _.over(math.min, math.max)
			local maxmin = _.over(math.max, math.min)
			assert_true(_.isEqual(minmax(5,10,12,4,3),{3,12}))
			assert_true(_.isEqual(maxmin(5,10,12,4,3),{12,3}))	
		end)
		
	end)		
	
	context('overEvery', function()
		
		local alleven, allpositive
		
		before(function()
			alleven = function(...) 
				for i, v in ipairs({...}) do if v%2~=0 then return false end end 
				return true 
			end

			allpositive = function(...)
				for i, v in ipairs({...}) do if v < 0 then return false end end
				return true 	
			end		
		end)
		
		test('checks if all predicates passes truth with args. ',function()
			local allok = _.overEvery(alleven, allpositive)
			assert_false(allok(2,4,-1,8))
			assert_false(allok(10,3,2,6))
			assert_true(allok(8,4,6,10))
		end)
		
	end)

	context('overSome', function()
		
		local alleven, allpositive
		
		before(function()
			alleven = function(...) 
				for i, v in ipairs({...}) do if v%2~=0 then return false end end 
				return true 
			end

			allpositive = function(...)
				for i, v in ipairs({...}) do if v < 0 then return false end end
				return true 	
			end		
		end)
		
		test('checks if all predicates passes truth with args. ',function()
			local anyok = _.overSome(alleven, allpositive)
			assert_false(anyok(2,4,-1,8))
			assert_true(anyok(10,3,2,6))
			assert_false(anyok(-1,-5,-3))
		end)
		
	end)	
	
	context('overArgs', function()

		test('Creates a function that invokes `f` with its arguments transformed',function()
			local function f(x, y) return {x, y} end
			local function triple(x) return x*3 end
			local function square(x) return x^2 end
			local new_f = _.overArgs(f, triple, square)
			assert_true(_.isEqual(new_f(1,2), {3,4}))
			assert_true(_.isEqual(new_f(10,10), {30,100}))			
		end)
		
		test('when supplied more args than transforms, remaining are left as-is',function()
			local function f(x, y, z, k) return {x, y, z, k} end
			local function triple(x) return x*3 end
			local function square(x) return x^2 end
			local new_f = _.overArgs(f, triple, square)
			assert_true(_.isEqual(new_f(1,2,3,4), {3,4,3,4}))
			assert_true(_.isEqual(new_f(10,10,10,10), {30,100,10,10}))			
		end)		
		
	end)	
	
	context('partial', function()

		test('applies partially f',function()
			local function diff(a, b) return a - b end
			local diffFrom20 = _.partial(diff, 20)
			assert_equal(diffFrom20(5), 15)
			assert_equal(diffFrom20(10), 10)
			assert_equal(diffFrom20(-5), 25)
		end)
		
		test('\'_\' can be used as a placeholder',function()
			local function diff(a, b) return a - b end
			local remove10 = _.partial(diff, '_',10)
			assert_equal(remove10(5), -5)
			assert_equal(remove10(10), 0)
			assert_equal(remove10(15), 5)
		end)
		
	end)
	
	context('partialRight', function()

		test('applies partial but from the right',function()
			local function concat(a,b,c,d) return a..b..c..d end
			assert_equal(_.partialRight(concat,'a','b','c')('d'), 'dabc')
			assert_equal(_.partialRight(concat,'a','b')('c','d'), 'cdab')
			assert_equal(_.partialRight(concat,'a')('b','c','d'), 'bcda')
		end)
		
		test('\'_\' can be used as a placeholder',function()
			local function concat(a,b,c,d) return a..b..c..d end		
			assert_equal(_.partialRight(concat,'a','_','c')('d','b'), 'badc')
			assert_equal(_.partialRight(concat,'a','b','_')('c','d'), 'dabc')
			assert_equal(_.partialRight(concat,'_','a')('b','c','d'), 'cdba')
		end)
		
	end)	
	
	context('curry', function()

		test('curries a function for a specific number of args',function()
			local function sumOf5args(a,b,c,d,e) return a+b+c+d+e end
			local curried_sumOf5args = _.curry(sumOf5args, 5)
			assert_equal(curried_sumOf5args(1)(2)(3)(4)(5),15)
			assert_equal(curried_sumOf5args(8)(-2)(4)(-10)(1),1)
		end)
		
		test('n_args defaults to 2 when not supplied',function()
			local function prod(x,y) return x*y end
			local curried_prod = _.curry(prod)
			assert_equal(curried_prod(2)(3), (_.curry(prod,2))(2)(3))
			assert_equal(curried_prod(-2)(6), (_.curry(prod,2))(-2)(6))
		end)

		test('n_args can be equal to 1',function()
			local curried_identity = _.curry(_.identity,1)
			assert_equal(curried_identity('value'), 'value')
			assert_equal(curried_identity(1), 1)
			assert_equal(curried_identity(true), true)
			assert_equal(curried_identity(false), false)
		end)
		
		test('giving more args than n_args will raise an error',function()
			local function add(a,b) return a+b end
			local curried_add = _.curry(add, 2)
			assert_error(function() curried_add(1)(2)(3) end)
			assert_error(function() curried_add(4)(5)(6)(7)(8) end)
		end)		
		
		test('When given less than n_args, it will wait for missing args',function()
			local function add(a,b,c) return a+b+c end
			local curried_add = _.curry(add, 3)
			local c1 = curried_add(1)
			local c2 = c1(2)
			local c3 = c2(3)
			assert_type(c1, 'function')		
			assert_type(c2, 'function')
			assert_equal(c3, 6)
		end)
		
	end)	
	
end)