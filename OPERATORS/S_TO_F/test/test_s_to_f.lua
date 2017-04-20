local ffi = require "ffi"
require "globals"
ffi.cdef([[
  void * malloc(size_t size);
  void free(void *ptr);
  ]])

  -- local dbg = require 'debugger'
  package.path = package.path .. ";../lua/?.lua"
  local const_specialize = require 'const_specialize'

  local plfile = require 'pl.file'
  -- local str = plfile.read("../gen_inc/_const_I8.h")
  local extract_fn_proto = require 'extract_fn_proto'
  local str = extract_fn_proto("../gen_src/_const_I8.c")
  ffi.cdef(str)
  local cee = ffi.load("../gen_src/libs_to_f.so")
  local args = {}
  args.val = 1
  args.len = 100
  args.qtype = "I8"
  status, subs, tmpl = pcall(const_specialize, args)
  assert(status)
  assert(type(subs) == "table")
  local c_type = g_qtypes[args.qtype].ctype
  nX = (args.len * ffi.sizeof(c_type))
  X = ffi.gc(ffi.C.malloc(nX), ffi.C.free)
  Y = ffi.gc(ffi.C.malloc(8), ffi.C.free)
  cee.const_I8(X, args.len, Y)

  print("All done")
