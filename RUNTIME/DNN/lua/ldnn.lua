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


function ldnn.new(mode, params)
  local dnn = setmetatable({}, ldnn)
  -- for meta data stored in dnn
  dnn._meta = {}
  local nl  -- num_layers
  local bsz -- batch_size
  local npl -- neurons_per_layer

  assert( mode and ( type(mode) == "string") ) 
  if ( mode == "new" ) then 
    assert(type(params) == "table", "dnn constructor requires table as arg")
    assert( ( params.npl) and 
            ( type(params.npl) == "table" ) and 
            ( #(params.npl) >= 3 ) )
    npl = params.npl
    nl = #params.npl
    --[[ TODO 
    assert( ( params.activation_function) and 
            ( type(params.activation_function) == "table" ) and 
            ( #(params.activation_function)  == nl) )
    --]]
    assert( ( params.bsz)  and 
            ( type(params.bsz) == "number" ) and 
            ( params.bsz >= 1 ) )
    bsz = params.bsz
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
  ldnn._base_vec = Dnn.new(bsz, nl, c_npl)
  assert(ldnn._base_vec)
  dnn.npl = npl
  dnn.nl  = nl 
  dnn.bsz = bsz
  return dnn
end


function ldnn:check()
  local chk = Dnn.check(self._base_vec)
  assert(chk, "Internal error")
  return true
end

return ldnn
