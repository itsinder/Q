local rootdir = os.getenv("Q_SRC_ROOT")
assert(rootdir, "Do export Q_SRC_ROOT=/home/subramon/WORK/Q or some such")
package.path = package.path.. ";" .. rootdir .. "/UTILS/lua/?.lua"
local plpath = require 'pl.path'
local pldir  = require 'pl.dir'
local log = require 'log'
require 'utils'
local ffi = require 'ffi'
--============================
local nargs = assert(#arg == 1, "Need input file as argument")
local infile = arg[1]
assert(plpath.isfile(infile), "File not found")
local X = load_file_as_string(infile)
local ncols = 4
local nrows = 2
local nX = string.len(X)
local xidx = 0
local rowidx = 0
local colidx = 0
local bufsz = 32
ffi.cdef( [[
void *malloc(size_t size);
void free(void *ptr);
size_t get_cell(char *X, size_t nX, size_t xidx, bool is_last_col, char *buf, size_t bufsz);
]])
-- TODO str = "malloc(size_t size);"
-- TODO ffi.cdef(str);
local buf = ffi.gc(ffi.C.malloc(bufsz), ffi.C.free) 
is_last_col = false
-- TODO local lget_cell = ffi.load("get_cell.so").get_cell -- Create libget_cell.so
xidx = lget_cell(X, nX, xidx, is_last_col, buf, bufsz);

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

