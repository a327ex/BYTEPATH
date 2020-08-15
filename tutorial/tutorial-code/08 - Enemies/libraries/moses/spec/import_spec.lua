require 'luacov'
local _ = require 'moses'

context('Import specs', function()
  
  test('imports all library function to a given context', function()
    local funcs = _.functions()
    local context = _.import({})
    assert_true(_.all(funcs, function(k, n) return _.has(context, n) end))
  end)

  test('passing "noConflict" will preserve already existing keys', function()
    local funcs = _.functions()
    local context = _.import({each = 1, all = 2}, true)
    assert_true(_.all(funcs, function(k, n) return _.has(context, n) end))
    assert_equal(context.each, 1)
    assert_equal(context.all, 2)
  end)
    
  test('The context will default to the global _G if not supplied', function()
    local oldG = _.clone(_G,true)
    assert_not_equal(_G, oldG)
    _.import()
    local funcs = _.functions()
    _.each(funcs, function(__, fname)
      assert_not_nil(_G[fname])
      assert_true(type(_G[fname]) == 'function')
    end)
    _G = oldG
  end)
  
end)