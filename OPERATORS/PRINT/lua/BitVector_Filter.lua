package.path = package.path .. ";../../../Q2/code/?.lua;../../../UTILS/lua/?.lua"
package.path = package.path .. ";../../DATA_LOAD/lua/?.lua"

local Base_Filter = require "Base_Filter"

local BitVector_Filter = Base_Filter:new()

function BitVector_Filter:new (o)
  o = o or Base_Filter:new(o,iterator)
  setmetatable(o, self)
  self.__index = self
  return o
end

function BitVector_Filter:initialize(iterator,filter)
  Base_Filter:initialize(iterator)
  -- to do
end


function BitVector_Filter:get_row_iterator()
  local func_iterator = self.iterator:get_row_iterator()
  -- to do
end

return BitVector_Filter
