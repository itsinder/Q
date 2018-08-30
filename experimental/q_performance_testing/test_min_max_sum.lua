local Q = require 'Q'
local Vector = require 'libvec'
local Scalar = require 'libsclr'
local qconsts = require 'Q/UTILS/lua/q_consts'
local qc = require 'Q/UTILS/lua/q_core'

local len = qconsts.chunk_size*5

--[[
local in_table = {}
for i = 1, len do
  in_table[i] = i
end

local col1 = Q.mk_col(in_table, "I4", nil):set_name("col1")
]]
local col1 = Q.rand( { lb = 100, ub = len, qtype = "I4", len = len } )
local start_time, stop_time, time

Vector.reset_timers()
start_time = qc.get_time_usec()
for i = 1, 10000 do
  local x = Q.min(col1)
  x:eval()
  min, total, index = x:value()
  -- print(min:to_num())
end
stop_time = qc.get_time_usec()
Vector.print_timers()

print("min total execution time : " .. tostring(tonumber(stop_time-start_time)/1000000))

print("=========================")
if _G['g_time'] then
  for k, v in pairs(_G['g_time']) do
    local niters  = _G['g_ctr'][k] or "unknown"
    local ncycles = tonumber(v)
    print("0," .. k .. "," .. niters .. "," .. ncycles)
  end
end

os.exit()
