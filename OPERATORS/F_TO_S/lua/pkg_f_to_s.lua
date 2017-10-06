
local plfile = require 'pl.file'
local s = [===[
local function <<operator>>(x)
  if type(x) == "lVector" then
    local expander = assert(require 'Q/OPERATORS/F_TO_S/lua/expander_f_to_s')
    -- y is a Scalar
    local status, y = pcall(expander, "<<operator>>", x)
    if ( not status ) then print(y) end
    assert(status, "Could not execute <<operator>>")
    return y
  end
  assert(nil, "input must be of type lVector")
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
