require "lazy"

local numbers = {1,2,-4,5,-7,3,-5}
local iterator = Iterator.list(numbers):filter(function(num) return num > 0 end)
for number in iterator do
    print("Number: ", number)
    -- Number:         1
    -- Number:         2
    -- Number:         5
    -- Number:         3
end
