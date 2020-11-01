local Iterator = {}
-- Iterator.__index = function(t, k) print("Iterator lookup", k) return getmetatable(t)[k] end
Iterator.__index = Iterator

local GenericIterator = {}
function Iterator.from(func, state, init)
    print("func: ", func)
    print("state: ", state)
    print("init: ", init)
    return GenericIterator:new(func, state, init)
end
--- Returns an iterator that yields two values, a key and value, for each entry in table
--- Works like std pairs(), except iterator style
function Iterator.pairs(table)
    return GenericIterator:new(pairs(table))
end

--- Returns an iterator that yields in order numerical keys of a table
--- Works like std ipairs(), except iterator style
function Iterator.ipairs(table)
    return GenericIterator:new(ipairs(table))
end

--- Fully consumes and evaluates iterator, discarding the result
--- Useful when an iterator has a side effect and it is needed to be run
function Iterator:consume()
    while true do
        if self:next() == nil then break end
    end
end

--- Alias for :next to allow for loop integration
function Iterator:__call()
    return self:next()
end

function Iterator:to_list()
    local result = {}
    for val in self do
        result[#result + 1] = val
    end
    return result
end

function Iterator:to_table()
    local result = {}
    for key, val in self do
        result[key] = val
    end
    return result
end

--- Defines a iterator "trait" and allows it to be chained with the name
function Iterator:define(name, iterator)
    setmetatable(iterator, self)

    iterator.__index = iterator
    iterator.__call = self.__call

    setmetatable(iterator, self)
    self.__index = self
    self[name] = function (...) return iterator:new(...) end
end

------------- Default Iterators -------------
local RangeIterator = {}

-- Iterator yielding a closed range from start to stop
-- If end is nil, range is infinite
-- An optional step can be defined as a third argument
function RangeIterator:new(start, stop, step)
    return setmetatable({cur=start, stop=stop, step=step or 1}, self)
end

function RangeIterator:next()
    if self.stop ~= nil and self.cur > self.stop then return nil end

    local cur = self.cur
    self.cur = self.cur + self.step

    return cur
end

function GenericIterator:new(func, state, init)
    return setmetatable({alive=true, func=func, state=state, prev=init}, self)
end

function GenericIterator:next()
    if not self.alive then return nil end
    local k,v = self.func(self.state, self.prev)
    self.prev = k
    if k == nil then self.alive = false end

    return k,v
end

local ListIterator = {}

function ListIterator:new(list)
    return setmetatable({index=1, list=list}, self)
end

function ListIterator:next()
    local item = self.list[self.index]
    if item ~= nil then
        self.index = self.index  + 1
    end
    return item
end


local MapIterator = {}

function MapIterator:new(iter, func)
    return setmetatable({iter=iter, func=func}, self)
end

function MapIterator:next()
    local next = table.pack(self.iter:next())

    if #next > 0 then
        return self.func(table.unpack(next))
    else
        return nil
    end
end

local FilterIterator = {}

function FilterIterator:new(iter, pred)
    return setmetatable({iter=iter, pred=pred}, self)
end

function FilterIterator:next()
    while true do
        local next = table.pack(self.iter:next())
        if #next == 0 then return nil end

        if self.pred(table.unpack(next)) then
            return table.unpack(next)
        end
    end

end

local TakeIterator = {}

function TakeIterator:new(iter, n)
    return setmetatable({iter=iter, n=n}, self)
end

function TakeIterator:next()
    if self.n == 0 then return nil end

    self.n = self.n - 1
    return self.iter:next()
end

local EachIterator = {}

function EachIterator:new(iter, func)
    return setmetatable({iter=iter, func=func}, self)
end

function EachIterator:next()
    local next = table.pack(self.iter:next())
    if #next == 0 then return nil end

    self.func(table.unpack(next))

    return table.unpack(next)
end

Iterator:define("from", GenericIterator)
Iterator:define("range", RangeIterator)
Iterator:define("list", ListIterator)
Iterator:define("map", MapIterator)
Iterator:define("filter", FilterIterator)
Iterator:define("take", TakeIterator)
Iterator:define("each", EachIterator)

return Iterator

-- MIT License
--
-- Copyright (c) 2020 Tim Roberts
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
