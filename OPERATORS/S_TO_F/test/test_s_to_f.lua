
  local ffi = require 'ffi'
  local tmp = require "ffi_core"
  local q_core = tmp()
  local ffi_malloc = require "ffi_malloc"
  local pldir = require 'pl.dir'
  local plfile = require 'pl.file'
  -- local dbg = require 'debugger'
  package.path = package.path .. ";../lua/?.lua"
  local const_specialize = require 'const_specialize'
  local cee = ffi.load("../gen_src/libs_to_f.so")
  incfiles  = pldir.getfiles("../gen_inc/", "*.h")
  incs = {}
  for i, v in ipairs(incfiles) do
    local x = plfile.read(v)
    x = string.gsub(x, "#include.-\n", "")
    incs[#incs+1] = x
  end
  cdef_str = table.concat(incs)
  ffi.cdef(cdef_str)
  
  local args = {}
  args.val = 123
  args.len = 100
  args.qtype = "I8"
  local ctype = assert(g_qtypes[args.qtype].ctype)
  status, subs, tmpl = pcall(const_specialize, args)
  assert(status)
  assert(type(subs) == "table")
  local ctype = g_qtypes[args.qtype].ctype
  local nX = (args.len * ffi.sizeof(ctype))
  local X = ffi_malloc(nX)
  cee.const_I8(X, args.len, subs.c_mem)
  -- local x = ffi.cast(subs.out_c_type .. " *", subs.c_mem); print(x[0])
  
  X = ffi.cast(subs.out_c_type .. " * ", X)
  for i = 1, args.len do 
    assert(tonumber(X[i-1]) == args.val)
  end

  print("All done")
