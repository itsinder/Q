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
local Dictionary = require "dictionary"

local c = ffi.load('print.so')
local lib = ffi.load("initializevector.so")


_G["Q_DICTIONARIES"] = {}
local dictionary = Dictionary({dict = "D1", is_dict = false, add=true})
dictionary:add_with_condition("e1")
dictionary:add_with_condition("e2")
dictionary:add_with_condition("e3")
dictionary:add_with_condition("e4")
dictionary:add_with_condition("e5")
dictionary:add_with_condition("e6")

print(dictionary:get_string_by_index(1))
print(dictionary:get_string_by_index(2))
print(dictionary:get_string_by_index(3))
print(dictionary:get_string_by_index(4))
print(dictionary:get_string_by_index(5))
print(dictionary:get_string_by_index(6))


local v1 = Vector{field_type='SV', field_size = 4,chunk_size = 5,
  filename="./bin/SV_1.bin", write_vector = true,
}

local v2 = Vector{field_type='SV', field_size = 4,chunk_size = 6,
  filename="./bin/SV_2.bin", write_vector = true,
}

local size = { 4*5, 4*6 }
local x_size = { 5, 6 }
local x = {}
x[1] = ffi.C.malloc(size[1])
x[2] = ffi.C.malloc(size[2])
x[1] = ffi.cast("int32_t * ", x[1])
x[2] = ffi.cast("int32_t * ", x[2])


lib["initialize_vector"](x[1], x_size[1])
lib["initialize_vector"](x[2], x_size[2])


v2:put_chunk(x[2], x_size[2])
v1:put_chunk(x[1], x_size[1])
v2:eov()
v1:eov()
ffi.gc( x[2], ffi.C.free )
ffi.gc( x[1], ffi.C.free )
