local Q         = require 'Q'
local qconsts	= require 'Q/UTILS/lua/q_consts'
local get_ptr	= require 'Q/UTILS/lua/get_ptr'

require 'Q/UTILS/lua/strict'

local tests = {}

tests.t1 = function()
  local x_length = 65
  local y_length = 80

  local x = Q.seq( {start = 1, by = 1, qtype = "I4", len = x_length} )
  local y = Q.seq( {start = 1, by = 1, qtype = "I4", len = y_length} )
  y:eval()

  local z = Q.get(x, y)
  Q.print_csv({x, z})
  print("Successfully completed t1")
end
return tests
