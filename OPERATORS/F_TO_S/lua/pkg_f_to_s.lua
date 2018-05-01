
local plfile = require 'pl.file'
local s = [===[
local function <<operator>>(x, y)
  assert(type(x) == "lVector", "input must be of type lVector")
  local expander = assert(require 'Q/OPERATORS/F_TO_S/lua/expander_f_to_s')
  local status, z = pcall(expander, "<<operator>>", x, y)
  if ( not status ) then print(z) end
  assert(status, "Could not execute <<operator>>")
  return z
end
T.<<operator>> = <<operator>>
require('Q/q_export').export('<<operator>>', <<operator>>)
    ]===]

local avg_string = [[
local function avg(x, y)
  local Q = require 'Q'
  local Scalar = require 'libsclr'
  assert(type(x) == "lVector", "input must be of type lVector")
  local sum, count = Q.sum(x):eval()
  local avg = sum:to_num() / count:to_num()
  local z = Scalar.new(avg, "F8")
  return z
end
T.avg = avg
require('Q/q_export').export('avg', avg)
]]

io.output("_f_to_s.lua")
io.write("local T = {} \n")
local ops = assert(require 'Q/OPERATORS/F_TO_S/lua/operators')
local T = {}
for i, op in ipairs(ops) do
  T[#T+1] = string.gsub(s, "<<operator>>", op)
end
local x = table.concat(T, "\n")
io.write(x)
io.write("\n" .. avg_string)
io.write("\nreturn T\n")
io.close()
