-- FUNCTIONAL 
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local tests = {}
--=================================================
tests.test_const = function()
  local num = (2048*1048576)-1
  local c1 = Q.const( {val = num, qtype = "I4", len = 8 })
  c1:eval()
  local minval = Q.min(c1):eval()
  local maxval = Q.max(c1):eval()
  assert(minval == num)
  assert(maxval == num)
  require('Q/UTILS/lua/cleanup')()
end
--=================================================
tests.test_period = function()
  local n = 32768+10923
  print("n = ", n)
  local len = n * 3 
  local y = Q.period({start = 1, by = 2, period = 3, qtype = "I4", len = len })
  local actual = Q.sum(y):eval()
  local expected = (n * (1+3+5))
  assert (actual == expected ) 
  -- TODO Krushnakant: Q.print_csv(y, nil, "")
  require('Q/UTILS/lua/cleanup')()
end
--========================================
tests.test_rand_B1 = function()
  local len = 65536 * 4 
  local p = 0.25;
  local actual = Q.sum(Q.rand( { probability = p, qtype = "B1", len = len })):eval()
  local expected = len * p
  print("len,p,actual,expected", len, p, actual, expected)
  assert( ( ( actual >= expected * 0.90 ) and
       ( actual <= expected * 1.10 ) ) )
  require('Q/UTILS/lua/cleanup')()
end
--=======================================
tests.generic = function()
  local z = Q.const( { val = 5, qtype = "I4", len = 10 })
  local minval = Q.min(z):eval()
  local maxval = Q.max(z):eval()
  assert(minval == 5)
  assert(maxval == 5)
  --========================================
  z = Q.rand( { lb = 100, ub = 200, seed = 1234, qtype = "I4", len = 10 })
  minval = Q.min(z):eval()
  maxval = Q.max(z):eval()
  assert(minval >= 100)
  assert(maxval <= 200)
  --========================================
  z = Q.rand( { lb = 0, ub = 1, qtype = "F8", len = 3 } )
  minval = Q.min(z):eval()
  maxval = Q.max(z):eval()
  assert(minval >= 0)
  assert(maxval <= 1)
  --========================================
  z = Q.seq( {start = -1, by = 5, qtype = "I4", len = 10} )
  minval = Q.min(z):eval()
  maxval = Q.max(z):eval()
  assert(minval == -1)
  assert(maxval == 44)
  --=======================================
  require('Q/UTILS/lua/cleanup')()
end

return tests
