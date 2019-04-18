local Q = require 'Q'
local dload = require 'Q/MULTI_DIM/lua/dload'
local mk_ab = require 'Q/MULTI_DIM/lua/mk_ab'

local T, M = dload()
local n
for k, v in pairs(T) do 
  n = v:length() 
end

local a, b = mk_ab(n, 0.4)
local grp_by = { "f1", "f2", "f3", "f4" }
local avals = {}
for k, v in pairs(grp_by) do 
  avals[k] = Q.sumby_where(T[k], xxx, nxx, { where = a })
  bvals[k] = Q.sumby_where(T[k], xxx, nxx, { where = b })
end

print("Successfully completed")
