local Q = require 'Q'
local qc = require 'Q/UTILS/lua/q_core'
local ffi = require 'Q/UTILS/lua/q_ffi'
local lVector = require 'Q/RUNTIME/lua/lVector'

return function(func_name, A, b)
  assert(type(A) == "table", "A should be a table of columns")
  assert(type(b) == "lVector", "b should be a column")
  assert(b:fldtype() == "F8", "b should be a column of doubles")

  for i, v in ipairs(A) do
    assert(type(v) == "lVector", "A["..i.."] should be a column")
    assert(v:fldtype() == "F8", "A["..i.."] should be a column of doubles")
  end

  local b_len, b_chunk, nn_b_chunk = b:chunk()
  local n = b_len
  assert(n > 0)
  assert(nn_b_chunk == nil, "b should have no nil elements")

  assert(#A == n, "A should have same width as b")
  --[[ Modified to following to add assert 
  local A_chunks = ffi.cast('double**', ffi.malloc(n * ffi.sizeof('double*')))
  local x_chunk = ffi.cast('double*', ffi.malloc(n * ffi.sizeof('double')))
  --]]
  local A_chunks = assert(ffi.malloc(n * ffi.sizeof('double *')))
  local x_chunk  = assert(ffi.malloc(n * ffi.sizeof('double')))
  A_chunks = ffi.cast('double **', A_chunks)
  -- Creating separate pointer copy 'x_chunk_copy' because if we modify 'x_chunk' as below
  -- x_chunk = ffi.cast('double *', x_chunk)
  -- then vec:put_chunk() operation fails saying "NOT CMEM" type, Line 329 of File vector.c
  local x_chunk_copy = ffi.cast('double *', x_chunk)
  for i = 1, n do
    local Ai_len, Ai_chunk, nn_Ai_chunk = A[i]:chunk()
    assert(Ai_len == n, "A["..i.."] should have same height as b")
    assert(nn_Ai_chunk == nil, "A["..i.."] should have no nil elements")

    A_chunks[i-1] = Ai_chunk
  end

  assert(qc[func_name], "Symbol not found " .. func_name)
  local status = qc[func_name](A_chunks, x_chunk_copy, b_chunk, n)
  assert(status == 0, "solver failed with status "..status)
  assert(qc["full_positive_solver_check"](A_chunks, x_chunk_copy, b_chunk, n, 0),
         "solution returned by solver "..func_name.." is invalid")

  local x_col = lVector({qtype = "F8", gen = true, has_nulls=false})
  x_col:put_chunk(x_chunk, nil, n)
  x_col:eov()
  return x_col
end
