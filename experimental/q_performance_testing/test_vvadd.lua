local Q = require 'Q'
local qconsts = require 'Q/UTILS/lua/q_consts'

local file_name = "profile_result.txt"

local len = 65536*2
local in_table = {}
for i = 1, len do
  in_table[i] = i
end

local col1 = Q.mk_col(in_table, "I4")
local col2 = Q.mk_col(in_table, "I4")

local qc = require 'Q/UTILS/lua/q_core'
local start_time, stop_time, time
start_time = qc.get_time_usec()

for i = 1, 5000 do
  local vvadd_res = Q.vvadd(col1, col2):eval()
end

stop_time = qc.get_time_usec()
print("vvadd total execution time : " .. tostring(tonumber(stop_time-start_time)/1000000))

print("=========================")

for i, v in pairs(_G['g_time']) do
  print(i, tostring(tonumber(v)/1000000))
end

