local save = require "save"
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
-- local c = ffi.load('print.so')
local c = ffi.load('vector_mmap.so')
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
save("vone",v1)
