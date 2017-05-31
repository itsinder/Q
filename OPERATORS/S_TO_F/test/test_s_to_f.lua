-- local dbg = require 'debugger'
require 'Q/UTILS/lua/globals'
local ffi = require 'ffi'
local qc = require 'Q/UTILS/lua/q_core'
local pldir  = require 'pl.dir'
local plfile = require 'pl.file'
local plpath = require 'pl.path'
local cdef_str = require 'Q/UTILS/lua/mk_cdef_str'
-- local dbg = require 'debugger'
local const_specialize = require 'Q/OPERATORS/S_TO_F/lua/const_specialize'
local cee = ffi.load("../gen_src/libs_to_f.so")
local cdef_str = mk_cdef_str(plpath.currentdir() .. "/../gen_src/")
ffi.cdef(cdef_str)

local args = {}
args.val = 123
args.len = 100
args.qtype = "I8"
status, subs, tmpl = pcall(const_specialize, args)
assert(status, subs)
local ctype = g_qtypes[args.qtype].ctype
local nX = (args.len * g_qtypes[args.qtype].width)
local X = qc.malloc(nX)
chk_val = qc.cast(subs.out_ctype .. " * ", subs.c_mem)
assert(chk_val[0] == args.val)
cee.const_I8(X, args.len, subs.c_mem)
X = qc.cast(subs.out_ctype .. " * ", X)
for i = 1, args.len do 
  assert(tonumber(X[i-1]) == args.val)
end
print("All done"); os.exit()
