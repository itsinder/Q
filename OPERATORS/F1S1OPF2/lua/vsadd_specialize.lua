return function (
  ftype,
  scalar_val,
  scalar_type
  )
  -- following line used for additional asserts for rem 
  local addnl_asserts = 0
  local is_base_qtype = assert(require 'is_base_qtype')
  assert(is_base_qtype(ftype))
  assert(is_base_qtype(scalar_type))
  local is_global_cdef = false
  if is_global_cdef then 
    local filename = rootdir .. "/OPERATORS/LOAD_CSV/gen_src/_txt_to_" 
      .. scalar_type .. ".c"
    local plpath = require 'pl.path'
    assert(plpath.isfile(filename))
    local txt_to = assert(extract_fn_proto(filename))
    ffi.cdef(txt_to)
  end
  --===========================================
  local promote = require 'promote'
  local out_type = assert(promote(ftype, scalar_type))
  if ( scalar ) then 
    assert(type(scalar) == "string")
    local conv_fn = "txt_to_" .. scalar_type
    -- local status  = ffi.C.conv_fn(scalar, ...)
    assert(status, "Unable to convert to scalar " .. scalar)
  end
  local tmpl = 'arith.tmpl'
  local subs = {}; -- scalar can be undefined while generating code at compile time 
    subs.fn = "vsadd_" .. ftype .. "_" .. scalar_type
    subs.fldtype = g_qtypes[ftype].ctype
    subs.c_code_for_operator = "c = a + b; "
    subs.c_scalar = c_mem
    subs.out_ctype = g_qtypes[out_type].ctype
    subs.scalar_ctype = g_qtypes[scalar_type].ctype
    return subs, tmpl
end
