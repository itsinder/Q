-- FUNCTIONAL 
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local tests = {}
--=================================================
tests.test_const = function()
  num = (2048*1048576)-1
  local c1 = Q.const( {val = num, qtype = "I4", len = 8 })
  c1:eval()
  minval = Q.min(c1):eval()
  maxval = Q.max(c1):eval()
  assert(minval == num)
  assert(maxval == num)
  require('Q/UTILS/lua/cleanup')()
end
--=================================================
tests.test_period = function()
  n = 32768+10923
  print("n = ", n)
  len = n * 3 
  y = Q.period({start = 1, by = 2, period = 3, qtype = "I4", len = len })
  actual = Q.sum(y):eval()
  expected = (n * (1+3+5))
  asssert (actual == expected ) 
  -- TODO Krushnakant: Q.print_csv(y, nil, "")
  require('Q/UTILS/lua/cleanup')()
end
--========================================
tests.test_rand_B1 = function()
  len = 65536 * 4 
  p = 0.25;
  actual = Q.sum(Q.rand( { probability = p, qtype = "B1", len = len })):eval()
  expected = len * p
  print("len,p,actual,expected", len, p, actual, expected)
  assert( ( ( actual >= expected * 0.90 ) and
       ( actual <= expected * 1.10 ) ) )
  require('Q/UTILS/lua/cleanup')()
end
--=======================================
tests.generic = function()
  z = Q.const( { val = 5, qtype = "I4", len = 10 })
  minval = Q.min(z):eval()
  maxval = Q.max(z):eval()
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
