require "Q/UTILS/lua/strict"
local multiple8 = require "Q/UTILS/lua/multiple8"
for i = 1, 17 do
  print(i, multiple8(i))
end
print("SUCCESS for ", arg[0])
