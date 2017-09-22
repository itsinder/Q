local s = [===[
local function <<operator>>(x, y, optargs)
  local expander = require 'Q/OPERATORS/AINB/lua/expander_ainb'
  if type(x) == "lVector" and type(y) == "lVector" then
    local status, col = pcall(expander, "<<operator>>", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute <<operator>>")
    return col
  end
  assert(nil, "Bad arguments to ainb")
end
T.<<operator>> = <<operator>>
require('Q/q_export').export('<<operator>>', <<operator>>)
    ]===]

io.output("_ainb.lua")
io.write("local T = {} \n")
local ops = assert(require 'Q/OPERATORS/AINB/lua/operators')
local T = {}
for i, op in ipairs(ops) do
  T[#T+1] = string.gsub(s, "<<operator>>", op)
  loadstring(T[#T])
end
local x = table.concat(T, "\n")
io.write(x)
io.write("\nreturn T\n")
io.close()
-- TODO Is it necessary to create a file? Will the loadstring be enough
