return function (
  args
  )
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
  -- local status  = assert(ffi.C.conv_fn(scalar, ...), "Unable to convert to scalar " .. scalar)
  local tmpl = 'const.tmpl'
  local subs = {}; -- scalar can be undefined while generating code at compile time 
    subs.fn = "const_" .. qtype
    subs.c_scalar = c_mem
    subs.out_c_type = g_qtypes[qtype].ctype
    return subs, tmpl
end
