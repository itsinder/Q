local Q       = require 'Q'
local qc      = require 'Q/UTILS/lua/q_core'
local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local lVector = require 'Q/RUNTIME/lua/lVector'

return function(func_name, A, b)
  print(func_name)
  -- TODO change positive_solver to to general_linear_solver
  assert( ( func_name == "positive_solver") or 
          ( func_name == "posdef_linear_solver") )
  assert(type(A) == "table", "A should be a table of columns")
  assert(type(b) == "lVector", "b should be a column")
  local b_qtype = b:fldtype()
  local b_ctype = assert(qconsts.qtypes[b_qtype].ctype)

  assert( (b_qtype == "F4") or (b_qtype == "F8"), 
  "b should be a column of doubles/floats")

  for i, v in ipairs(A) do
    assert(type(v) == "lVector", "A["..i.."] should be a column")
    assert(v:fldtype() == b_qtype, 
      "A["..i.."] should be a column of same type as b")
  end

  local n, b_chunk, nn_b_chunk = b:chunk()
  assert(n > 0)
  assert(nn_b_chunk == nil, "b should have no nil elements")

  assert(#A == n, "A should have same width as b")
  local Aptr = assert(ffi.malloc(n * ffi.sizeof(b_ctype .. " *")))
  local xptr = assert(ffi.malloc(n * ffi.sizeof(b_ctype .. " *")))
  Aptr = ffi.cast(b_ctype .. " **", Aptr)
  -- Creating separate pointer copy 'copy_xptr' because if we 
  -- modify 'xptr' as below
  -- xptr = ffi.cast('double *', xptr)
  -- then vec:put_chunk() operation fails saying 
  -- "NOT CMEM" type, Line 329 of File vector.c
  local copy_xptr = ffi.cast(b_ctype .. " *", xptr)
  for i = 1, n do
    local Ai_len, Ai_chunk, nn_Ai_chunk = A[i]:chunk()
    assert(Ai_len == n, "A["..i.."] should have same height as b")
    assert(nn_Ai_chunk == nil, "A["..i.."] should have no nil elements")
    Aptr[i-1] = Ai_chunk
  end

  assert(qc[func_name], "Symbol not found " .. func_name)
  local status = qc[func_name](Aptr, copy_xptr, b_chunk, n)
  assert(status == 0, "solver failed")
  assert(qc["full_positive_solver_check"](Aptr, copy_xptr, b_chunk, n, 0),
         "solution returned by solver "..func_name.." is invalid")

  local x_col = lVector({qtype = b_qtype, gen = true, has_nulls=false})
  x_col:put_chunk(xptr, nil, n)
  x_col:eov()
  return x_col
end
