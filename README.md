# Lazy
Lazy is a lua module that provides lazy iterators similar to those found in Haskell or Rust.
These iterators can be chained with each other and produce infinite sequences. They can also be used with a normal for loop.

Custom iterators can also be created and chained with the already existing ones

The iterators are lazy and do not evaluate until required. This means they work on infinite sequences and long lists without allocation.

## Usage
### Installation
Copy [lazy.lua](https://github.com/ten3roberts/lazy-lua/blob/master/lazy.lua) into your project and require it by:
```lua
Iterator = require "lazy"
```
The module returns the base iterator containing all functionality
### Iterating a table
```lua
local table = {a=2,b=5,c=3}
local iterator = Iterator.table(table)

-- Consume iterator, evaluating all
for k,v in iterator do
    print(k, v)
end
```
### Chaining with Map
```lua
local table = {a=2,b=5,c=3}
local iterator = Iterator.table(table):map(function(k,v) return k,v*v end)

-- Consume iterator, evaluating all
for k,v in iterator do
    print(k, v)
end
```

### Map over lists
```lua
local names = {"adam", "beatrice", "ceasar", "david"}
local lengths = Iterator.list(names):map(string.len).to_list()
```

### Filter over lists
```lua
local numbers = {1,2,-4,5,-7,3,-5}
local iterator = Iterator.list(numbers):filter(function(number) return num > 0 end)
for number in iterator do
    print("Number: ", number)
end
```

## Custom Iterators
You can also define and create your own type of iterator

This example defines an iterator which calculates a running sum on an iterator

All iterators must implement `new` and `next`

`new(iter, ...)` constructs an iterator from a chain, gets the previous iterator in chain as first argument, and the user-provided as the rest

`next()` used to yield the next value from an iterator, one value at a time

```lua
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

```

## License
This module is free software and licensed under the MIT license. The license is included in the repository and the `lazy.lua` file, so it can be copied on its own
