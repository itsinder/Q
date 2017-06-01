local do_solver = require 'Q/OPERATORS/AX_EQUALS_B/lua/do_solver'

return function(A, b)
  return do_solver("full_posdef_positive_solver", A, b)
end
