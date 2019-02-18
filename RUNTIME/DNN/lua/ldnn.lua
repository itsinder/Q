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
--[[
__index metamethod tells about necessary action/provision, when a absent field is called from table.
Below line indicates, whenever any method get called using 'dnn' object (e.g "dnn:fit()"),
here 'dnn' is object/table returned from new() method, the method/key will be searched in ldnn table.
If we comment below line then the methods/fields like 'fit' or 'check' will not be available for 'dnn' object
]]
ldnn.__index = ldnn


--[[
'__call' metamethod allows you to treat a table like a function.
e.g ldnn(mode, Xin, Xout, params)
above call is similar to ldnn.new(mode, Xin, Xout, params)
for more info, please refer sam.lua in the same directory
]]
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

--======================================================
local function get_ptrs_to_data(lptrs, lX)
  assert(lptrs)
  print(type(lX))
  assert(type(lX) == "table")
  local  cptrs = get_ptr(lptrs)
  cptrs = ffi.cast("float **", cptrs)
  for k, v in pairs(lX) do
    -- the end_write will occur when the vector is gc'd
    local x_len, x_chunk, nn_x_chunk = v:start_write()
    assert(x_chunk)
    assert(x_len > 0)
    assert(not nn_x_chunk)
    cptrs[k-1] = get_ptr(x_chunk, "F4") -- Note the -1 
  end
  return cptrs
end
local function release_ptrs_to_data(lX)
  print("XXXX", lX)
  assert(lX and type(lX) == "table")
  for k, v in pairs(lX) do
    assert(v:end_write())
  end
  return true
end
--======================================================
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
  local sz = ffi.sizeof("float *") * n_cols
  local lptrs = cmem.new(sz, "PTR", lbl)
  assert(lptrs)
  --=======================
  return n_cols, data_len, lX, lptrs
end

function ldnn.new(mode, Xin, Xout, params)
  local dnn = setmetatable({}, ldnn)
  --[[ we could have written previous line as follows 
  local dnn = {}
  setmetatable(dnn, ldnn)
  --]]
  -- for meta data stored in dnn
  dnn._meta = {}
  local bsz -- batch_size
  local nphl -- neurons per hidden layer
  local nhl  -- numebr of hidden layers
  local nl   -- number of layers = nhl + 1 + 1
  local npl  -- neurons per layer
  local ncols_in,  nrows_in,  lXin, lptrs_in  = chk_data(Xin, "in")
  local ncols_out, nrows_out, lXout, lptrs_out = chk_data(Xout, "out")
  assert(nrows_in == nrows_out)
  local num_instances = nrows_in

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
  assert(bsz and (type(bsz) == "number" ) and ( bsz > 0 ) )
  --==========================================
  -- c_npl = C neurons per layer 
  local sz = ffi.sizeof("int") * nl
  local c_npl = cmem.new(sz, "I4", "npl") 
  assert(c_npl)
  
  local  X = get_ptr(c_npl, "I4")
  for i = 1, nl do 
    X[i-1] = npl[i]
  end
 
  --==========================================
  dnn._dnn = assert(Dnn.new(bsz, nl, c_npl))
  -- TODO: Should we maintain all the meta data on C side?
  dnn._npl  = npl   -- neurons per layer
  dnn._nl   = nl    -- num layers
  dnn._nphl = nphl -- neurons per hidden layer
  dnn._nhl  = nhl  -- num hidden layers
  dnn._bsz  = bsz   -- batch size 
  dnn._lXin  = lXin  -- copy of input data
  dnn._lXout = lXout -- copy of output data
  dnn._num_instances = num_instances
  dnn._lptrs_in  = lptrs_in   -- C pointers to input data
  dnn._lptrs_out = lptrs_out  -- C pointers to output data
  dnn._c_npl = c_npl
  dnn._num_epochs = 0
  print("XXXX ", lXin)
  return dnn
end

function ldnn:fit(num_epochs)
  if ( not num_epochs ) then 
     num_epochs = 1
  else 
    assert( ( type(num_epochs) == "number")  and 
           ( num_epochs >= 1 ) ) 
  end
  local dnn  = self._dnn
  local lXin = self._lXin
  local lXout = self._lXout
  local lptrs_in  = self._lptrs_in
  local lptrs_out = self._lptrs_out
  local num_instances = self._num_instances

  for i = 1, num_epochs do 
    -- TODO Need to andomly permute data before each epoch 
    local cptrs_in  = get_ptrs_to_data(lptrs_in, lXin)
    local cptrs_out = get_ptrs_to_data(lptrs_out, lXout)
    -- TODO Pass read only data to fstep and bprop
    assert(Dnn.fstep(dnn, lptrs_in, lptrs_out, num_instances))
    assert(Dnn.bprop(dnn, lptrs_in, lptrs_out, num_instances))
    release_ptrs_to_data(lXin)
    release_ptrs_to_data(lXout)
  end
  self._num_epochs = self._num_epochs + num_epochs
  return true
end

function ldnn:check()
  local chk = Dnn.check(self._dnn)
  assert(chk, "Internal error")
  return true
end

return ldnn
