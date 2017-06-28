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
    iter = 1
    repeat 
      print("Iteration = ", iter)
      iter = iter + 1
      local len = 0
      -- assemble Xptr
      for xidx = 1, #X do
        local x_len, xptr, nn_xptr = X[xidx]:chunk(cidx) 
        local new_chunk = ffi.cast("double*", xptr)
        --[[print(new_chunk[0])
        print(new_chunk[1])
        print(new_chunk[2])
        --]]
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
      print("len", x_len)
      for o=1,2 do
        for p=1,3 do
          print(o, p, Xptr[o-1][p-1])
        end
      end
      --=================================
      if ( len > 0 ) then 
        -- mvmul_a( double ** x, double * y, double * z, int m, int k); 
        local status = qc["mvmul_a"](Xptr, yptr, z_buf, len, k)
        assert(status == 0, "C error in mvmul") coroutine.yield(len, z_buf, nil)
        local zptr = ffi.cast("double *", z_buf)
        for i = 1, 3 do 
          print("Z ", i, zptr[i-1])
        end
        local yyptr = ffi.cast("double *", yptr)
        for i = 1, 2 do 
          print("Y ", i, yyptr[i-1])
        end
      end
      cidx = cidx + 1
      print("last chunk", last_chunk)
    until (last_chunk == true )
  end)

  return Column( {gen=coro, nn=(nn_zptr ~= nil), field_type="F8"} )
end
return require('Q/q_export').export('cmvmul', cmvmul)


