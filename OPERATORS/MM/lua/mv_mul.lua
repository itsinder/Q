-- local dbg = require 'Q/UTILS/lua/debugger'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local lVector  = require 'Q/RUNTIME/COLUMN/code/lua/lVector'
local qconsts = require 'Q/UTILS/lua/q_consts'
local qc      = require 'Q/UTILS/lua/q_core'

-- This is matrix vector multiply, done chunks at a time 
local mv_mul = function(X, Y)
  local sp_fn_name = "Q/OPERATORS/MM/lua/" .. a .. "_specialize"
  local spfn = assert(require(sp_fn_name))
  local status, subs, tmpl = pcall(spfn, X, Y)
  if not status then print(subs) end
  assert(status, "Error in specializer " .. sp_fn_name)
  local func_name = assert(subs.fn)
  assert(qc[func_name], "Symbol not available" .. func_name)

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
      local status = qc[func_name](Xptr, yptr, z_buf, len, k)
      assert(status == 0, "C error in mvmul") 
      return len, z_buf, nn_z_buf
    else
      return 0, nil, nil
    end
  end
  return lVector( {gen = gen_fn, has_nulls = false, qtype = "F8"} )
end
return require('Q/q_export').export('cmvmul', cmvmul)


