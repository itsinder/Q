local ffi = require "ffi"
ffi.cdef([[
    typedef struct {
        char *fpos;
        void *base;
        unsigned short handle;
        short flags;
        short unget;
        unsigned long alloc;
        unsigned short buffincrement;
    } FILE;
    int print_vector(int* ptr, int length);
    int print_bits(char * file_name, int length);
    int get_bits_from_file(FILE* fp, int* arr, int length);
    int get_bits_from_array(unsigned char* input_arr, int* arr, int length);
    ]])
local c = ffi.load('./print.so')
local b = ffi.load('./vector_mmap.so')
local Generator = require "Generator"
local Vector = require 'Vector'
g_valid_types = {}
g_valid_types['i'] = 'int'
g_valid_types['f'] = 'float'
g_valid_types['d'] = 'double'
g_valid_types['c'] = 'char'
g_valid_types['B1'] = 'unsigned char'
g_chunk_size = 15
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
local v4 = Vector{field_type='B1',
filename="test_bits.txt", field_size=1/8}
local a, a_size = v4:chunk(0)
local a_int = ffi.gc(c.malloc(ffi.sizeof("int")* a_size), ffi.free)
b.get_bits_from_array(a, a_int, a_size)
print "**************"
c.print_vector(a_int, a_size)
-- add function to print bits:b2

