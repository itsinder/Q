package.path = package.path .. ";../../../Q2/code/?.lua;../../../UTILS/lua/?.lua"
package.path = package.path .. ";../../DATA_LOAD/lua/?.lua"

local ffi = require "ffi"
ffi.cdef
[[ 
  void *malloc(size_t size);
  void free(void *ptr);
  void initialize_vector(uint32_t *vec, int n);
  int print_vector(int* ptr, int length); 
]]

local Vector = require 'Vector'
require 'globals'
require 'q_c_functions'
--require 'print_csv'

local field_size = 8

local v1 = Vector{field_type='SC', field_size = field_size,chunk_size = 5,
filename="./bin/SC_1.bin", write_vector = true,  
}

local v2 = Vector{field_type='SC', field_size = field_size,chunk_size = 6,
filename="./bin/SC_2.bin", write_vector = true,
}

local size = { field_size*5, field_size*6 }
local x_size = { 5, 6 }
local x = {}
x[1] = ffi.C.malloc(size[1])
x[2] = ffi.C.malloc(size[2])
x[1] = ffi.cast("char * ", x[1])
x[2] = ffi.cast("char * ", x[2])

values_string = {"test1","test2","test3","test4","test5","test6"}

convert_txt_to_c("SC",values_string[1],x[1],field_size)
convert_txt_to_c("SC",values_string[2],x[1]+field_size,field_size)
convert_txt_to_c("SC",values_string[3],x[1]+2*field_size,field_size)
convert_txt_to_c("SC",values_string[4],x[1]+3*field_size,field_size)
convert_txt_to_c("SC",values_string[5],x[1]+4*field_size,field_size)

convert_txt_to_c("SC",values_string[1],x[2],field_size)
convert_txt_to_c("SC",values_string[2],x[2]+field_size,field_size)
convert_txt_to_c("SC",values_string[3],x[2]+2*field_size,field_size)
convert_txt_to_c("SC",values_string[4],x[2]+3*field_size,field_size)
convert_txt_to_c("SC",values_string[5],x[2]+4*field_size,field_size)
convert_txt_to_c("SC",values_string[6],x[2]+5*field_size,field_size)

print(convert_c_to_txt("SC", x[1], 0,field_size))
print(convert_c_to_txt("SC", x[1], field_size,field_size))
print(convert_c_to_txt("SC", x[1], 2*field_size,field_size))
print(convert_c_to_txt("SC", x[1], 3*field_size,field_size))
print(convert_c_to_txt("SC", x[1], 4*field_size,field_size))


print(convert_c_to_txt("SC", x[2], 0,field_size))
print(convert_c_to_txt("SC", x[2], field_size,field_size))
print(convert_c_to_txt("SC", x[2], 2*field_size,field_size))
print(convert_c_to_txt("SC", x[2], 3*field_size,field_size))
print(convert_c_to_txt("SC", x[2], 4*field_size,field_size))
print(convert_c_to_txt("SC", x[2], 5*field_size,field_size))


v2:put_chunk(x[2], x_size[2])
v1:put_chunk(x[1], x_size[1])
v2:eov()
v1:eov()
ffi.gc( x[2], ffi.C.free )
ffi.gc( x[1], ffi.C.free )

