
local plfile = require 'pl.file'
local s = [===[
local function <<operator>>(x, y, optargs)
  if type(x) == "Column" and type(y) == "Column" then
    local status, col = pcall(expander_f1f2opf3, "<<operator>>", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute <<operator>>")
    return col
  end
end
T.<<operator>> = <<operator>>
    ]===]

io.output("_f1f2opf3.lua")
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
