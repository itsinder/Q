local ffi = require 'ffi'
local ffi_malloc = require 'ffi_malloc'
local q = require 'q'

function ax_equals_b(A, b)
  assert(type(A) == "table", "A should be a table of columns")
  assert(type(b) == "Column", "b should be a column")

  for i, v in ipairs(A) do
    assert(type(v) == "Column", "A["..i.."] should be a column")
  end

  local b_len, b_chunk, nn_b_chunk = b:chunk(-1)
  assert(nn_b_chunk == nil, "b should have no nil elements")

  assert(#A == b_len, "A should have same width as b")
  local A_chunks = ffi.cast('double**', ffi_malloc(b_len * ffi.sizeof('double*')))
  local x_returned = ffi.cast('double*', ffi_malloc(b_len * ffi.sizeof('double')))
  for i = 1, b_len do
    local Ai_len, Ai_chunk, nn_Ai_chunk = A[i]:chunk(-1)
    assert(Ai_len == b_len, "A["..i.."] should have same height as b")
    assert(nn_Ai_chunk == nil, "A["..i.."] should have no nil elements")

    A_chunks[i-1] = Ai_chunk
    x_returned[i-1] = 0
  end

  local status = q["positive_solver"](A_chunks, x_returned, b_chunk, b_len, 0)
  assert(status == 0, "solver failed with status "..status)

  return x_returned
end
