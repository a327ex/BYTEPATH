--[[
Copyright (c) 2016 Calvin Rose

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

local binser = require "binser"

local function test_ser(...)
    local serialized_data = binser.s(...)
    local results, len = binser.d(serialized_data)
    for i = 1, len do
        assert.are.same(select(i, ...), results[i])
    end
end

describe("binser", function()

    it("Serializes numbers", function()
        -- NaN should work, but lua thinks NaN ~= NaN
        test_ser(1, 2, 4, 809, -1290, math.huge, -math.huge, 0)
    end)

    it("Serializes numbers with no precision loss", function()
        test_ser(math.ldexp(0.985, 1023), math.ldexp(0.781231231, -1023),
            math.ldexp(0.5, -1021), math.ldexp(0.5, -1022))
    end)

    it("Serializes strings", function()
        test_ser("Hello, World!", "1231", "jojo", "binser", "\245897", "#####",
        "#|||||###|#|#|#!@|#|@|!||2121|2", "", "\000\x34\x67\x56", "\000\255" )
    end)

    it("Serializes booleans", function()
        test_ser(true, false, false, true)
    end)

    it("Serializes nil", function()
        test_ser(nil, nil, true, nil, nil, true, nil)
    end)

    it("Serializes simple tables", function()
        test_ser({0, 1, 2, 3}, {a = 1, b = 2, c = 3})
    end)

    it("Serializes tables", function()
        -- Using tables as keys throws a wrench into busted's "same" assert.
        -- i.e., busted's deep equals seems not to apply to table keys.
        -- This isn't a bug, just annoying.
        test_ser({0, 1, 2, 3, "a", true, nil, ["ranÎØM\000\255"] = "koi"}, {})
    end)

    it("Serializes cyclic tables", function()
        local tab = {
            a = 90,
            b = 89,
            zz = "binser",
        }
        tab["cycle"] = tab
        test_ser(tab, tab)
    end)

    it("Serializes metatables", function()
        local mt = {
            name = "MyCoolType"
        }
        test_ser(setmetatable({}, mt), setmetatable({
            a = "a",
            b = "b",
            c = "c"
        }, mt))
    end)

    it("Serializes custom tyes", function()
        local mt = {
            name = "MyCoolType"
        }
        binser.register(mt)
        test_ser(setmetatable({}, mt), setmetatable({
            a = "a",
            b = "b",
            c = "c"
        }, mt))
        binser.unregister(mt.name)
    end)

    it("Serializes custom type references", function()
        local mt = {
            name = "MyCoolType"
        }
        binser.register(mt)
        local a = setmetatable({}, mt)
        test_ser(a, a, a)
        local b1, b2, b3 = binser.dn(binser.s(a, a, a), 3)
        assert.are.same(b1, b2)
        assert.are.same(b2, b3)
        binser.unregister(mt.name)
    end)

    it("Serializes cyclic tables in constructors", function()
        local mt
        mt = {
            name = "MyCoolType",
            _serialize = function(x)
                local a = {value = x.value}
                a[a] = a -- add useless cycling to try and confuse the serializer
                return a
            end,
            _deserialize = function(a)
                return setmetatable({value = a.value}, mt)
            end
        }
        binser.register(mt)
        local a = setmetatable({value = 30}, mt)
        local b = setmetatable({value = 40}, mt)
        local c = {}
        c.a = a
        c.b = b
        test_ser(a, c, b)
        binser.unregister(mt.name)
    end)

    it("Serializes functions", function()
        local function myFn(a, b)
            return (a + b) * math.sqrt(a + b)
        end
        local myNewFn = binser.dn(binser.s(myFn))
        assert.are.same(myNewFn(10, 9), myFn(10, 9))
    end)

    it("Serializes with resources", function()
        local myResource = {"This is a resource."}
        binser.registerResource(myResource, "myResource")
        test_ser({1, 3, 5, 7, 8, myResource})

        local data = binser.s(myResource)
        myResource[2] = "This is some new data."
        local deserdata = binser.dn(data)
        assert(myResource == deserdata)

        binser.unregisterResource("myResource")
    end)

    it("Serializes serpent's benchmark data", function()
        -- test data
        local b = {text="ha'ns", ['co\nl or']='bl"ue', str="\"\n'\\\001"}
        local a = {
          x=1, y=2, z=3,
          ['function'] = b, -- keyword as a key
          list={'a',nil,nil, -- shared reference, embedded nils
                [9]='i','f',[5]='g',[7]={}}, -- empty table
          ['label 2'] = b, -- shared reference
          [math.huge] = -math.huge, -- huge as number value
        }
        a.c = a -- self-reference
        local c = {}
        for i = 1, 500 do
           c[i] = i
        end
        a.d = c
        -- test data
        test_ser(a)
    end)

    it("Fails gracefully on impossible constructors", function()
        local mt = {
            name = "MyCoolType",
            _serialize = function(x) return x end,
            _deserialize = function(x) return x end
        }
        binser.register(mt)
        local a = setmetatable({}, mt)
        assert.has_error(function() binser.s(a, a, a) end, "Infinite loop in constructor.")
        binser.unregister(mt.name)
    end)

    it("Can use templates to have more efficient custom serialization and deserialization", function()
        local mt = {
            name = "marshalledtype",
            _template = {
                "cat", "dog", 0, false
            }
        }
        local a = setmetatable({
            cat = "meow",
            dog = "woof",
            [0] = "something",
            [false] = 1
        }, mt)
        binser.register(mt)
        test_ser(a)
        binser.unregister(mt)
    end)

    it("Can use nested templates", function()
        local mt = {
            name = "mtype",
            _template = {
                "movie", joe = { "age", "width", "height" }, "yolo"
            }
        }
        local a = setmetatable({
            movie = "Die Hard",
            joe = {
                age = 25,
                width = "kinda wide",
                height = "not so tall"
            },
            yolo = "bolo"
        }, mt)
        binser.register(mt)
        test_ser(a)
        binser.unregister(mt)
    end)

    it("Can use templates that don't fully specify an object", function()
        local mt = {
            name = "marshalledtype",
            _template = {
                "cat", "dog", 0, false
            }
        }
        local a = setmetatable({
            cat = "meow",
            dog = "woof",
            [0] = "something",
            [false] = 1,
            notintemplate = "woops."
        }, mt)
        binser.register(mt)
        test_ser(a)
        binser.unregister(mt)
    end)

    it("Can serialize nested registered objects", function()
        local mt1 = {
            name = "MyCoolType1",
            _serialize = function(x) return x.data1 end,
            _deserialize = function(x) return { data1 = x } end
        }
        local mt2 = {
            name = "MyCoolType2",
            _serialize = function(x) return x.data2 end,
            _deserialize = function(x) return { data2 = x } end
        }
        binser.register(mt1)
        binser.register(mt2)
        local instance = setmetatable({
            data1 = setmetatable({
                data2 = 11
            }, mt2)
        }, mt1)
        test_ser(instance)
        binser.unregister(mt1.name)
        binser.unregister(mt2.name)
    end)

    it("Can serialize function references", function()
        local f = function()
            print "hello, world!"
        end
        local f2 = function()
            print "goodbye, world!"
        end
        local indata = {f, f, f, f, f, f, f2, f2, f2, f, f, f2, f}
        local outdata = binser.dn(binser.s(indata), 1)
        for i, func in ipairs(indata) do
            assert.are.same(string.dump(func, true), string.dump(outdata[i], true))
        end
    end)

    -- 5.3 only
    if math.type then
        it("Can serialize large integers", function()
            test_ser(10000, math.maxinteger, math.maxinteger - 120)
        end)

        it("Can serialize small integers", function()
            test_ser(-10000, math.mininteger, math.mininteger + 201)
        end)
    end

end)
