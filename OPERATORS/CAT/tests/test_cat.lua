local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local tests = {}

tests.t1 = function()
  local x_length = 10
  local y_length = 20

  local x = Q.seq( {start = 1, by = 1, qtype = "I4", len = x_length} )
  local y = Q.seq( {start = 1, by = 1, qtype = "I4", len = y_length} )

  local z = Q.cat(x, y)
  assert(z:length() == (x_length + y_length))
  
--  for i = 1, z:length() do
--    if i <= x_length then
--      
--    end
--  end
  Q.print_csv(z, nil, "")
end

return tests