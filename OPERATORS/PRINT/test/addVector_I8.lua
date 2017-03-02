package.path = package.path .. ";../../../Q2/code/?.lua;../../../UTILS/lua/?.lua"
local ffi = require "ffi"
ffi.cdef
[[ 
  void *malloc(size_t size);
  void free(void *ptr);
  void initialize_vector_I8(int64_t *vec, int n);
  int print_vector(int* ptr, int length); 
]]
local c = ffi.load('print.so')
local lib = ffi.load("initializevector_I8.so")

local Vector = require 'Vector'
require 'globals'


local v1 = Vector{field_type='I8', field_size = 8,chunk_size = 5,
filename="./bin/I8_1.bin", write_vector = true,  
}

local v2 = Vector{field_type='I8', field_size = 8,chunk_size = 6,
filename="./bin/I8_2.bin", write_vector = true,
}

local size = { 8*5, 8*6 }
local x_size = { 5, 6 }
local x = {}
x[1] = ffi.C.malloc(size[1])
x[2] = ffi.C.malloc(size[2])
x[1] = ffi.cast("int64_t * ", x[1])
x[2] = ffi.cast("int64_t * ", x[2])


lib["initialize_vector_I8"](x[1], x_size[1])
lib["initialize_vector_I8"](x[2], x_size[2])


v2:put_chunk(x[2], x_size[2])
v1:put_chunk(x[1], x_size[1])
v2:eov()
v1:eov()
ffi.gc( x[2], ffi.C.free )
ffi.gc( x[1], ffi.C.free )

