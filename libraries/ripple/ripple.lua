local ripple = {
  _VERSION = 'Ripple',
  _DESCRIPTION = 'Audio library for LÖVE',
  _URL = 'https://github.com/tesselode/ripple',
  _LICENSE = [[
    MIT License

    Copyright (c) 2016 Andrew Minnich

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
  ]]
}


local function removeByValue(t, v)
  for i = #t, 1, -1 do
    if t[i] == v then
      table.remove(t, i)
    end
  end
end

local function removeByFilter(t, f)
  for i = #t, 1, -1 do
    if f(t[i]) then
      table.remove(t, i)
    end
  end
end


local Tag = {}

function Tag:_addChild(child)
  table.insert(self._children, child)
end

function Tag:_removeChild(child)
  removeByValue(self._children, child)
end

function Tag:_updateVolume()
  for i = 1, #self._children do
    self._children[i]:_updateVolume()
  end
end

function Tag:_getFinalVolume()
  local v = self._volume
  for i = 1, #self._parents do
    v = v * self._parents[i]:_getFinalVolume()
  end
  return v
end

function Tag:getVolume()
  return self._volume
end

function Tag:setVolume(volume)
  self._volume = volume
  self:_updateVolume()
end

function Tag:tag(tag)
  table.insert(self._parents, tag)
  tag:_addChild(self)
  self:_updateVolume()
end

function Tag:untag(tag)
  removeByValue(self._parents, tag)
  tag:_removeChild(self)
  self:_updateVolume()
end

local function newTag()
  local tag = setmetatable({
    _children = {},
    _parents = {},
    _volume = 1,
  }, {__index = Tag})
  tag.volume = setmetatable({}, {
    __index = function(t, k) return tag:getVolume() end,
    __newindex = function(t, k, v) tag:setVolume(v) end,
  })
  return tag
end


local Instance = setmetatable({}, {__index = Tag})

function Instance:_updateVolume()
  self._source:setVolume(self:_getFinalVolume())
end

function Instance:_stop()
  self._source:stop()
end

local function newInstance(sound, options)
  options = options or {}
  local instance = setmetatable({
    _children = {},
    _parents = {},
    _volume = options.volume or 1,
    _source = sound._source:clone(),
  }, {__index = Instance})
  instance:tag(sound)
  instance:_updateVolume()
  instance._source:setPitch(options.pitch or 1)
  instance._source:play()
  return instance
end


local Sound = setmetatable({}, {__index = Tag})

function Sound:_parseTime(value)
  local time, units = value:match '(.*)([sbm])'
  time = tonumber(time)
  if units == 's' then
    return time
  elseif units == 'b' then
    assert(self._bpm, 'Must set the BPM to use beats and measures as units')
    return 60/self._bpm * time
  elseif units == 'm' then
    assert(self._bpm, 'Must set the BPM to use beats and measures as units')
    return 60/self._bpm * time * 4
  end
end

function Sound:_getLength()
  if self._length then
    return self:_parseTime(self._length)
  else
    return self._source:getDuration()
  end
end

function Sound:_clean()
  removeByFilter(self._children, function(instance)
    return not instance._source:isPlaying()
  end)
end

function Sound.onEnd() end

function Sound:play(options)
  self:_clean()
  local instance = newInstance(self, options)
  self._playing = true
  self._time = 0
  for interval, f in pairs(self.every) do
    self._timers[interval] = self:_parseTime(interval)
  end
end

function Sound:update(dt)
  if self._playing then
    self._time = self._time + dt
    for interval, f in pairs(self.every) do
      local t = self._timers
      t[interval] = t[interval] - dt
      while t[interval] <= 0 do
        t[interval] = t[interval] + self:_parseTime(interval)
        f()
      end
    end
    if self._time >= self:_getLength() then
      self._playing = false
      self.onEnd()
      if self._loop then
        self:play()
      end
    end
  end
end

function Sound:stop()
  for i = 1, #self._children do
    self._children[i]:_stop()
  end
  self._playing = false
  self:_clean()
end

local function newSound(filename, options)
  options = options or {}
  options.tags = options.tags or {}
  local sound = setmetatable({
    _children = {},
    _parents = {},
    _volume = 1,
    _source = love.audio.newSource(filename, options.mode or 'static'),
    _bpm = options.bpm,
    _length = options.length,
    _loop = options.loop or false,
    _playing = false,
    _time = 0,
    every = {},
    _timers = {},
  }, {__index = Sound})
  sound.volume = setmetatable({}, {
    __index = function(t, k) return sound:getVolume() end,
    __newindex = function(t, k, v) sound:setVolume(v) end,
  })
  for i = 1, #options.tags do
    sound:tag(options.tags[i])
  end
  return sound
end


ripple.newTag = newTag
ripple.newSound = newSound
return ripple
