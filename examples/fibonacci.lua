Iterator = require "lazy"

FibIterator = {}

function FibIterator:new()
    return setmetatable({cur=1,prev=0}, self)
end

function FibIterator:next()
    self.prev, self.cur = self.cur, self.cur + self.prev
    return self.prev
end

local a = table.pack(nil, nil)
Iterator:define("fibonacci", FibIterator)

io.write("Enter length of fibonacci sequence: ")

local n = tonumber(io.read())

local _ = Iterator.fibonacci()
    :take(n)
    :each(print)
    :consume()
