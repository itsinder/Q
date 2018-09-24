local Q         = require 'Q'
local qconsts	= require 'Q/UTILS/lua/q_consts'
local get_ptr	= require 'Q/UTILS/lua/get_ptr'
local Scalar    = require 'libsclr'

require 'Q/UTILS/lua/strict'

local tests = {}

tests.t1 = function()
  local n_src = 65

  local x = Q.seq( {start = 10, by = 1, qtype = "I4", len = n_src} )
  local y = Q.seq( {start = 1, by = 1, qtype = "I4", len = n_src} ):eval()

  local z = Q.get_idx_by_val(x, y)
  Q.print_csv({x, z})
  -- local n1, n2 = Q.sum(Q.vveq(z, exp_z)):eval()
  -- assert(n1:to_num() == x_length)
  -- assert(n2:to_num() == x_length)
  print("Successfully completed t1")
end
return tests
