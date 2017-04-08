
local ffi = require "ffi"
ffi.cdef([[
  void * malloc(size_t size);
  void free(void *ptr);
  int txt_to_I1(const char *X, int base, int8_t *ptr_out);
  int txt_to_I2(const char *X, int base, int16_t *ptr_out);
  int txt_to_I4(const char *X, int base, int32_t *ptr_out);
  int txt_to_I8(const char *X, int base, int64_t *ptr_out);
  int txt_to_F4(const char *X, float *ptr_out);
  int txt_to_F8(const char *X, double *ptr_out);
  int txt_to_SC(const char *X, char *out, size_t sz_out);
  ]])

function svadd_specialize(
  scalar,
  ftype
  )
    assert(( ftype == "I1" ) or ( ftype == "I2") or ( ftype == "I4" ) or 
       ( ftype == "I8" ) or ( ftype == "F4") or ( ftype == "F8" ),
       "type must be I1/I2/I4/I8/F4/F8")
    assert(tostring(scalar))
    local status = -1
    local sbuf  = ffi.gc(cee.malloc(8), ffi.C.free)
    if ( ftype == "I1" ) then status = txt_to_I1(scalar, 10, sbuf); end
    if ( ftype == "I2" ) then status = txt_to_I2(scalar, 10, sbuf); end
    if ( ftype == "I4" ) then status = txt_to_I4(scalar, 10, sbuf); end
    if ( ftype == "I8" ) then status = txt_to_I8(scalar, 10, sbuf); end
    if ( ftype == "F4" ) then status = txt_to_F4(scalar, sbuf); end
    if ( ftype == "F8" ) then status = txt_to_F8(scalar, sbuf); end
    assert(status == 0, "Could not convert scalar to proper type")

    local tmpl = 'arith.tmpl'
    local subs = {}; 
    subs.fn = "svadd_" .. f1type 
    subs.intype = g_qtypes[f1type].ctype
    subs.c_code_for_operator = "c = a + b; "
    return subs, tmpl
end
