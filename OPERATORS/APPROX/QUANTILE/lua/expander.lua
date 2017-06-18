
local ffi = require "Q/UTILS/lua/q_ffi"
local Column = require 'Q/RUNTIME/COLUMN/code/lua/Column'
local qconsts = require 'Q/UTILS/lua/q_consts'
local qc = require "Q/UTILS/lua/q_core"

assert(type(x) == "Column")
local qtype = x:fldtype()
local func_name = "approx_quantile_" .. qtype 

local approx_quantile = function(x, args)
  -- START: verify inputs
  local siz = x:length()
  local is_base_qtype = assert(require 'Q/UTILS/lua/is_base_qtype')
  assert(is_base_qtype(qtype))
  assert(type(siz) == "number")
  assert( siz > 0, "vector length must be positive")
  
  assert(type(args) == "table")
  local num_quantiles = assert(args.num_quantiles, "num quantiles is a required argument")
  num_quantiles = assert(tonumber(num_quantiles), "num quantiles must be a number")
  assert(num_quantiles > 2, "num quantiles must be positive and greater than 2")
  assert( num_quantiles < siz, "cannot have more quantiles than numbers")
  
  local err = args.err
  if ( err == nil ) then
    err = 0.01
  else 
    err = assert(tonumber(err), "error rate must be a number")
    assert( err >= 0 and err <= 1, "error must be a decimal")
  end
  
  local cfld = args.where
  if ( cfld ) then 
    assert(type(cfld) == "Column")
    assert(cfld:fldtype() == "B1")
    assert(nil, "TODO NOT IMPLEMENTED") -- TODO FIX THIS
  end
  -- STOP: verify inputs
  
  local ptr_est_is_good = assert(ffi.malloc(ffi.sizeof(int)), "malloc failed")
  ptr_est_is_good = ffi.cast("int *", ptr_est_is_good)

  local ctype = qconsts.qtypes[qtype].ctype
  local yptr = assert(ffi.malloc(num_quantiles*ffi.sizeof(ctype)), "malloc failed")
  
  local x_len, xptr, nn_xptr = x:chunk(-1)

  qc[func_name](xptr, cfld, siz, num_quantiles, err, yptr, ptr_est_is_good)

end


return require('Q/q_export').export('approx_quantile', approx_quantile)
