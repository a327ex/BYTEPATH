require 'luacov'
local _ = require 'moses'

context('Chaining specs', function()

   context('chain', function()
  
    test('Chains a value',function()
      local v = _.chain({1,2,3,4})
        :filter(function(i,k) return k%2~=0 end)
        :max()
        :value()
      assert_equal(v, 3)
    end)
    
    test('_(value) is the same as _.chain(value)', function()
      local v = _({1,2,3,4})
        :filter(function(i,k) return k%2~=0 end)
        :max()
        :value()
      assert_equal(v, 3)    
    end)
    
  end) 
  
   context('value', function()
  
    test('Unwraps a chained object',function()
      local t = {1,2,3}
      assert_equal(_.chain(t):value(), t)
      assert_equal(_(t):value(), t)
    end)
    
  end)   

end)