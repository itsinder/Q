package.path = package.path .. ";../../../Q2/code/?.lua;../../../UTILS/lua/?.lua"

_G["Q_DATA_DIR"] = "./"
_G["Q_META_DATA_DIR"] = "./"
_G["Q_DICTIONARIES"] = {}

-- local Vector_Wrapper = require 'vector_wrapper'
require "validate_meta"
require 'globals'
require 'parser'
require 'dictionary'
local Vector = require 'Vector'
local Column = require 'Column'
local dbg = require("debugger")
require "load"
-- require 'q_c_functions'
require 'pl'
require 'utils'
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
void * malloc(size_t size);
void free(void *ptr);
typedef struct {void* ptr_mmapped_file; size_t ptr_file_size; int status; } mmap_struct;
mmap_struct* f_mmap(const char* file_name, bool is_write);
int f_munmap(mmap_struct* map);
FILE *fopen(const char *path, const char *mode);
extern int
I4_to_txt(
const int32_t * const in,
const char * const fmt,
char *X,
size_t nX
);
extern int
F4_to_txt(
const float * const in,
const char * const fmt,
char *X,
size_t nX
);

]])

local c = ffi.load("load_csv.so")
function print_csv(column_list, filter, opfile)
	--TODO check that all are of same length and exist. If static type then
	--repeat
	--TODO check that c_type to txt exists
	assert(type(column_list) == "table")
	for i = 1, #column_list do
		assert(type(column_list[i]) == "Column" or type(column_list[i]) == "Vector")
	end

	local bufsz = 1024
	local cbuf = c.malloc(bufsz) -- TODO alloc max of all field type
	local buf  = c.malloc(bufsz) -- TODO
	local num_cols = #column_list
	local num_rows = column_list[1].length()
	if filter_lb and filter_ub then
		lb = filter_lb
		ub = filter_ub
	else
		lb = 1
		ub = num_rows
	end
	local file = nil
	if opfile ~= nil and opfile ~= "" then
		file = io.open(opfile, "w+")
		io.output(file)
	end
	for rowidx = lb, ub do
		--Column filter comes here
		for colidx = 1, num_cols do
			local c = column_list[colidx]
			cbuf = c:get_element(rowidx-1)
			if cbuf == ffi.NULL then
				c.sprintf(buf, "%s", "\"\"");
			else
				if colidx == 1 then
					status = I4_to_txt(cbuf, buf, bufsz)
				else
					status = F4_to_txt(cbuf, buf, bufsz)
				end
				assert(status == 0)

			end
			if ( rowidx > 1 )  then
				io.write(",")
			end
			io.write(ffi.string(buf))
			fprintf(ofp, "%s", buf)
		end
		io.write("\n")
	end
	if file then
		io.close(file)
	end
end
print_csv(load( "gm1d1.csv" , dofile("gm1.lua"), nil))
