
local plfile = require 'pl.file'
local s = [===[
local function <<operator>>(x)
  if type(x) == "Column" then
    local status, numer, denom = pcall(expander_f_to_s, <<operator>>, x)
    if ( not status ) then print(col) end
    assert(status, "Could not execute <<operator>>")
    return numer, denom
  end
end
T.<<operator>> = <<operator>>
require('Q/q_export').export('<<operator>>', <<operator>>)
    ]===]

io.output("_f_to_s.lua")
io.write("local T = {} \n")
local ops = assert(require 'Q/OPERATORS/F_TO_S/lua/operators')
local T = {}
for i, op in ipairs(ops) do
  T[#T+1] = string.gsub(s, "<<operator>>", op)
end
local x = table.concat(T, "\n")
io.write(x)
io.write("\nreturn T\n")
io.close()
