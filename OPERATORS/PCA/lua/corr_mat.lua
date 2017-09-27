local lVector = require 'Q/RUNTIME/lua/lVector'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local qconsts = require 'Q/UTILS/lua/q_consts'
local qc      = require 'Q/UTILS/lua/q_core'

local function corr_mat(X)
  -- X is an n by m matrix (table of lua column)
  -- START: verify inputs
  assert(type(X) == "table", "X must be a table ")
  local n = nil
  for k, v in ipairs(X) do
    assert(type(v) == "lVector", "Each element of X must be a lVector")
    if (n == nil) then
      n = v:length()
    else
      assert(v:length() == n, "each element of X must have the same length")
    end
  end
  
  local m = #X
  -- END: verify inputs

  -- malloc space for the variance covariance matrix A 
  local Aptr = assert(ffi.malloc(ffi.sizeof("double *") * m), "malloc failed")
  Aptr = ffi.cast("double **", Aptr)
  for i=1, m do
    Aptr[i -1] = ffi.malloc(ffi.sizeof("double") * m)
  end

  local Xptr = assert(ffi.malloc(ffi.sizeof("float *") * m), "malloc failed")
  Xptr = ffi.cast("float **", Xptr)
  Aptr[0][0] = 1
  for xidx = 1, m do
    local x_len, xptr, nn_xptr = X[xidx]:chunk()
    assert(nn_xptr == nil, "Null vector should not exist")
    Xptr[xidx-1] = ffi.cast("float *", xptr)
  end
  
  assert(qc["corr_mat"], "Symbol not found corr_mat")
  local status = qc["corr_mat"](Xptr, m, n, Aptr)
  assert(status == 0, "corr matrrix could not be calculated")
  local CM = {}
  -- for this to work, m needs to be less than q_consts.chunk_size
  for i = 1, m do
    CM[i] = lVector.new({qtype = "F8", gen = true, has_nulls = false})
    CM[i]:put_chunk(Aptr[i - 1], nil, m)
  end
  return CM
end
return require('Q/q_export').export('corr_mat', corr_mat)