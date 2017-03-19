package.path = package.path .. ";../../../Q2/code/?.lua;../../../UTILS/lua/?.lua"
package.path = package.path .. ";../../DATA_LOAD/lua/?.lua"

local Base_Filter = {iterator = nil}

function Base_Filter:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.is_initialized = false
  return o
end

function Base_Filter:initialize(iterator)
  assert(iterator ~= nil, "Iterator object cannot be nil")
  self.iterator = iterator
  self.is_initialized = true
  
end

function Base_Filter:get_row_iterator()
  assert(self.is_initialized == true, "Base Filter class not initialized")
  return self.iterator:get_row_iterator()
end

return Base_Filter
