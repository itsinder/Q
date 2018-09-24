local Q         = require 'Q'
local qconsts	= require 'Q/UTILS/lua/q_consts'
local get_ptr	= require 'Q/UTILS/lua/get_ptr'
local Scalar    = require 'libsclr'

require 'Q/UTILS/lua/strict'

local tests = {}

tests.t1 = function()
  local n_idx = 65
  local n_val = n_idx

  local idx = Q.seq( {start = 0, by = 1, qtype = "I4", len = n_idx} )
  local x = Q.seq( {start = 0, by = 2, qtype = "I4", len = n_idx} )
  local y = Q.const( {val = 100,  qtype = "I4", len = n_val} )
  y:eval()

  Q.set_sclr_val_by_idx(x, y, { sclr_val = -100 })
  Q.print_csv({idx, x, y})
  --[[
  local n1, n2 = Q.sum(Q.vveq(z, exp_z)):eval()
  assert(n1:to_num() == x_length)
  assert(n2:to_num() == x_length)
  --]]
  print("Successfully completed t1")
end
return tests
