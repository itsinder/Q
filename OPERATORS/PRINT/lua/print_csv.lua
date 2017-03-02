package.path = package.path .. ";../../../Q2/code/?.lua;../../../UTILS/lua/?.lua"

local Vector_iter = require "Vector_iter"
local Base_Filter = require "Base_Filter"
local Range_Filter = require "Range_Filter"
local BitVector_Filter = require "BitVector_Filter"

function print_csv(input_list, filter, destination)
  local file = assert(io.open(destination, 'w'))
  local iterator = Vector_iter(input_list)
  local filter_object = get_Filter_Object(iterator,filter)
  assert(filter_object~=nil,"Filter object not Found")
  filter_object:initialize(iterator,filter)
  for index,row in filter_object:get_row_iterator() do
    print("Index: "..tostring(index).."            Row "..row)
    write_to_file(file,row)
  end
  assert(io.close(file))

end


function write_to_file(file, data_string)
  file:write(data_string,"\n")
end

local object_map = {}

function initialize_filter()  
  object_map['nil']    = Base_Filter:new(nil)
  object_map['string'] = Range_Filter:new(nil)
  object_map['Vector']    = BitVector_Filter:new(nil)
  return object_map
end


function get_Filter_Object(iterator,filter)
  return object_map[type(filter)]
end


