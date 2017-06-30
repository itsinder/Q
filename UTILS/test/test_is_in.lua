require "Q/UTILS/lua/strict"
local is_in = require "Q/UTILS/lua/is_in"
local x = "number"
local X = { "number", "string", "table" }
local rslt = is_in(x, X)
assert(rslt == true)
x = "foobar"
local rslt = is_in(x, X)
assert(rslt == false)
print("SUCCESS for ", arg[0] )
