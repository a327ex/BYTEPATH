Ripple
------
**Ripple** is an audio library for LÖVE. It handles a variety of situations for sound effects and music, and it has support for tags and calling function in time with music.

```lua
ripple = require 'ripple'

tags = {
  sfx = ripple.newTag(),
  music = ripple.newTag(),
  master = ripple.newTag(),
}

sounds = {
  shoot = ripple.newSound('shoot.ogg', {
    tags = {tags.sfx, tags.master},
  }),
}

music = {
  gameplay = ripple.newSound('gameplay.ogg', {
    bpm = 130,
    length = '32m',
    loop = true,
    tags = {tags.music, tags.master},
  })
}
music.gameplay.every['1b'] = function() background:flashOnBeat() end

tags.master:setVolume(.8)
music.gameplay:play()

function player:shoot()
  sounds.shoot:play {pitch = .5*love.math.random() + .5}
end

function love.update(dt)
  for _, m in pairs(music) do
    m:update(dt)
  end
end
```

Installation
============
To use Ripple, place ripple.lua in your root folder and include the library using
```lua
ripple = require 'ripple'
```
Alternatively, you can place ripple.lua in a subfolder and include it like this:
```lua
ripple = require 'path.to.ripple'
```

Usage
=====
### Basic usage
To create a sound, use `ripple.newSound`:
```lua
sound = ripple.newSound(filename, options)
```
- `filename` is the path to the sound.
- `options` is a table containing any of the following properties:
  - `bpm` - the beats per minute of the sound (mostly applicable if you're using the sound as music)
  - `length` - the length of the sound (mostly applicable if you're using the sound as music)
  - `loop` - set this to `true` to loop the sound whenever it reaches its end (defined by `length`)
  - `tags` - a table containing a list of tags to tag the sound with
  - `mode` - can be either `'static'` or `'stream'`, and defaults to '`static`'. `'static'` means that the entire sound will be loaded at once, while `'stream'` means that the sound will be loaded on the fly. Streaming sources take less memory, but there can be a slight delay when playing them, so using the static mode is recommended for cases where two sounds need to play at the exact same time (i.e. music with multiple layers).

To play a sound, use `sound:play`:
```lua
sound:play(options)
```
- `options` is a table containing any of the following properties:
  - `volume` - the volume of the instance of the sound
  - `pitch` - the pitch of the instance of the sound

Note that `sound:play` creates a new instance of the sound each time, so multiple copies of the sound can play at once, and each instance has a separate volume and pitch.

To stop a sound, just call `sound:stop()`.

To update a sound, call
```lua
sound:update(dt)
```
where `dt` is the time between frames (you'll probably want to use the `dt` argument from `love.update`). You don't *have* to call `update` on every sound, but the `loop` option as well as `onEnd` and `every` functions (see below) only work if the sound is updated every frame.

### Timing actions with music
Ripple provides two ways of timing actions with sounds, `onEnd` and `every`.

To call code at the end of a sound, overwrite the function `sound.onEnd`. For example, this code will cause a sound to loop:
```lua
sound.onEnd = function() sound:play() end
-- this is just an example, using the loop option in ripple.newSound would be easier
```
You can specify when the "end" of a sound is by setting the `length` option in `ripple.newSound`.

To call code at regular intervals in a sound, set `sound.every[interval]` to a function, where `interval` is the amount of time between function calls, and the function is the code you want to call. For example, this will print "eighth note" to the console on every half a beat:

```lua
sound.every['.5b'] = function() print 'eighth note' end
```

#### Specifying times
Both `options.length` and intervals use a string with the following format to specify times:
```lua
'[time][unit]'
```
- `time` is the amount of time.
- `unit` is the unit of time. The possible units are:
  - `'s'` - seconds
  - `'b'` - beats
  - `'m'` - measures (assuming 4 beats per measure)

Note that to use beats or measures for your times, you must specify `options.bpm` in `ripple.newSound`.

### Tags and volumes
Tags are categories you can assign to sounds, allowing you to control the volume levels of multiple sounds at once. To create a tag, use `ripple.newTag`:
```lua
tag = ripple.newTag()
```
And to tag a sound, use `sound:tag`:
```lua
sound:tag(tag)
```
where `tag` is the tag to assign to the sound. You can also remove tags using `sound:untag(tag)`.

To get the volume of a tag, use 
```
tag:getVolume()
```
and to set the volume of a tag, use
```
tag:setVolume(volume)
```
(where volume is a number from 0-1, 0 representing 0%, and 1 representing 100%).

Note that the functions `tag`, `untag`, `getVolume`, and `setVolume` are all available to both sounds and tags. This means that you can get and set the volume of individual sounds, and you can tag and untag tags themselves, creating a hierarchy of tags.

#### Magic volume property
Both tags and sounds have a table called `volume` you can use. If you access any key in the `volume` table, the value is equivalent to `sound:getVolume()`, and if you set any key in the table to a `value`, it is equivalent to calling `sound:setVolume(value)`. This allows you to control volume levels using a variable instead of get and set functions, like so:
```lua
sound.volume.v = .5
-- the volume is now .5, just as if you called sound:setVolume(.5)
print(sound.volume.v) -- prints .5
print(sound.volume.value) -- also prints .5
```
This is useful for tweening volumes for situations such as crossfading music.

Contributing
============
This library is in early development, so feel free to open issues or create pull requests in regards to either design or implementation.

License
=======
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
