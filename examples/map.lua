require "lazy"

local names = {"adam", "beatrice", "ceasar", "david"}
-- This iterator will yield the  lengths of each element in list
local lengths = Iterator.list(names):map(string.len)

for v in lengths do
    print(v)
    -- 4
    -- 8
    -- 6
    -- 5
end

