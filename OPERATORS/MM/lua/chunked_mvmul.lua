-- local dbg = require 'Q/UTILS/lua/debugger'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local Column  = require 'Q/RUNTIME/COLUMN/code/lua/Column'
local qconsts = require 'Q/UTILS/lua/q_consts'
local qc      = require 'Q/UTILS/lua/q_core'

local cmvmul = function(X, Y)
  -- START: verify inputs
  assert(type(X) == "table", "X must be a table ")
  local m = nil
  for k, v in ipairs(X) do 
    assert(type(v) == "Column", "each element of X must be a column")
    local l_m = v:length()
    -- assert(l_m > 0, "column must have positive length")
    if not m then 
      m = l_m  
    else 
      -- assert(m == l_m, "All columns must have same length")
    end
    assert(v:fldtype() == "F8", "Currently we only support F8")
  end
  assert(type(Y) == "Column", "Y must be a column ")
  local k = #X
  -- assert(k == Y:length(), "Y must have same length as num cols of X")
  assert(Y:fldtype() == "F8", "Currently we only support F8")
  -- STOP: verify inputs


  --all of y needs to be evaluated
  local y_len, yptr, nn_yptr = Y:chunk(-1)
  assert(nn_yptr == nil, "Don't support null values")
  assert(yptr)
  assert(y_len == k)

  local chunk_size = qconsts.chunk_size
  local num_blocks = math.ceil( m / chunk_size )

  local coro = coroutine.create(function()
   
    local status, zptr, Xptr, len

    for i = 1,num_blocks do

      len = chunk_size
      if( i == num_blocks ) then
        len = m % chunk_size
      end
    
      zptr = assert(ffi.malloc(qconsts.qtypes["F8"].width * len), "malloc failed")
      Xptr = assert(ffi.malloc(ffi.sizeof("double *") * k), "malloc failed")
      Xptr = ffi.cast("double **", Xptr)
      
      --TODO FIX THIS FOR LOOP
      for xidx = 1, #X do
        local x_len, xptr, nn_xptr = X[xidx]:chunk(i) -- TODO check this line
        assert(x_len == len)
        assert(nn_xptr == nil, "Don't support null values")
        Xptr[xidx-1] = ffi.cast("double *", xptr)
      end

      local status = qc["mvmul_a"](Xptr, yptr, zptr, len, k)
      assert(status == 0, "C error in mvmul")
      coroutine.yield(len, zptr, nil)
    end
  end)

  -- mvmul_a( double ** x, double * y, double * z, int m, int k); 
  return Column( {gen=coro, nn=(nn_zptr ~= nil), field_type="F8"} )
end
return require('Q/q_export').export('cmvmul', cmvmul)


