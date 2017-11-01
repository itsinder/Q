-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local c_to_txt = require 'Q/UTILS/lua/C_to_txt'

local a = Q.mk_col({10, 20, 30, 40, 50}, "I4") 
local b = Q.mk_col({1, 0, 0, 1, 0}, "B1")

local out_table = {10, 40}

local c = Q.where(a, b)
c:eval()

assert(c:length() == Q.sum(b):eval(), "Length Mismatch")

for i = 1, c:length() do
  local value = c_to_txt(c, i)
  assert(value == out_table[i])
end

Q.print_csv(c, nil, "")
--======================================

print("=======================================")
b = Q.mk_col({0, 0, 0, 0, 0}, "B1")
local c = Q.where(a, b)
c:eval()

assert(c:length() == 0, "Length Mismatch")
--======================================
print("=======================================")
b = Q.mk_col({1, 1, 1, 1, 1}, "B1")

local out_table = {10, 20, 30, 40, 50}

local c = Q.where(a, b)
c:eval()

assert(c:length() == Q.sum(b):eval(), "Length Mismatch")

for i = 1, c:length() do
  local value = c_to_txt(c, i)
  assert(value == out_table[i])
end

Q.print_csv(c, nil, "")
--======================================
print("=======================================")
b = Q.mk_col({0, 0, 0, 0, 0}, "B1")
b:set_meta("min", 0)
b:set_meta("max", 0)
local c = Q.where(a, b)
assert(c == nil)

--======================================
print("=======================================")
b = Q.mk_col({1, 1, 1, 1, 1}, "B1")
b:set_meta("min", 1)
b:set_meta("max", 1)
local c = Q.where(a, b)
assert(c == a)
--======================================
--[[
print("=======================================")
-- Set CHUNK_SIZE to 64
-- Then below will be a case where more than chunk size values present in a and b

local a = Q.mk_col({10, 20, 30, 40, 50, 10, 20, 30, 40, 50, 10, 20, 30, 40, 50, 10, 20, 30, 40, 50, 10, 20, 30, 40, 50, 10, 20, 30, 40, 50, 10, 20, 30, 40, 50, 10, 20, 30, 40, 50, 10, 20, 30, 40, 50, 10, 20, 30, 40, 50, 10, 20, 30, 40, 50, 10, 20, 30, 40, 50, 10, 20, 30, 40, 50, 10, 20, 30, 40, 50}, "I4") 

local b = Q.mk_col({1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,}, "B1")

local out_table = {10, 40, 50}

local c = Q.where(a, b)
c:eval()

assert(c:length() == Q.sum(b):eval(), "Length Mismatch")

for i = 1, c:length() do
  local value = c_to_txt(c, i)
  assert(value == out_table[i])
end

-- Q.print_csv(c, nil, "")
]]
--======================================
print("SUCCESS for ", arg[0])
require('Q/UTILS/lua/cleanup')()
os.exit()

