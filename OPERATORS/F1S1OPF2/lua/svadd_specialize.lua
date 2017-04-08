
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
  f2type
  )
    local sbuf  = ffi.gc(cee.malloc(8), ffi.C.free)
    assert(( f2type == "I1" ) or ( f2type == "I2") or ( f2type == "I4" ) or 
       ( f2type == "I8" ) or ( f2type == "F4") or ( f2type == "F8" ),
       "type must be I1/I2/I4/I8/F4/F8")
    assert(tostring(scalar))
    local status = 0
    if ( f2type == "I1" ) then status = txt_to_I1(scalar, 10, sbuf); end
    if ( f2type == "I2" ) then status = txt_to_I2(scalar, 10, sbuf); end
    if ( f2type == "I4" ) then status = txt_to_I4(scalar, 10, sbuf); end
    if ( f2type == "I8" ) then status = txt_to_I8(scalar, 10, sbuf); end
    if ( f2type == "F4" ) then status = txt_to_F4(scalar, sbuf); end
    if ( f2type == "F8" ) then status = txt_to_F8(scalar, sbuf); end
    assert(status == 0, "Could not convert scalar to proper type")

    local sz1 = assert(g_qtypes[f1type].width)
    local sz2 = assert(g_qtypes[f2type].width)
    local iorf1 = g_iorf[f1type]
    local iorf2 = g_iorf[f2type]
    if ( ( iorf1 == "fixed" ) and ( iorf2 == "fixed" ) ) then
      iorf_outtype = "fixed" 
    else
      iorf_outtype = "floating_point" 
    end
    local szout = sz1; 
    if ( sz2 > szout )  then szout = sz2 end
    if ( iorf_outtype == "floating_point" ) then 
      l_outtype = g_fsz_to_fld[szout]
    elseif ( iorf_outtype == "fixed" ) then 
      l_outtype = g_isz_to_fld[szout]
    else
      assert(false, "Control should not come here")
    end
    local tmpl = 'base.tmpl'
    local subs = {}; 
    subs.fn = "vvadd_" .. f1type .. "_" .. f2type .. "_" .. l_outtype 
    subs.in1type = g_qtypes[f1type].ctype
    subs.in2type = g_qtypes[f2type].ctype
    subs.outtype = g_qtypes[l_outtype].ctype
    subs.c_code_for_operator = "c = a + b; "
    return subs, tmpl
end
