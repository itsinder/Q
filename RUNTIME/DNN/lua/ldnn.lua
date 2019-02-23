local ffi		= require 'Q/UTILS/lua/q_ffi'
local qconsts		= require 'Q/UTILS/lua/q_consts'
local cmem		= require 'libcmem'
local Scalar		= require 'libsclr'
local Dnn		= require 'libdnn'
local register_type	= require 'Q/UTILS/lua/q_types'
local qc		= require 'Q/UTILS/lua/q_core'
local get_ptr           = require 'Q/UTILS/lua/get_ptr'
local get_network_structure           = 
  require 'Q/RUNTIME/DNN/lua/aux/get_network_structure'
local get_dropout_per_layer = 
  require 'Q/RUNTIME/DNN/lua/aux/get_dropout_per_layer'
local get_ptrs_to_data = 
  require 'Q/RUNTIME/DNN/lua/aux/get_ptrs_to_data'
local release_ptrs_to_data = 
  require 'Q/RUNTIME/DNN/lua/aux/release_ptrs_to_data'
local chk_data = require 'Q/RUNTIME/DNN/lua/aux/chk_data'
local set_data = require 'Q/RUNTIME/DNN/lua/aux/set_data'
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


function ldnn.new(params)
  local dnn = setmetatable({}, ldnn)
  --[[ we could have written previous line as follows 
  local dnn = {}
  setmetatable(dnn, ldnn)
  --]]
  -- for meta data stored in dnn
  assert(type(params) == "table", "dnn constructor requires table as arg")
  --[[
  assert( ( params.activation_function) and 
          ( type(params.activation_function) == "table" ) and 
          ( #(params.activation_function)  == nl) )
  --]]
  -- Get structure of network, # of layers and # of neurons per layer
  local nl, npl, c_npl = get_network_structure(params)
  --=========== get dropout per layer; 0 means no drop out
  local dpl, c_dpl = get_dropout_per_layer(params, nl)
  --==========================================
  dnn._dnn = assert(Dnn.new(nl, c_npl, c_dpl))
  -- TODO: Should we maintain all the meta data on C side?
  dnn._npl    = npl   -- neurons per layer for Lua
  dnn._c_npl  = c_npl -- neurons per layer for C
  dnn._dpl    = dpl   -- dropout per layer for Lua
  dnn._c_dpl  = c_dpl -- dropout per layer for C
  dnn._nl     = nl    -- num layers
  dnn._num_epochs = 0
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
    -- TODO Need to randomly permute data before each epoch 
    local cptrs_in  = get_ptrs_to_data(lptrs_in, lXin)
    local cptrs_out = get_ptrs_to_data(lptrs_out, lXout)
    -- TODO Pass read only data to fpass and bprop
    assert(Dnn.fpass(dnn, lptrs_in, lptrs_out, num_instances))
    -- WRONG: assert(Dnn.bprop(dnn, lptrs_in, lptrs_out, num_instances))
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

function ldnn:set_io(Xin, Xout, bsz)
  local ncols_in,  nrows_in  = chk_data(Xin)
  local ncols_out, nrows_out = chk_data(Xout)
  assert(nrows_in == nrows_out)
  assert(nrows_in > 0)

  assert( ( bsz) and ( type(bsz) == "number")  and ( bsz >= 1 ) ) 

  local lXin, lptrs_in   = set_data(Xin, "in")
  local lXout, lptrs_out = set_data(Xout, "out")

  local npl = self._npl
  local  nl = self._nl
  assert(ncols_in  == npl[1] )
  assert(ncols_out == npl[nl])
  assert(ncols_out == 1) -- TODO: Assumption to be relaxed

  local dnn  = self._dnn
  assert(Dnn.set_io(dnn, bsz))
  --==========================================
  self._lXin  = lXin  -- copy of input data
  self._lXout = lXout -- copy of output data
  self._bsz   = bsz
  self._num_instances = nrows_in
  self._lptrs_in  = lptrs_in   -- C pointers to input data
  self._lptrs_out = lptrs_out  -- C pointers to output data
  return self
end

local function release_vectors(X)
  if ( X ) then 
    for _, v in ipairs(X) do
      v:delete()
    end
  end
  X  = nil
end

function ldnn:unset_io()
  release_vectors(self._lXin)
  release_vectors(self._lXout)
  self._num_instances = nil
  self._lptrs_in  = nil
  self._lptrs_out = nil
end

function ldnn:delete()
  ldnn:unset_io()
end

return ldnn
