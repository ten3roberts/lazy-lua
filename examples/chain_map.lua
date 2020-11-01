Iterator = require "lazy"
local table = {a=2,b=5,c=3}
local iterator = Iterator.pairs(table):map(function(k,v) return k,v*v end)

-- Consume iterator, evaluating all
for k,v in iterator do
    print(k, v)
end
