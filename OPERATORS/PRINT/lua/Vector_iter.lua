package.path = package.path .. ";../../../Q2/code/?.lua;../../../UTILS/lua/?.lua"
package.path = package.path .. ";../../DATA_LOAD/lua/?.lua"

require 'q_c_functions'
local Generator = require "Generator"
local Vector_iter = {}
Vector_iter.__index = Vector_iter
setmetatable(Vector_iter, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

local original_type = type  -- saves `type` function
-- monkey patch type function
type = function( obj )
  local otype = original_type( obj )
  if  (otype == "table" or otype == "Vector") and getmetatable( obj ) == Vector_iter then
    return "Vector_iter"
  end
  return otype
end


function Vector_iter.new(arg)

  local self = setmetatable({}, Vector_iter)
  assert(type(arg) == "Vector" or type(arg) == "table",
    "argument should be either table or Vector")

  local element_size = 0
  self.iteration_size = 0
  self.iter_function = {}

  if type(arg) == "table" then
    self.input_list = arg
    for k,v in pairs(arg) do
      assert(type(v) == "Vector" or type(v) == "number",
        " The key at index " .. k .. " is not a Vector or number")
      if type(v) == "Vector" then
        self.iter_function[k] = self:get_cell_iterator(v)
        element_size = v:size()
        if v.field_type == 'SV' then
          assert(_G["Q_DICTIONARIES"][v:get_meta("dir")]~=nil,"Q_dictionary cannot be nil")
        end
      else
        self.iter_function[k] = self:get_scalar_value(v)
        element_size = 1
      end
      if element_size > self.iteration_size then
        self.iteration_size = element_size
      end
    end
  end

  if type(arg) == "Vector" then
    self.iteration_size = arg:size()
    self.input_list = {arg}
    self.iter_function[1] = self:get_cell_iterator(arg)
    if arg.field_type == 'SV' then
      assert(_G["Q_DICTIONARIES"][arg:get_meta("dir")]~=nil,"Q_dictionary cannot be nil")
    end
  end

  --print(self.iteration_size)
  return self
end


function Vector_iter:get_iteration_size()
  return self.iteration_size
end

function Vector_iter:get_row_iterator()

  local cur_size = 0
  local result
  return function()

      if cur_size == self.iteration_size then
        return nil
      end

      result = self:get_row()

      local ret_size = cur_size
      cur_size = cur_size + 1
      --print("-----")
      return ret_size, result
  end

end

function Vector_iter:get_row()
  local result = ""
  for k,v in pairs(self.input_list) do
    result = result .. self.iter_function[k]() .. ","
  end
  result = string.sub(result,1,-2)
  return result
end



function Vector_iter:get_cell_iterator(vector)
  local cur_index = 0
  local string_cur_index = 0
  local result = ""
  local vec_gen = Generator{vec=vector}
  local status, chunk, size

  return function ()   -- anonymous function

    if(cur_index % vector.chunk_size == 0) then
      chunk = nil
      if(vec_gen:status() ~= 'dead') then
        status, chunk, size = vec_gen:get_next_chunk()
      end
      cur_index = 0
      string_cur_index = 0
  end
  if chunk == nil then
    result = ""
  else
    if vector.field_type == 'SC' then
      result = convert_c_to_txt(vector.field_type, chunk, string_cur_index,vector.field_size)
      string_cur_index = string_cur_index + vector.field_size
    elseif vector.field_type == 'SV' then
      result = convert_c_to_txt(vector.field_type, chunk, cur_index)
      result = tonumber(result)
      result = _G["Q_DICTIONARIES"][vector:get_meta("dir")]:get_string_by_index(result)
    else 
      result = convert_c_to_txt(vector.field_type, chunk, cur_index)
    end
    cur_index = cur_index + 1
  end
  return result
  end
end


function Vector_iter:get_scalar_value(scalar)
  return function()
    return tostring(scalar)
  end
end


return Vector_iter
