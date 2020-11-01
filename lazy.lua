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
    local o = setmetatable({cur=start, stop=stop, step=step or 1}, self)
    return o
end

function RangeIterator:next()
    if self.stop ~= nil and self.cur > self.stop then return nil end

    local cur = self.cur
    self.cur = self.cur + self.step

    return cur
end

function GenericIterator:new(func, state, init)
    local o = setmetatable({alive=true, func=func, state=state, prev=init}, self)
    return o
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
    local o = setmetatable({index=1, list=list}, self)
    return o
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
    local o = setmetatable({iter=iter, func=func}, self)
    return o
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
    local o = setmetatable({iter=iter, pred=pred}, self)
    return o
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


Iterator:define("from", GenericIterator)
Iterator:define("range", RangeIterator)
Iterator:define("list", ListIterator)
Iterator:define("map", MapIterator)
Iterator:define("filter", FilterIterator)

return Iterator