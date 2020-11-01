Iterator = require "lazy"

ScanIterator = {}

-- Create the iterator, this is called by :scan when chaining
-- iter is the iterator we're chaining from, Iterator.range  in this case
-- init is the initial value provided by user
-- func is the function to get the new state, provided by the user
function ScanIterator:new(iter, init, func)
    return setmetatable({iter=iter, state=init, func=func}, self)
end

-- Is called to yield the next element when iterator is consumed
function ScanIterator:next()
    -- Get the value from the chained iterator
    local next = self.iter:next()

    -- Do nothing if it yielded nil (iterator has ended)
    if next == nil then return nil end

    -- Apply func to get new state
    self.state = self.func(self.state, next)
    -- Return new state
    return self.state
end

-- This function defines the iterator enabling us to use ":scan()" to chain with other iterators
Iterator:define("scan", ScanIterator)

-- Create and consume iterator
for val in Iterator.range(1, 10):scan(0, function(state, v) return state + v end) do
    print(val)
end

-- Also works in infinite sequences without extra memory (will print until stopped)
for val in Iterator.range(1):scan(0, function(state, v) return state + v end) do
    print("Infinite: ", val)

    -- Make user press enter to not overload terminal
    io.write("Press enter to continue")
    io.read()
end
