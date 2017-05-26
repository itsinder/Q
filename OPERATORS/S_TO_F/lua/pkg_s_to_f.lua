
local plfile = require 'pl.file'
local s = [===[
local function <<operator>>(x)
  local status, col = pcall(expander_s_to_f, <<operator>>, x)
  assert(status, "Could not execute <<operator>>" .. col)
  return col
end
T.<<operator>> = <<operator>>
    ]===]

io.output("_f_to_s.lua")
io.write("local T = {} \n")
local ops = assert(require 'operators')
local T = {}
for i, op in ipairs(ops) do
  T[#T+1] = string.gsub(s, "<<operator>>", op)
end
local x = table.concat(T, "\n")
io.write(x)
io.write("\nreturn T\n")
io.close()
