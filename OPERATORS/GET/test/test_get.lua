local Q         = require 'Q'
local qconsts	= require 'Q/UTILS/lua/q_consts'
local get_ptr	= require 'Q/UTILS/lua/get_ptr'
local Scalar    = require 'libsclr'

require 'Q/UTILS/lua/strict'

local tests = {}

tests.t1 = function()
  local x_length = 65
  local y_length = 80

  local x = Q.seq( {start = 1, by = 1, qtype = "I4", len = x_length} )
  local y = Q.seq( {start = 2, by = 2, qtype = "I4", len = y_length} )
  local exp_z = Q.seq( {start = 4, by = 2, qtype = "I4", len = x_length} )
  y:eval()

  local z = Q.get(x, y)
  -- Q.print_csv({x, z, exp_z})
  local n1, n2 = Q.sum(Q.vveq(z, exp_z)):eval()
  assert(n1:to_num() == x_length)
  assert(n2:to_num() == x_length)
  print("Successfully completed t1")
end
tests.t2 = function()
  local x_length = 65
  local y_length = 30

  local x = Q.seq( {start = 0, by = 1, qtype = "I4", len = x_length} )
  local y = Q.seq( {start = 2, by = 2, qtype = "I4", len = y_length} )
  y:eval()

  local null_val = Scalar.new(1000, "I4")
  local z = Q.get(x, y, { null_val = null_val})
  -- TODO Write invariant for test Q.print_csv({x, z})
  print("Successfully completed t2")
end
return tests
