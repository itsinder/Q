-- TODO IMPORTANT. export LD_LIBRARY_PATH=$PWD
local rootdir = os.getenv("Q_SRC_ROOT")
assert(rootdir, "Do export Q_SRC_ROOT=/home/subramon/WORK/Q or some such")
package.path = package.path.. ";" .. rootdir .. "/UTILS/lua/?.lua"
local plpath = require 'pl.path'
local pldir  = require 'pl.dir'
local log = require 'log'
require 'utils'
require 'compile_so'
require 'extract_fn_proto'
local ffi = require 'ffi'
local cfile = "get_cell.c"
local get_cell_h = extract_fn_proto("get_cell.c")
-- TODO Improve following. Should not have to give path to mmap
local mmap_h = extract_fn_proto(rootdir .. "UTILS/src/mmap.c")
--============================
local nargs = assert(#arg == 3, "Arguments are <nrows> <ncols> <infile>")
local nrows = assert(tonumber(arg[1]))
local ncols = assert(tonumber(arg[2]))
local infile = arg[3]
assert(plpath.isfile(infile), "File not found")
local instr = load_file_as_string(infile)
local nX = string.len(instr)
local xidx = 0
local rowidx = 0
local colidx = 0
local bufsz = 32
ffi.cdef( [[
void *malloc(size_t size);
void free(void *ptr);
]]
)
ffi.cdef(get_cell_h)
ffi.cdef(mmap_h)
local buf = ffi.gc(ffi.C.malloc(bufsz), ffi.C.free) 
is_last_col = false
-- Create libget_cell.so
incs = { "../../../UTILS/inc/", "../../../UTILS/gen_inc/", "../gen_inc/"}
srcs = { "get_cell.c", "../../../UTILS/src/mmap.c" }
tgt = "libget_cell.so"
assert(compile_so(incs, srcs, tgt), "compile of .so failed")
local lget_cell = assert(ffi.load("get_cell.so").get_cell)
local rs_mmap   = assert(ffi.load("get_cell.so").rs_mmap)
X = ffi.new("char **");
nX = ffi.new("uint64_t *");
local status = rs_mmap(infile, X, nX, 0);
os.exit()
local xidx = lget_cell(X, nX, xidx, is_last_col, buf, bufsz);

-- for ( true ) do
-- end
--[[
    bool is_last_col;
    if ( colidx == (ncols-1) ) { 
      is_last_col = true;
    }
    else { 
      is_last_col = false;
    }
    xidx = get_cell(X, nX, xidx, is_last_col, buf, bufsz);
    if ( xidx == 0 ) { go_BYE(-1); }
    fprintf(stderr, "%d:%d->%s\n", rowidx, colidx, buf);
    if ( is_last_col ) { 
      rowidx++;
      colidx = 0;
    }
    else {
      colidx++;
    }
    if ( xidx >= nX ) { break; }
--]]
log.info("All is well")

