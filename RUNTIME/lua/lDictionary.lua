local ffi		= require 'Q/UTILS/lua/q_ffi'
local qconsts		= require 'Q/UTILS/lua/q_consts'
local log		= require 'Q/UTILS/lua/log'
local qc		= require 'Q/UTILS/lua/q_core'
--====================================
local lDictionary = {}
lDictionary.__index = lDictionary

setmetatable(lDictionary, {
   __call = function (cls, ...)
      return cls.new(...)
   end,
})

register_type(lDictionary, "lDictionary")

function lDictionary:get_name()
  if ( qconsts.debug ) then self:check() end
  return self._meta.name
end

function lDictionary:to_file(filename)
  if ( qconsts.debug ) then self:check() end
  assert(filename)
  assert(type(filename) == "string")
  assert(#filename > 0)
  -- TODO Need to finish
  return true
end

function lDictionary.new(arg)
  local dictionary = setmetatable({}, lDictionary)
  -- for meta data stored in dictionary
  dictionary._meta = {}

  assert(type(arg) == "table", "Dictionary constructor requires table as arg")
  local chk = true
  if ( type(arg.chk) ~= nil ) then
    assert(type(arg.chk) == "boolean")
    chk = arg.chk
  end

  if ( arg.filename ) then 
    assert(qc.file_exists(filename))
    assert(qc.(filename))
  end
  if ( arg.int_to_str ) then 
    assert ( type(arg.map_int_to_str) == "table" )
    local fmap =  arg.map_int_to_str 
    assert(#fmap > 0)
    if ( chk ) then 
      local chk_n = 0
      for k, v in pairs(fmap) do chk_n = chk_n + 1 end
      assert(#fmap == chk_n)
    end
    self.map_int_to_str = map_int_to_str
    local rmap = {}
    for k, v in pairs(fmap) do 
      assert(not rmap[v])
      rmap[v] = k
    end
    self.map_str_to_int = rmap
  end
  assert(self.map_str_to_int)
  assert(self.map_int_to_str)
  return dictionary
end

function lDictionary:set_sibling(x)
  assert(type(x) == "lDictionary")
  local exists = false
  for k, v in ipairs(self.siblings) do
    if ( x == v ) then
      exists = true
    end
  end
  if ( not exists ) then
    self.siblings[#self.siblings+1] = x
  end
end
function lDictionary:persist(is_persist)
  local base_status = true
  local nn_status = true
  if ( is_persist == nil ) then 
    is_persist = true
  else
    assert(type(is_persist) == "boolean")
  end
  base_status = Dictionary.persist(self._base_vec, is_persist)
  if ( self._nn_vec ) then 
    nn_status = Dictionary.persist(self._nn_vec, is_persist)
  end
  if ( qconsts.debug ) then self:check() end
  if ( base_status and nn_status ) then
    return self
  else
    return nil
  end
end

function lDictionary:nn_vec()
  -- TODO Can only do this when dictionary has been materialized
  -- That is because one generator starts feeding 2 dictionarys and 
  -- we are not prepared for that
  -- P1 Fix this code. In current state, it is not working
  assert(self:is_eov())
  local dictionary = setmetatable({}, lDictionary)
  dictionary._meta = {}
  dictionary._base_vec = self._nn_vec
  if ( qconsts.debug ) then self:check() end
  return dictionary
end
  
function lDictionary:drop_nulls()
  assert(self:is_eov())
  self._nn_vec = nil
  self:set_meta("__has_nulls", false)
  if ( qconsts.debug ) then self:check() end
  return self
end

function lDictionary:make_nulls(bvec)
  assert(self:is_eov())
  assert(self._nn_vec == nil) 
  assert(type(bvec) == "lDictionary")
  assert(bvec:fldtype() == "B1")
  assert(bvec:num_elements() == self:num_elements())
  assert(bvec:has_nulls() == false)
  self._nn_vec = bvec._base_vec
  self:set_meta("__has_nulls", true)
  if ( qconsts.debug ) then self:check() end
  return self
end
  

function lDictionary:memo(is_memo)
  local base_status = true
  local nn_status = true
  if ( is_memo == nil ) then 
    is_memo = true
  else
    assert(type(is_memo) == "boolean")
  end
  base_status = Dictionary.memo(self._base_vec, is_memo)
  if ( self._nn_vec ) then 
    nn_status = Dictionary.persist(self._nn_vec, is_memo)
  end
  if ( qconsts.debug ) then self:check() end
  if ( base_status and nn_status ) then
    return self
  else
    return nil
  end
end

function lDictionary:num_elements()
  if ( qconsts.debug ) then self:check() end
  -- TODO
  return 0
end


function lDictionary:check()
  -- TODO
  return true
end

function lDictionary:meta()
  return self._meta
end

function lDictionary:reincarnate()
  if ( qconsts.debug ) then self:check() end
  -- TODO
end
  

return lDictionary
