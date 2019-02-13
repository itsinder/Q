local ffi		= require 'Q/UTILS/lua/q_ffi'
local qconsts		= require 'Q/UTILS/lua/q_consts'
local cmem		= require 'libcmem'
local Scalar		= require 'libsclr'
local Dnn		= require 'libdnn'
local register_type	= require 'Q/UTILS/lua/q_types'
local qc		= require 'Q/UTILS/lua/q_core'
local get_ptr           = require 'Q/UTILS/lua/get_ptr'
--====================================
local ldnn = {}
ldnn.__index = ldnn

setmetatable(ldnn, {
   __call = function (cls, ...)
      return cls.new(...)
   end,
})

register_type(ldnn, "ldnn")
-- -- TODO Indrajeet to change WHAT IS THIS???? 
-- local original_type = type  -- saves `type` function
-- -- monkey patch type function
-- type = function( obj )
--    local otype = original_type( obj )
--    if  otype == "table" and getmetatable( obj ) == ldnn then
--       return "ldnn"
--    end
--    return otype
-- end

local function chk_data(X, lbl)
  local data_len
  local n_cols 
  assert( ( X ) and ( type(X) == "table" ) )
  for k, v in pairs(X) do 
    assert(type(v) == "lVector" )
    assert(v:is_eov())
    assert(not v:has_nulls())
    assert(v:fldtype() == "F4", "currently only F4 data is supported")
    if ( not n_cols ) then 
      data_len = v:length()
      n_cols = 1
    else
      assert(data_len == v:length())
      n_cols = n_cols + 1 
    end
  end
  assert(n_cols >= 1 )
  --=======================
  -- Since we will randomize the input, we have to make a copy of it
  local lX = {}
  for k, v in pairs(X) do 
    lX[k] = v:clone()
  end
  --=======================
  -- We set up an array of pointers to the data of each vector
  local ptrs = assert(cmem.new(ffi.sizeof("float *") * n_cols), "F4", lbl)
  ptrs = ffi.cast("float **", ptrs)
  for k, v in pairs(lX) do
    -- the end_write will occur when the vector is gc'd
    local x_len, x_chunk, nn_x_chunk = v:start_write()
    assert(x_chunk)
    assert(x_len > 0)
    assert(not nn_x_chunk)
    ptrs[k] = get_ptr(x_chunk, "F4")
  end
  --=======================
  return n_cols, data_len, lX, ptrs
end

function ldnn.new(mode, Xin, Xout, params)
  local dnn = setmetatable({}, ldnn)
  -- for meta data stored in dnn
  dnn._meta = {}
  local bsz -- batch_size
  local nphl -- neurons per hidden layer
  local nhl  -- neurons per layer
  local ncols_in,  nrows_in,  lXin, cptrs_in  = chk_data(Xin, "in")
  local ncols_out, nrows_out, lXout, cptrs_out = chk_data(Xout, "out")
  assert(nrows_in == nrows_out)

  assert( mode and ( type(mode) == "string") ) 
  if ( mode == "new" ) then 
    assert(type(params) == "table", "dnn constructor requires table as arg")
    assert( ( params.nphl) and 
            ( type(params.nphl) == "table" ) and 
            ( #(params.nphl) >= 1 ) )
    nphl = params.nphl
    nhl = #params.nphl
    --[[ TODO 
    assert( ( params.activation_function) and 
            ( type(params.activation_function) == "table" ) and 
            ( #(params.activation_function)  == nl) )
    --]]
    nl = nhl + 1 + 1  -- 1 for input, 1 for output
    npl = {}
    npl[1] = ncols_in
    for i = 1, nhl do
      npl[i+1] = nphl[i]
    end
    npl[nl] = ncols_out

    if ( ( params.bsz)  and 
            ( type(params.bsz) == "number" ) and 
            ( params.bsz >= 1 ) ) then
      bsz = params.bsz
    else
      bsz = nrows_in
    end
  elseif ( mode == "hydrate" ) then 
    assert(nil, "TODO")
  else
    assert(nil, "Invalid mode of creation")
  end
  --==========================================
  -- c_npl = C neurons per layer 
  local c_npl = cmem.new(ffi.sizeof("int") * nl, "I4") 
  local  X = get_ptr(c_npl, "I4")
  for i = 1, nl do 
    X[i-1] = npl[i]
  end
  --==========================================
  ldnn._dnn = assert(Dnn.new(bsz, nl, c_npl))
  -- TODO: Should we maintain all the meta data on C side?
  dnn._npl = npl   -- neurons per layer
  dnn._nl  = nl    -- num layers
  dnn._nphl = nphl -- neurons per hidden layer
  dnn._nhl  = nhl  -- num hidden layers
  dnn._bsz = bs    -- batch size 
  dnn._Xin = lXin   -- copy of input data
  dnn._Xin = lXout  -- copy of output data
  dnn._cptrs_in  = cptrs_in   -- C pointers to input data
  dnn._cptrs_out = cptrs_out  -- C pointers to output data
  dnn._num_epochs = 0
  return dnn
end

--================================== Destructor
function ldnn.destructor()
  if self._dnn.Xin then 
    for k, v in pairs(self._dnn.Xin) do
      v:end_write()
      v:delete()
    end
  end
  if self._dnn.Xout then 
    for k, v in pairs(self._dnn.Xout) do
      v:end_write()
      v:delete()
    end
  end
end

ldnn.__gc = ldnn.destructor
--================================== 

function ldnn:fit(num_epochs)
  if ( not num_epochs ) then 
   num_epochs = 1
 else 
   assert( ( type(num_epochs) == "number")  and 
           ( num_epochs >= 1 ) ) 
  end
  for i = 1, num_epochs do 
    assert(Dnn.fstep(self._dnn),  "Internal error")
    assert(Dnn.bprop(self._dnn),  "Internal error")
  end
  _dnn.num_epochs = _dnn.num_epochs + num_epochs
  return true
end

function ldnn:check()
  local chk = Dnn.check(self._dnn)
  assert(chk, "Internal error")
  return true
end

return ldnn
