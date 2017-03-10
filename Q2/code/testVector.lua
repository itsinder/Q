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
local c = ffi.load('print.so')
local b = ffi.load('vector_mmap.so')
local Generator = require "Generator"
local Vector = require 'Vector'
local Column = require "Column"
g_valid_types = {}
g_valid_types['i'] = 'int'
g_valid_types['f'] = 'float'
g_valid_types['d'] = 'double'
g_valid_types['c'] = 'char'
g_valid_types['B1'] = 'unsigned char'
g_chunk_size = 16
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
v5 = Column{field_type='i',
filename="o2.txt", write_vector=true,
 }
 v5:put_chunk(x_size, x )
v5:eov()
local dbg = require "debugger"
t1 = Vector{filename="t1.txt", field_type="B1", write_vector=true}
t1:put_chunk(a,x_size)
t1:eov()

v6 = Column{field_type='i',
filename="o3.txt", write_vector=true, nn=true
 }
assert(v6.nn_vec ~= nil , "has an nn vector")
v6:put_chunk(x_size, x, a )
v6:eov()
q_size, q, q_nn = v6:chunk(0)
c.print_vector(q, q_size)
local q_int = ffi.cast( "int*", ffi.gc(c.malloc(ffi.sizeof("int")* q_size), ffi.free) )
b.get_bits_from_array(q_nn, q_int, q_size)
print "**************"
c.print_vector(q_int, q_size)

print "**************"
c.print_vector(a_int, a_size)
print( v1:length())

print(q_int[0])
print(v6:get_element(1))

print "**"
print(q_int[0])
print(q_int[1])
print(q_int[3])
print(q_int[5])
print "**"
print(v6:get_element(0))
print(v6:get_element(1))
print(v6:get_element(3))
print(v6:get_element(5))
print "**************"
V7 = Vector{field_type='B1', filename="o7.txt", write_vector=true}
V7:put_chunk(a, 1)
V7:put_chunk(a, 1)
V7:put_chunk(a, 1)
V7:put_chunk(a, 1)
V7:put_chunk(a, 1)
V7:put_chunk(a, 1)
V7:put_chunk(a, 1)
V7:put_chunk(a, 1)
V7:put_chunk(a, 1)
V7:put_chunk(a, 2)


V7:eov()
