local Q = require 'Q'

local M = dofile './meta_eee.lua'
local optargs = { is_hdr = true }
local datadir = "./data/"
local niters = 1
for i = 1, niters do 
  local T_eee = Q.load_csv(datadir .. "eee_1.csv", M, optargs)
  local uuid = T_eee[1]
  assert(type(uuid) == "lVector")
  print("Loaded with C", i)
  print("=====================================")
end
print("DONE Loaded with C")
--==== Repeat as pure Lua code 
optargs = { is_hdr = true, use_accelerator = false }
for i = 1, niters do 
  T_eee = Q.load_csv(datadir .. "eee_1.csv", M, optargs)
  local uuid = T_eee[1]
  assert(type(uuid) == "lVector")
  print("Loaded with Lua", i)
end
-- Q.print_csv(ccid)
print("ALL DONE")
os.exit()
