local Q_core = require 'Q/UTILS/lua/q_core'
local ffi = require 'Q/UTILS/lua/q_ffi'
local Column = require 'Q/RUNTIME/COLUMN/code/lua/Column'
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
  local A_chunks = ffi.cast('double**', ffi.malloc(n * ffi.sizeof('double*')))
  local x_chunk = ffi.cast('double*', ffi.malloc(n * ffi.sizeof('double')))
  for i = 1, n do
    local Ai_len, Ai_chunk, nn_Ai_chunk = A[i]:chunk(-1)
    assert(Ai_len == n, "A["..i.."] should have same height as b")
    assert(nn_Ai_chunk == nil, "A["..i.."] should have no nil elements")

    A_chunks[i-1] = Ai_chunk
  end

  local status = Q_core[func_name](A_chunks, x_chunk, b_chunk, n)
  assert(status == 0, "solver failed with status "..status)
  assert(Q_core["full_positive_solver_check"](A_chunks, x_chunk, b_chunk, n, 0),
         "solution returned by solver "..func_name.." is invalid")

  local x_col = Column({field_type = "F8", write_vector = true})
  x_col:put_chunk(n, x_chunk)
  x_col:eov()
  return x_col
end
