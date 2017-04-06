local ffi = require 'ffi'
require 'C_to_txt'

ffi.cdef [[
  void *malloc(size_t size);
  void free(void *ptr);
  void *memset(void *str, int c, size_t n);
  int initialize_vector_B1(unsigned char* x, int i);
  void initialize_vector_I1( int8_t *vec, int i, int8_t val);
  void initialize_vector_I2( int16_t *vec, int i, int16_t val);
  void initialize_vector_I4( int32_t *vec, int i, int32_t val);
  void initialize_vector_I8( int64_t *vec, int i, int64_t val);
  void initialize_vector_F4( float *vec, int i, float val);
  void initialize_vector_F8( double *vec, int i, double val);
  void initialize_vector_SV( int32_t *vec, int i, int32_t val);
  void initialize_vector_SC( char * const X, char *out, int sz_out);
  ]]
  
  
local lib = ffi.load("initialize_vector.so")

local failed_testcases = { }

local no_of_pass_testcases = 0
local no_of_fail_testcases = 0 

function print_result() 
  print("-----------------------------------")
  print("No of successfull testcases ", no_of_pass_testcases)
  print("No of failure testcases     ", no_of_fail_testcases)
  print("-----------------------------------")
end


function file_size (file)
        local filep = io.open(file)
        local current = filep:seek()      -- get current position
        local size = filep:seek("end")    -- get file size
        filep:seek("set", current)        -- restore position
        io.close(filep)
        return size
end

function increment_fail_testcases(index, v, str)
  no_of_fail_testcases = no_of_fail_testcases + 1
  table.insert(failed_testcases, index)
  print("Name of testcase: "..v.name)
  print("Reason for failure: "..str)
end
function create_c_data(vector, input_values)
  
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
  -- check for B1
  local chunk = ffi.C.malloc(length_in_bytes)
  chunk = ffi.cast(ctype.. " * ", chunk)
  ffi.C.memset(chunk, 0, length_in_bytes)
  local function_name = "initialize_vector_"..field_type

  for k,v in ipairs(input_values) do
    if field_type == "B1" then
      if v == true then
        lib[function_name](chunk, k-1)
      end
    elseif field_type == "SC" then
      local v = ffi.cast(ctype.. " * ", v)
      lib[function_name](v,chunk+(k-1)*field_size, field_size)
    else
      lib[function_name](chunk, k-1, v)
    end
  end
  return chunk,length
  
end


function handle_category1(index, v, vector, input_values)
  
  local chunk,length = create_c_data(vector, input_values)
  assert( chunk~=nil, "chunk cannot be nil" )
  
  vector:put_chunk(chunk, length)
  vector:eov()
  
  
  if length ~= #input_values then 
    increment_fail_testcases(index, v, "Length of input is not equal to the number of elements in binary file")
    return nil
  end
  
  -- file size of bin divided by field width should be equal to length
  local field_type = vector.field_type
  local field_size = g_qtypes[field_type].width
  
  local file_size = file_size(v.filename)
  file_size = file_size / field_size
  --print(file_size, length)
  if length ~= file_size then
    increment_fail_testcases(index, v, "Length of input is not equal to the binary file size")
    return nil
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
      increment_fail_testcases(index, v, "Input value does not match with value in binary file")
      return nil
    end
  end
  no_of_pass_testcases = no_of_pass_testcases + 1
  ffi.gc(chunk, ffi.C.free )
end

