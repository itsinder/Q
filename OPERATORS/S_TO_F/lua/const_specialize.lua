return function (
  args
  )
  local ffi = require "ffi"
  ffi.cdef([[
  void * malloc(size_t size);
  void free(void *ptr);
  int bar(void *);
  int printf (const char *__restrict __format, ...);
  ]])
  -- TODO This should be for conv_fn, not hard coded as below
  local extract_fn_proto = require 'extract_fn_proto'
  local str = extract_fn_proto("../gen_src/_txt_to_I8.c")
  ffi.cdef(str)
  local cee = ffi.load("../gen_src/libs_to_f.so")

  local dbg = require 'debugger'
  assert(type(args) == "table")
  local val   = assert(args.val)
  local qtype = assert(args.qtype)
  local len   = assert(args.len)
  -- following line used for additional asserts for rem 
  local addnl_asserts = 0
  local is_base_qtype = assert(require 'is_base_qtype')
  assert(is_base_qtype(qtype))
  assert(len > 0, "vector length must be positive")
  local is_global_cdef = false

  if is_global_cdef then 
    local filename = rootdir .. "/OPERATORS/LOAD_CSV/gen_src/_txt_to_" 
      .. qtype .. ".c"
    local plpath = require 'pl.path'
    assert(plpath.isfile(filename))
    local txt_to = assert(extract_fn_proto(filename))
    ffi.cdef(txt_to)
  end
  assert(type(val) == "number")
  local conv_fn = "txt_to_" .. qtype
  local out_c_type = g_qtypes[qtype].ctype
  local c_mem = assert(ffi.gc(ffi.C.malloc(ffi.sizeof(out_c_type)), ffi.C.free))
  -- TODO txt_to_I8 shpuld be conv_fn
  c_mem = ffi.cast(c_mem, "int64_t *")
  ffi.fill(c_mem, 8, 0)
  local status  = cee.txt_to_I8("1000", 10, c_mem)
  cee.bar(c_mem)
  print("hello world")
--    "Unable to convert to scalar " .. args.val)
  local tmpl = 'const.tmpl'
  local subs = {}; -- scalar can be undefined while generating code at compile time 
    subs.fn = "const_" .. qtype
    subs.c_mem = c_mem
    subs.out_c_type = out_c_type
    subs.out_q_type = qtype
    return subs, tmpl
end
