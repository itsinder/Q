local ffi = require "ffi"
ffi.cdef("int print_vector(int* ptr, int length);")
local c = ffi.load('./print.so')
local Generator = require "Generator"
local Vector = require 'Vector'
g_valid_types = {}
g_valid_types['i'] = 'int'
g_valid_types['f'] = 'float'
g_valid_types['d'] = 'double'
g_valid_types['c'] = 'char'
g_chunk_size = 10
--local size = 1000
--create bin file of only ones of type int
local v1 = Vector{field_type='i',
filename='test1.txt', }

local v2 = Vector{field_type='i',
filename='test1.txt', }

local x, x_size = v1:chunk(0)
c.print_vector(x, x_size)
local y, y_size = v2:chunk(1)
c.print_vector(y, y_size)
local v1_gen = Generator{vec=v1}
local i = 0
while(v1_gen:status() ~= 'dead')
do
    local status, chunk, size = v1_gen:get_next_chunk()
    print("Generator chunk number=".. i, "Generator status=" .. tostring(status), "Chunk size=" .. size)
    i = i +1
    c.print_vector(chunk, size)
end

--TODO add tests for put to vector
local v3 = Vector{field_type='i',
filename="o.txt", write_vector=true, 
}
v3:put_chunk(x, x_size)
v3:eov()
local z, z_size = v3:chunk(0)
c.print_vector(z, z_size)
