-- FUNCTIONAL
local Q = require 'Q'
local Scalar = require 'libsclr'
local qconsts = require 'Q/UTILS/lua/q_consts'
require('Q/UTILS/lua/cleanup')()
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function()
  local qtypes =  { "I4", "I8" }
  local shifts = { "0", "1", "2", "3", "4", "5", "6", "7"}
  -- local len = qconsts.chunk_size * 2 + 17
  local len = 17
  for _, qtype in pairs(qtypes) do 
    for _, shift in pairs(shifts) do 
      local x = Q.rand( { lb = 1, ub = 32767, qtype = qtype, len = len })
      local y = Q.shift_left(x, Scalar.new(shift, qtype))
      local mul = math.pow(2, shift)
      local z = Q.vsmul(x, Scalar.new(mul, qtype))
      -- Q.print_csv({x,y,z})
      local n1, n2 = Q.sum(Q.vveq(y, z)):eval()
      assert(n1 == n2)
    end
  end
  print("Test t1 succeeded")
end
--return tests
tests.t1()
os.exit()

