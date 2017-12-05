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
 
  -- run time checks not made in compile time specializer
  assert(y:is_eov(), "y must be fully evaluated")

  local z_buf = nil 
  local nn_z_buf = nil 
  local z_qtype = subs.z_qtype
  local z_sz = qconsts.qtypes[z_qtype].width * qconsts.chunk_size
  local Xptr -- malloc space for pointers to chunks of X
  local first_call = true
  local y_len, yptr, nn_yptr 
  local chunk_idx = 0
  
  local gen_fn = function()
    if  ( first_call ) then 
      -- print("malloc'ing for generator of mv_mul")
      -- START: malloc
      Xptr = ffi.malloc(ffi.sizeof("double *") * #X)
      assert(Xptr, "malloc failed")
      Xptr = ffi.cast("double **", Xptr)

      z_buf = ffi.malloc(z_sz)
      assert(z_buf, "malloc failed")
      -- STOP : malloc

      --all of y needs to be evaluated
      y_len, yptr, nn_yptr = y:get_all()
      assert(nn_yptr == nil, "Don't support null values")
      assert(yptr)
      assert(y_len == #X, "Y must have same length as num cols of X")

      first_call = false
    end
    local len = 0
    -- START: assemble Xptr
    for xidx = 1, #X do
      local x_len, xptr, nn_xptr = X[xidx]:chunk(chunk_idx) 
      assert(nn_xptr == nil, "Don't support null values")
      if ( xidx == 1 ) then
        len = x_len
      else 
        assert(x_len == len)
      end
      Xptr[xidx-1] = ffi.cast("double *", xptr)
    end
    -- STOP : assemble Xptr
    chunk_idx = chunk_idx + 1
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
