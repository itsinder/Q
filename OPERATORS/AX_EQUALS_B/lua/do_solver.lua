local Q = require 'Q/UTILS/lua/q'
local Q_core = require 'Q/UTILS/lua/q_core'
local mk_col = require 'Q/OPERATORS/MK_COL/lua/mk_col'

return function(func_name, A, b)
  assert(type(A) == "table", "A should be a table of columns")
  assert(type(b) == "Column", "b should be a column")
  assert(b:fldtype() == "F8", "b should be a column of doubles")

  for i, v in ipairs(A) do
    assert(type(v) == "Column", "A["..i.."] should be a column")
    assert(v:fldtype() == "F8", "A["..i.."] should be a column of doubles")
  end

  local b_len, b_chunk, nn_b_chunk = b:chunk(-1)
  local n = b_len
  assert(nn_b_chunk == nil, "b should have no nil elements")

  assert(#A == n, "A should have same width as b")
  local A_chunks = Q_core.cast('double**', Q_core.malloc(n * Q_core.sizeof('double*')))
  local x_chunk = Q_core.cast('double*', Q_core.malloc(n * Q_core.sizeof('double')))
  for i = 1, n do
    local Ai_len, Ai_chunk, nn_Ai_chunk = A[i]:chunk(-1)
    assert(Ai_len == n, "A["..i.."] should have same height as b")
    assert(nn_Ai_chunk == nil, "A["..i.."] should have no nil elements")

    A_chunks[i-1] = Ai_chunk
  end

  local status = Q[func_name](A_chunks, x_chunk, b_chunk, n)
  assert(status == 0, "solver failed with status "..status)
  assert(Q["full_positive_solver_check"](A_chunks, x_chunk, b_chunk, n, 0),
         "solution returned by solver "..func_name.." is invalid")

  local x = {}
  for i = 1, n do
    x[i] = x_chunk[i-1]
  end

  return mk_col(x, "F8")
end
