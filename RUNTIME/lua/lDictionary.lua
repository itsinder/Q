local ffi           = require 'Q/UTILS/lua/q_ffi'
local qconsts       = require 'Q/UTILS/lua/q_consts'
local log           = require 'Q/UTILS/lua/log'
local qc            = require 'Q/UTILS/lua/q_core'
local register_type = require 'Q/UTILS/lua/q_types'
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

function lDictionary.new(inparam, optargs)
  local dictionary = setmetatable({}, lDictionary)
  -- for meta data stored in dictionary
  dictionary._meta = {}

  assert( ( type(inparam) == "table") or ( type(inparam) == "string") )
  local chk = true
  if ( optargs ) then 
    if ( type(opatargs.chk) ~= nil ) then
      assert(type(optargs.chk) == "boolean")
      chk = optargs.chk
    end
  end

  local rmap -- map from string to int
  local fmap -- map from int to string
  if ( type(inparam) == "string" ) then 
    local filename = inparam
    assert(qc.file_exists(filename))
    assert(qc.get_file_size(filename) > 0)
    fmap = require(filename)
  end
  if ( type(inparam) == "table" ) then 
    fmap = inparam
  end
  assert ( type(fmap) == "table" )
  assert(#fmap > 0)
  if ( chk ) then 
    local chk_n = 0
    for k, v in pairs(fmap) do chk_n = chk_n + 1 end
    assert(#fmap == chk_n)
  end
  local rmap = {}
  for k, v in pairs(fmap) do 
     assert(not rmap[v])
    rmap[v] = k
  end
  dictionary._map_str_to_int = rmap
  dictionary._map_int_to_str = fmap
  return dictionary
end

function lDictionary:num_elements()
  if ( qconsts.debug ) then self:check() end
  return #self._map_int_to_str
end


function lDictionary:pr(direction)
  assert( (direction and type(direction) == "string"))
  if ( direction == "forward" ) then 
    for k, v in pairs(self._map_int_to_str) do print(k, v) end 
  elseif ( direction == "reverse" ) then 
    for k, v in pairs(self._map_str_to_int) do print(k, v) end 
  else
    assert(nil)
  end
  return true
end

function lDictionary:check()
  assert(self._map_int_to_str)
  assert(type(self._map_int_to_str) == "table")
  assert(#self._map_int_to_str > 0)
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
