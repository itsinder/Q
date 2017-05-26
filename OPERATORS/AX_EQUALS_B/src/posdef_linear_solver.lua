local q = require 'q'
local allocator = dofile('linear_solver_allocator.lua')

return function(A, b)
  A_chunks, x_chunk, b_chunk, n = allocator(A, b)

  local status = q["full_posdef_positive_solver"](A_chunks, x_chunk, b_chunk, n)
  assert(status ~= 1, "solver failed to find a solution")
  assert(status == 0, "solver failed with status "..status)

  return x_chunk
end
