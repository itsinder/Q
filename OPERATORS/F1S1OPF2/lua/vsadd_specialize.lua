function vsadd_specialize(
  ftype,
  scalar_val,
  scalar_type
  )
  assert(scalar_type == "I1" or scalar_type == "I2" or 
         scalar_type == "I4" or scalar_type == "I8" or 
         scalar_type == "F4" or scalar_type == "F8")
  local filename = rootdir .. "/OPERATORS/LOAD_CSV/gen_src/_txt_to_" 
  .. scalar_type .. ".c"
  local txt_to = assert(extract_fn_proto(filename))
  local conv_fn = "txt_to_" .. scalar_type
  ffi.cdef(txt_to)
  --===========================================

  local promote = require 'promote'
  local out_c_type = assert(promote(ftype, scalar_type))
  if ( scalar ) then 
    assert(type(scalar) == "string")
    -- local status  = ffi.C.conv_fn(scalar, ...)
    assert(status, "Unable to convert to scalar " .. scalar)
  end
  local tmpl = 'arith.tmpl'
  local subs = {}; 
    -- scalar can be undefined while generating code at compile time 
    subs.fn = "vsadd_" .. ftype 
    subs.fldtype = g_qtypes[ftype].ctype
    subs.c_code_for_operator = "c = a + b; "
    subs.c_scalar = c_mem
    subs.out_c_type = out_c_type 
    return subs, tmpl
end
