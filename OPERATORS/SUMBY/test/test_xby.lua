local Q = require 'Q'
local qconsts = require 'Q/UTILS/lua/q_consts'
require 'Q/UTILS/lua/strict'

local tests = {}

tests.t1 = function()
  local len = qconsts.chunk_size + 1
  -- set len to more than a chunk and so that exp_rslt for numby is correct
  while ( ( len % 3 ) != 1 ) do
    len = len + 1
  end
  local a = Q.period({ len = len, start = 10, by = 10, period = 6, qtype = "I4"})
  -- a has values 10, 20, 30, 40, 50, 60, 10, 20, 30, 40, 50, 60, ...
  local b = Q.seq({ len = len, start = 1, by = 2, qtype = "I4"}):eval()
  -- a has values 1, 3, 5
  operators = { "min", "max", "num" }
  for k, operator in ipairs(operators ) do 
    local rslt, exp_rslt
    if ( operator == "min" ) then 
      rslt = Q.minby(a, b, b:length(), {is_safe = false})
      exp_rslt = Q.mk_col({10, 20, 30}, "I4")
    elseif ( operator == "max" ) then 
      rslt = Q.maxby(a, b, b:length(), {is_safe = false})
      exp_rslt = Q.mk_col({40, 50, 60}, "I4")
    elseif ( operator == "num" ) then 
      rslt = Q.numby(a, b, b:length(), {is_safe = false})
      local x = len / 3 
      exp_rslt = Q.mk_col({x+1, x, x}, "I4")
    else
      assert(nil)
    end
    -- verify
    assert(rslt:length() == nb)
    local n1, n2 = Q.sum(Q.vvneq(rslt, exp_rslt)):eval()
    assert(n1 == 0)
  end
  print("Test t1 completed")
end
