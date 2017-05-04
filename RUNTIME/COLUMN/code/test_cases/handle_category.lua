local ffi = require 'ffi'
local convert_c_to_txt = require 'C_to_txt'

ffi.cdef [[
  void *malloc(size_t size);
  void free(void *ptr);
  void *memset(void *str, int c, size_t n);
  void *memcpy(void *dest, const void *src, size_t n);
]]
  
local fns = { }
local failed_testcases = { }

local no_of_pass_testcases = 0
local no_of_fail_testcases = 0 

fns.print_result = function () 
  local str
  
  str = "-----------Vector Testcases Results---------------\n"
  str = str.."No of successfull testcases "..no_of_pass_testcases.."\n"
  str = str.."No of failure testcases     "..no_of_fail_testcases.."\n"
  str = str.."---------------------------------------------------------------\n"
  if #failed_testcases > 0 then
    str = str.."Testcases failed are     \n"
    for k,v in ipairs(failed_testcases) do
      str = str..v.."\n"
    end
    str = str.."Run bash test_vector.sh <testcase_number> for details\n\n"
    str = str.."-------------------------------------------------------------\n"
  end 
  print(str)
  local file = assert(io.open("nightly_build_vector.txt", "w"), "Nighty build file open error")
  assert(io.output(file), "Nightly build file write error")
  assert(io.write(str), "Nightly build file write error")
  assert(io.close(file), "Nighty build file close error")
  
end


local file_size = function (file)
  local filep = io.open(file)
  local current = filep:seek()      -- get current position
  local size = filep:seek("end")    -- get file size
  filep:seek("set", current)        -- restore position
  io.close(filep)
  return size
end

fns.increment_fail_testcases = function (index, v, str)
  no_of_fail_testcases = no_of_fail_testcases + 1
  table.insert(failed_testcases, index)
  print("Name of testcase: "..v.name)
  print("Reason for failure: "..str)
end

local create_c_data = function (vector, input_values)
  local field_type = vector.field_type
  assert(field_type~=nil,"Field type should not be nil")
  local field_size = g_qtypes[field_type].width
  assert(field_size~=nil,"Field size should not be nil")
  local ctype = g_qtypes[field_type].ctype
  assert(ctype~=nil,"ctype should not be nil")
  local max_length = g_qtypes[field_type].max_length
  local is_integer = field_type == "I1" or field_type == "I2" or field_type == "I4" or field_type == "I8"
  local is_float = field_type == "F4" or field_type == "F8"
  
  if is_float == true or is_integer == true then
    assert(max_length~=nil,"max_length should not be nil")
  end

  assert(vector.chunk_size > 0 , " chunk_size should be greater than zero")
  assert(type(input_values)=="table"," input values should be of type table")


  local length = table.getn(input_values)
  local length_in_bytes = field_size * length
  local chunk = ffi.gc(ffi.C.malloc(length_in_bytes),ffi.C.free)
  chunk = ffi.cast(ctype.. " * ", chunk)
  ffi.C.memset(chunk, 0, length_in_bytes)
  
  for k,v in ipairs(input_values) do
    if field_type == "SC" then
      local v = ffi.cast(ctype.. " * ", v)
      ffi.C.memcpy(chunk + (k-1)*field_size, v, field_size)
    else
      chunk[k-1] = v
    end
  end
  return chunk,length
end


fns.handle_category2 = function (index, value, vector, input_values)
  local size
  local x_size = #input_values
  if x_size%8 ==0 then 
    size  = x_size/8
  else
    size = (x_size/8) + 1
  end
  size = math.floor(size)
  local x = ffi.gc(ffi.C.malloc(size),ffi.C.free)
  x = ffi.cast("unsigned char* ", x)
  ffi.C.memset(x, 0, size)

  for k,v in ipairs(input_values) do
    if v == 1 then
      local index = (k-1) / 8
      index = math.floor(index)
      x[index] = x[index] + math.pow(2,k-1)
    end
  end

  vector:put_chunk(x, x_size)
  vector:eov()
  
  local field_type = vector.field_type
  local field_size = g_qtypes[field_type].width
  local file_size = file_size(value.filename)
  if size ~= file_size then
    fns["increment_fail_testcases"](index, v, "Length of input is not equal to the binary file size")
    return false
  end

  for k,v in ipairs(input_values) do
    if v == 0 then v = nil end
    if v ~= vector:get_element(k-1) then
      fns["increment_fail_testcases"](index, value, "input value does not match with output")
      return false
    end
  end
  no_of_pass_testcases = no_of_pass_testcases + 1
  return true
end

fns.handle_category1 = function (index, v, vector, input_values)
  
  local chunk,length = create_c_data(vector, input_values)
  assert( chunk~=nil, "chunk cannot be nil" )
  
  vector:put_chunk(chunk, length)
  vector:eov()
  
  -- file size of bin divided by field width should be equal to length
  local field_type = vector.field_type
  local field_size = g_qtypes[field_type].width
  
  local file_size = file_size(v.filename)
  file_size = file_size / field_size
  --print(file_size, length)
  if length ~= file_size then
    fns["increment_fail_testcases"](index, v, "Length of input is not equal to the binary file size")
    return false
  end
  
  local is_SC = v.field_type == "SC"
  
  for i=1,length do
    local value 
    if is_SC then
      value = convert_c_to_txt(vector, i)
    else
      value = tonumber(convert_c_to_txt(vector, i))
    end
    
    if input_values[i] ~= value then
      print(input_values[i], value)
      fns["increment_fail_testcases"](index, v, "Input value does not match with value in binary file")
      return false
    end
  end
  no_of_pass_testcases = no_of_pass_testcases + 1
  return true
end

return fns