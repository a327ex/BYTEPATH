local timer = require 'timer'()

describe('hump.timer', function()
  it('runs a function during a specified time', function()
    local delta, remaining

    timer:during(10, function(...) delta, remaining = ... end)

    timer:update(2)
    assert.are.equal(delta, 2)
    assert.are.equal(8, remaining)

    timer:update(5)
    assert.are.equal(delta, 5)
    assert.are.equal(3, remaining)

    timer:update(10)
    assert.are.equal(delta, 10)
    assert.are.equal(0, remaining)
  end)

  it('runs a function after a specified time', function()
    local finished1 = false
    local finished2 = false

    timer:after(3, function(...) finished1 = true end)
    timer:after(5, function(...) finished2 = true end)

    timer:update(4)
    assert.are.equal(true, finished1)
    assert.are.equal(false, finished2)

    timer:update(4)
    assert.are.equal(true, finished1)
    assert.are.equal(true, finished2)
  end)

  it('runs a function every so often', function()
    local count = 0

    timer:every(1, function(...) count = count + 1 end)

    timer:update(3)
    assert.are.equal(3, count)

    timer:update(7)
    assert.are.equal(10, count)
  end)

  it('can script timed events', function()
    local state

    timer:script(function(wait)
      state = 'foo'
      wait(1)
      state = 'bar'
    end)

    assert.are.equal('foo', state)
    timer:update(0.5)
    assert.are.equal('foo', state)
    timer:update(1)
    assert.are.equal('bar', state)
  end)

  it('cancels and clears timer functions', function()
    pending('to be tested...')
  end)

  it('tweens', function()
    pending('to be tested...')
  end)
end)
