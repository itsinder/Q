package.path = package.path .. ";../../../Q2/code/?.lua;../../../UTILS/lua/?.lua"

require 'print_csv'
require 'globals'
require 'is_file'
g_valid_types['B1'] = 'unsigned char'
local Vector = require 'Vector'
local Column = require 'Column'
local ffi = require "ffi"
ffi.cdef
[[ 
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


function create_column_from_bin_file(table_data)
  
  assert(type(table_data)=="table"," table_data should be of type table")
  local field_type = table_data.field_type
  assert(g_valid_types[field_type]~=nil,"Field type is not valid")
  assert(table_data.chunk_size > 0 , " chunk_size should be greater than zero")
  assert(table_data.data==nil," data field of table_data should be nil")
  assert(is_file(table_data.filename),"Filename is not valid")
  
  local field_size = g_qtypes[field_type].width
  local ctype = g_qtypes[field_type].ctype
  local max_length = g_qtypes[field_type].max_length
  local is_integer = field_type == "I1" or field_type == "I2" or field_type == "I4" or field_type == "I8" 
  local is_float = field_type == "F4" or field_type == "F8" 
  
  assert(field_type~=nil,"Field type should not be nil")
  assert(field_size~=nil,"Field size should not be nil")
  assert(ctype~=nil,"ctype should not be nil")
  if is_float == true or is_integer == true then
    assert(max_length~=nil,"max_length should not be nil")
  end
  
  local column = Column{field_type=field_type, field_size = field_size,chunk_size = table_data.chunk_size,
    filename=table_data.filename,  
  }
  return column
end


-- creates column from and table and write to bin file
function write_to_bin_file(table_data)
  
  assert(type(table_data)=="table"," table_data should be of type table")
  local field_type = table_data.field_type
  local field_size = g_qtypes[field_type].width
  local ctype = g_qtypes[field_type].ctype
  local max_length = g_qtypes[field_type].max_length
  local is_integer = field_type == "I1" or field_type == "I2" or field_type == "I4" or field_type == "I8" 
  local is_float = field_type == "F4" or field_type == "F8" 
  
  assert(field_type~=nil,"Field type should not be nil")
  assert(field_size~=nil,"Field size should not be nil")
  assert(ctype~=nil,"ctype should not be nil")
  if is_float == true or is_integer == true then
    assert(max_length~=nil,"max_length should not be nil")
  end
  
  assert(table_data.filename~=nil,"Filename should not be nil")
  assert(g_valid_types[field_type]~=nil,"Field type is not valid")
  assert(table_data.chunk_size > 0 , " chunk_size should be greater than zero")
  assert(type(table_data.data)=="table"," data field of table_data should be of type table")
  
  local column = Column{field_type=field_type, field_size = field_size,chunk_size = table_data.chunk_size,
    filename=table_data.filename, write_vector = true,  
  }
  
  local length = table.getn(table_data.data)
  local length_in_bytes = field_size * length
  -- check for B1
  local chunk = ffi.C.malloc(length_in_bytes)
  chunk = ffi.cast(ctype.. " * ", chunk)
  ffi.C.memset(chunk, 0, length_in_bytes)
  local function_name = "initialize_vector_"..field_type
  
  for k,v in ipairs(table_data.data) do
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
  column:put_chunk(length, chunk)
  column:eov()
  ffi.gc(chunk, ffi.C.free )
end


B1_data = {field_type = "B1", filename = "./bin/B1.bin" , chunk_size = 8,
  data = {true,true,true,false,true,false,true,false}
}
I1_data = {field_type = "I1", filename = "./bin/I1.bin" , chunk_size = 5,
  data = {1,2,3,4,5,6,7,8}
}
I2_data = {field_type = "I2", filename = "./bin/I2.bin" , chunk_size = 5,
  data = {1,2,3,4,5,6,7,8}
}
I4_data = {field_type = "I4", filename = "./bin/I4.bin" , chunk_size = 5,
  data = {1,2,3,4,5,6,7,8}
}
I8_data = {field_type = "I8", filename = "./bin/I8.bin" , chunk_size = 5,
  data = {1,2,3,4,5,6,7,8}
}
F4_data = {field_type = "F4", filename = "./bin/F4.bin" , chunk_size = 5,
  data = {1.2,2.3,3.4,4.5,5.6,6.7,7.8,8.9}
}
F8_data = {field_type = "F8", filename = "./bin/F8.bin" , chunk_size = 5,
  data = {1.2,2.3,3.4,4.5,5.6,6.7,7.8,8.9}
}
SC_data = {field_type = "SC", filename = "./bin/SC.bin" , chunk_size = 3,
  data = {"test1","test2","test3","test4","test5","test6","test7","test8"}
}


B1_read_data = {field_type = "B1", filename = "./bin/B1.bin" , chunk_size = 8}
I1_read_data = {field_type = "I1", filename = "./bin/I1.bin" , chunk_size = 5}
I2_read_data = {field_type = "I2", filename = "./bin/I2.bin" , chunk_size = 5}
I4_read_data = {field_type = "I4", filename = "./bin/I4.bin" , chunk_size = 5}
I8_read_data = {field_type = "I8", filename = "./bin/I8.bin" , chunk_size = 5}
F4_read_data = {field_type = "F4", filename = "./bin/F4.bin" , chunk_size = 5}
F8_read_data = {field_type = "F8", filename = "./bin/F8.bin" , chunk_size = 5}
SC_read_data = {field_type = "SC", filename = "./bin/SC.bin" , chunk_size = 3}
SV_read_data = {field_type = "SV", filename = "./bin/I4.bin" , chunk_size = 3}

write_to_bin_file(B1_data)
write_to_bin_file(I1_data)
write_to_bin_file(I2_data)
write_to_bin_file(I4_data)
write_to_bin_file(I8_data)
write_to_bin_file(F4_data)
write_to_bin_file(F8_data)
write_to_bin_file(SC_data)

--local column_B1 = create_column_from_bin_file(B1_read_data)
local column_I1 = create_column_from_bin_file(I1_read_data)
local column_I2 = create_column_from_bin_file(I2_read_data)
local column_I4 = create_column_from_bin_file(I4_read_data)
local column_I8 = create_column_from_bin_file(I8_read_data)
local column_F4 = create_column_from_bin_file(F4_read_data)
local column_F8 = create_column_from_bin_file(F8_read_data)
local column_SC = create_column_from_bin_file(SC_read_data)
--local column_SV = create_column_from_bin_file(SV_read_data)


local bitVector = Vector{field_type='B1', field_size = 1/8,chunk_size = 8,
filename="./bin/B1.bin",  
}

filter = {}
--filter.lb = 1
--filter.ub = 6
--filter.where = bitVector

arr = {column_I1,column_I2,column_I4,column_I8,column_F4,column_F8,column_SC,100}
print_csv(arr,filter)
