Iterator = require "lazy"

local file = io.open("README.md")
if file == nil then
    error "Failed to open file"
end

-- Creates an iterator that yields all lines from file, turns them all to uppercase, and removes all lines that aren't between 0 and 40 chars long
local iterator = Iterator.from(file:lines())
    :map(string.upper)
    :filter(function(line) return #line > 0 and #line < 40 end)

for line in iterator do
    print(line)
end
