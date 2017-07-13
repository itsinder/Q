local Column  = require 'Q/RUNTIME/COLUMN/code/lua/Column'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local qconsts = require 'Q/UTILS/lua/q_consts'
local qc      = require 'Q/UTILS/lua/q_core'

local function var_covar(X)
  -- X is an n by m matrix (table of lua column)
  -- START: verify inputs
  assert(type(X) == "table", "X must be a table ")
  local n = nil
  for k, v in ipairs(X) do
    assert(type(v) == "Column", "Each element of X must be a column")
    if (n == nil) then
      n = v:length()
    else
      assert(v:length() == n, "each element of X must have the same length")
    end
  end
  
  local m = #X
  -- END: verify inputs

  -- malloc space for the variance covariance matrix A 
  local Aptr = assert(ffi.malloc(ffi.sizeof("double **") * m), "malloc failed")
  Aptr = ffi.cast("double **", Aptr)

  local Xptr = assert(ffi.malloc(ffi.sizeof("double *") * m), "malloc failed")
  Xptr = ffi.cast("double **", Xptr)
  for xidx = 1, m do
    local aptr = assert(ffi.malloc(qconsts.qtypes["F8"].width * m), "malloc failed")
    Aptr[xidx] = ffi.cast("double *", aptr)
    local x_len, xptr, nn_xptr = X[xidx]:chunk(-1)
    assert(nn_xptr == nil, "Values cannot be nil")
    Xptr[xidx-1] = ffi.cast("double *", xptr)
  end
  local status = qc["var_covar"](Xptr, m, n, Aptr)
  assert(status == 0, "eigenvectors could not be calculated")

  local VCM = {}
  -- for this to work, m needs to be less than q_consts.chunk_size
  for i = 1, m do
    VCM[i] = Column.new({field_type = "F8", write_vector = true})
    VCM[i]:put_chunk(n, Aptr[i], nil)
  end
  return VCM

end
return require('Q/q_export').export('var_covar', var_covar)
