-- local dbg = require 'Q/UTILS/lua/debugger'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local lVector  = require 'Q/RUNTIME/lua/lVector'
local qconsts = require 'Q/UTILS/lua/q_consts'
local qc      = require 'Q/UTILS/lua/q_core'

-- This is matrix vector multiply, done chunks at a time 
local mv_mul = function(X, y)
  local sp_fn_name = "Q/OPERATORS/MM/lua/mv_mul_specialize"
  local spfn = assert(require(sp_fn_name))
  local status, subs, tmpl = pcall(spfn, X, y)
  if not status then print(subs) end
  assert(status, "Error in specializer " .. sp_fn_name)
  local func_name = assert(subs.fn)
  assert(qc[func_name], "Symbol not available" .. func_name)
  --

  local z_buf = nil 
  local nn_z_buf = nil 
  local ztype = "F8" -- hard coded for now
  local z_sz = qconsts.qtypes[ztype].width * qconsts.chunk_size
  local Xptr -- malloc space for pointers to chunks of X
  local first_call = true
  local y_len, yptr, nn_yptr 

  local gen_fn = function(chunk_idx)
    if  ( first_call ) then 
      -- print("malloc'ing for generator of mv_mul")
      -- START: malloc
      -- malloc space for one chunk worth of output z
      Xptr = ffi.malloc(ffi.sizeof("double *") * #X)
      Xptr = ffi.cast("double **", Xptr)
      -- STOP : malloc
      z_buf = ffi.malloc(z_sz)

      --all of y needs to be evaluated
      y_len, yptr, nn_yptr = y:chunk()
      assert(nn_yptr == nil, "Don't support null values")
      assert(yptr)
      assert(y_len == #X, "Y must have same length as num cols of X")

      first_call = false
    end
    assert(z_buf, "malloc failed")
    assert(Xptr, "malloc failed")
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
      -- mv_mul_simple_F4_F4_F4( double ** x, double * y, double * z, int m, int k); 
      local status = qc[func_name](Xptr, yptr, z_buf, len, #X)
      assert(status == 0, "C error in ", func_name)
      return len, z_buf, nn_z_buf
    else
      return 0, nil, nil
    end
  end
  return lVector( {gen = gen_fn, has_nulls = false, qtype = "F8"} )
end
return require('Q/q_export').export('mv_mul', mv_mul)


