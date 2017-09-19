-- local dbg = require 'Q/UTILS/lua/debugger'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local lVector  = require 'Q/RUNTIME/COLUMN/code/lua/lVector'
local qconsts = require 'Q/UTILS/lua/q_consts'
local qc      = require 'Q/UTILS/lua/q_core'

-- This is matrix vector multiply, done chunks at a time 
local mv_mul = function(X, Y)
  -- START: verify inputs
  assert(type(X) == "table", "X must be a table of lVectors")
  local m = nil
  for k, v in ipairs(X) do 
    assert(type(v) == "lVector", "each element of X must be a lVector")
    assert(((v:qtype() == "F8") or (v:qtype()== "F4")), 
      "qtype must be F4 or F8")
  end
  assert(type(Y) == "lVector", "Y must be a lVector ")
  local k = #X
  -- assert(k == Y:length(), "Y must have same length as num cols of X")
  --all of y needs to be evaluated
  assert(((Y:qtype() == "F8") or (Y:qtype()== "F4")), 
      "qtype of Y must be F4 or F8")
  local y_len, yptr, nn_yptr = Y:get_all()
  assert(nn_yptr == nil, "Don't support null values")
  assert(yptr)
  assert(y_len == k)
  -- STOP: verify inputs

  -- START: malloc
    -- malloc space for one chunk worth of output z
    local z_sz = qconsts.qtypes["F8"].width * qconsts.chunk_size
    local z_buf = assert(ffi.malloc(z_sz), "malloc failed")
    local nn_z_buf = nil -- since no nils in output
    local Xptr -- malloc space for pointers to chunks of X
    local Xptr = assert(ffi.malloc(ffi.sizeof("double *") * k), "malloc failed")
    Xptr = ffi.cast("double **", Xptr)
  -- STOP : malloc

  local gen_fn = function(chunk_idx)
    local len = 0
    -- START: assemble Xptr
    for xidx = 1, #X do
      local x_len, xptr, nn_xptr = X[xidx]:chunk(chunk_idx) 
      assert(nn_xptr == nil, "Don't support null values")
      if ( xidx == 1 ) then
        len = x_len
        assert(x_len <= qconsts.chunk_size) 
      else 
        assert(x_len == len)
      end
      Xptr[xidx-1] = ffi.cast("double *", xptr)
    end
    -- STOP : assemble Xptr
    --=================================
    if ( len > 0 ) then 
      -- mvmul_a( double ** x, double * y, double * z, int m, int k); 
      local status = qc["mvmul_a"](Xptr, yptr, z_buf, len, k)
      assert(status == 0, "C error in mvmul") 
      return len, z_buf, nn_z_buf
    else
      return 0, nil, nil
    end
  end
  return lVector( {gen = gen_fn, has_nulls = false, qtype = "F8"} )
end
return require('Q/q_export').export('cmvmul', cmvmul)


