require "lazy"

-- local list = {"a", "b", "c", "d", "e", name="John", surname="Travolta"}

-- local iterator = Iterator:pairs(list)
-- local mapped = Iterator:pairs(list):map(function(k,v) return k, v:upper() end)
local iter = Iterator.range(0)
    :filter(function(val) return val > 0 end)
    :map(function(val) return val,val*val end)
    :filter(function(val) return val % 3 == 0 end)

for k,v in iter do
    print(k,v)
    os.execute("sleep 0.5")
end
