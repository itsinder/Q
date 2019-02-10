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

local function chk_data(X)
  local data_len
  local n_cols 
  assert( ( X ) and ( type(X) == "table" ) )
  for k, v in pairs(X) do 
    assert(type(v) == "lVector" )
    assert(v:is_eov())
    if ( not n_cols ) then 
      data_len = v:length()
      n_cols = 1
    else
      assert(data_len == v:length())
      n_cols = n_cols + 1 
    end
  end
  assert(n_cols >= 1 )
  return n_cols, data_len
end

function ldnn.new(mode, Xin, Xout, params)
  local dnn = setmetatable({}, ldnn)
  -- for meta data stored in dnn
  dnn._meta = {}
  local bsz -- batch_size
  local nphl -- neurons per hidden layer
  local nhl  -- neurons per layer
  local n_in,  data_len_in  = chk_data(Xin)
  local n_out, data_len_out = chk_data(Xout)
  assert(data_len_in == data_len_out)

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
    npl[1] = data_len_in
    for i = 1, nhl do
      npl[i+1] = nphl[i]
    end
    npl[nl] = data_len_out

    if ( ( params.bsz)  and 
            ( type(params.bsz) == "number" ) and 
            ( params.bsz >= 1 ) ) then
      bsz = params.bsz
    else
      bsz = data_len_in
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
  dnn._bsz = bsz
  dnn._num_epochs = 0
  return dnn
end


function ldnn:train(num_epochs)
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
