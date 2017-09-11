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
    assert(v:fldtype() == "F8", "Currently we only support F8")
  end
  assert(type(Y) == "Column", "Y must be a column ")
  local k = #X
  -- assert(k == Y:length(), "Y must have same length as num cols of X")
  assert(Y:fldtype() == "F8", "Currently we only support F8")
  --all of y needs to be evaluated
  local y_len, yptr, nn_yptr = Y:chunk(-1)
  assert(nn_yptr == nil, "Don't support null values")
  assert(yptr)
  assert(y_len == k)
  -- STOP: verify inputs

  local coro = coroutine.create(function()
    -- malloc space for one chunk worth of output z
    local z_sz = qconsts.qtypes["F8"].width * qconsts.chunk_size
    local z_buf = assert(ffi.malloc(z_sz), "malloc failed")
   
    local status, Xptr, len
    -- malloc space for pointers to chunks of X
    local Xptr = assert(ffi.malloc(ffi.sizeof("double *") * k), "malloc failed")
    Xptr = ffi.cast("double **", Xptr)

    local cidx = 0 -- chunk index
    local last_chunk = false
    repeat 
      local len = 0
      -- assemble Xptr
      for xidx = 1, #X do
        local x_len, xptr, nn_xptr = X[xidx]:chunk(cidx) 
        if ( xidx == 1 ) then
          len = x_len
          if ( len < qconsts.chunk_size ) then
            last_chunk = true
          end
          assert(len <= qconsts.chunk_size) 
          if ( len == 0 ) then
            last_chunk = true
            break
          end
        else 
          assert(x_len == len)
        end
        assert(nn_xptr == nil, "Don't support null values")
        Xptr[xidx-1] = ffi.cast("double *", xptr)
      end
      --=================================
      if ( len > 0 ) then 
        -- mvmul_a( double ** x, double * y, double * z, int m, int k); 
        local status = qc["mvmul_a"](Xptr, yptr, z_buf, len, k)
        assert(status == 0, "C error in mvmul") 
        coroutine.yield(len, z_buf, nil)
      end
      cidx = cidx + 1
    until (last_chunk == true )
  end)

  return Column( {gen=coro, nn=false, field_type="F8"} )
end
return require('Q/q_export').export('cmvmul', cmvmul)


