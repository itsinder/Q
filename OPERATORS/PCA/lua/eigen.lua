local Column  = require 'Q/RUNTIME/COLUMN/code/lua/Column'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local qconsts = require 'Q/UTILS/lua/q_consts'
local qc      = require 'Q/UTILS/lua/q_core'

local function eigen(X)
  local stand_alone_test = true
  local soqc
  if  stand_alone_test then
    local hdr = [[
    extern int eigenvectors(
                 uint64_t n,
                 double *W,
                 double *A,
                 double **X
                );
    ]]
    ffi.cdef(hdr)
    soqc = ffi.load("../src/libeigen.so")
  end
  -- START: verify inputs
  assert(type(X) == "table", "X must be a table ")
  local m = nil
  for k, v in ipairs(X) do
    assert(type(v) == "Column", "Each element of X must be a column")
    if (m == nil) then
      m = v:length()
    else
      assert(v:length() == m, "each element of X must have the same length")
    end
  assert(#X == m, "X must be a square matrix")
  -- Note: not checking symmetry, left to user's discretion to interpret results
  -- if they pass in a matrix that is not symmetric

  end


  -- END: verify inputs

  -- malloc space for eigenvalues (w) and eigenvectors (A)
  local wptr = assert(ffi.malloc(qconsts.qtypes["F8"].width * m), "malloc failed")
  wptr = ffi.cast("double *", wptr)
  local Aptr = assert(ffi.malloc(qconsts.qtypes["F8"].width * m * m), "malloc failed")
  Aptr = ffi.cast("double *", Aptr)

  local Xptr = assert(ffi.malloc(ffi.sizeof("double *") * m), "malloc failed")
  Xptr = ffi.cast("double **", Xptr)
  for xidx = 1, m do
    local x_len, xptr, nn_xptr = X[xidx]:chunk(-1)
    assert(nn_xptr == nil, "Values cannot be nil")
    Xptr[xidx-1] = ffi.cast("double *", xptr)
  end
  local cfn = nil
  if ( stand_alone_test ) then
    cfn = soqc["eigenvectors"]
  else
    cfn = qc["eigenvectors"]
  end
  assert(cfn, "C function for eigenvecrors not found")
  local status = cfn(m, wptr, Aptr, Xptr)
  assert(status == 0, "eigenvectors could not be calculated")

  local E = {}
  -- for this to work, m needs to be less than q_consts.chunk_size
  for i = 1, m do
    E[i] = Column.new({field_type = "F8", write_vector = true})
    E[i]:put_chunk(m, Aptr, nil)
    Aptr = Aptr + m
  end

  local W = Column.new({field_type = "F8", write_vector =true})
  W:put_chunk(m, wptr, nil)

  return({eigenvalues = W, eigenvectors = E})

end
--return eigen
return require('Q/q_export').export('eigen', eigen)
