package.path = package.path .. ";../../../Q2/code/?.lua;../../../UTILS/lua/?.lua"
package.path = package.path .. ";../../DATA_LOAD/lua/?.lua"
require 'pl'
local Base_Filter = require "Base_Filter"

local Range_Filter = Base_Filter:new()

function Range_Filter:new(o)
  o = o or Base_Filter:new(o)
  setmetatable(o, self)
  self.__index = self
  return o
end

function Range_Filter:initialize(iterator,filter)
  Base_Filter:initialize(iterator)
  local min_range_s,max_range_s = stringx.splitv(filter,":")
  
  assert(stringx.isdigit(min_range_s), "min range should be a number")
  assert(stringx.isdigit(max_range_s), "max range should be a number")
  
  local min_range = tonumber(min_range_s)
  local max_range = tonumber(max_range_s)
  assert(min_range >= 0 and min_range < iterator:get_iteration_size(),
    "min range should be between 1 and iterator size")
  assert(max_range >= 1 and max_range <= iterator:get_iteration_size(),
    "max range should be between 2 and iterator size")
  assert(min_range < max_range,"min range should be less than max range")

  self.min_range = min_range
  self.max_range = max_range
  
end


function Range_Filter:get_row_iterator()
  -- to do check
  assert(self.is_initialized == true, "Range Filter class not initialized")
  local func_iterator = self.iterator:get_row_iterator()
  local cur_index = 0
  while cur_index < self.min_range do
    cur_index, row = func_iterator()
  end
  return function()
    if cur_index == self.max_range then
      return nil
    end
    cur_index, row = func_iterator()
    return cur_index, row
  end
end

return Range_Filter
