-- local dbg = require 'Q/UTILS/lua/debugger'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local lVector  = require 'Q/RUNTIME/lua/lVector'
local qconsts = require 'Q/UTILS/lua/q_consts'
local qc      = require 'Q/UTILS/lua/q_core'
local cmem    = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'

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
  y:eval() -- y must be fully evaluated

  local gen_fn = function(chunk_num)

    local cast_as   = nil
    local z_buf     = nil 
    local cst_z_buf = nil
    local nn_z_buf  = nil 
    local z_qtype   = subs.z_qtype
    local z_ctype   = qconsts.qtypes[z_qtype].ctype
    local z_width   = qconsts.qtypes[z_qtype].width 
    local z_sz      = z_width * qconsts.chunk_size
    local Xptr      -- pointers to chunks of X
    local first_call = true
    local y_len, yptr, nn_yptr, cst_y_buf
    local chunk_idx = 0
  
    local y_qtype = y:qtype()
    local y_ctype = qconsts.qtypes[y_qtype].ctype

    local x_qtype   = subs.x_qtype
    local x_ctype   = qconsts.qtypes[x_qtype].ctype
    -- Adding assert on chunk_idx to have sync between expected 
    -- chunk_num and generator's chunk_idx state
    assert(chunk_num == chunk_idx)
    if  ( first_call ) then 
      -- START: malloc
      cast_as = x_ctype .. " ** "
      Xptr = get_ptr(cmem.new(ffi.sizeof(cast_as) * #X))
      Xptr = ffi.cast(cast_as, Xptr)

      z_buf = assert(cmem.new(z_sz, z_qtype))
      cast_as = z_ctype .. " * "
      cst_z_buf = ffi.cast(cast_as, get_ptr(z_buf))
      -- STOP : malloc

      --all of y needs to be evaluated
      y_len, yptr, nn_yptr = y:get_all()
      assert(nn_yptr == nil, "Don't support null values")
      assert(yptr)
      assert(y_len == #X, "Y must have same length as num cols of X")
      cast_as = y_ctype .. " *"
      cst_y_buf = ffi.cast(cast_as, get_ptr(yptr))

      first_call = false
    end
    -- START: assemble Xptr
    local len = 0
    for xidx = 1, #X do
      local x_len, xptr, nn_xptr = X[xidx]:chunk(chunk_idx) 
      assert(nn_xptr == nil, "Don't support null values")
      if ( xidx == 1 ) then
        len = x_len
      else 
        assert(x_len == len)
      end
      Xptr[xidx-1] = ffi.cast(x_ctype .. " *", get_ptr(xptr))
    end
    -- STOP : assemble Xptr
    chunk_idx = chunk_idx + 1
    --=================================
    if ( len > 0 ) then 
      -- mv_mul_simple_F4_F4_F4( double ** x, double * y, double * z, int m, int k);
      local status = qc[func_name](Xptr, cst_y_buf, cst_z_buf, len, #X)
      assert(status == 0, "C error in ", func_name)
      return len, z_buf, nn_z_buf
    else
      return 0, nil, nil
    end
  end
  return lVector( {gen = gen_fn, has_nulls = false, qtype = "F8"} )
end
return require('Q/q_export').export('mv_mul', mv_mul)
