local ffi     = require 'Q/UTILS/lua/q_ffi'
-- TODO Need to delete this cdef from here
ffi.cdef([[
typedef struct _cmem_rec_type {
  void *data;
  int64_t size;
  char field_type[4]; // MAX_LEN_FIELD_TYPE TODO Fix hard coding
  char cell_name[16]; // 15 chaarcters + 1 for nullc, mainly for debugging
} CMEM_REC_TYPE;
]]
)
local qconsts = require 'Q/UTILS/lua/q_consts'
local function get_ptr( x, qtype
)
  local ret_ptr 
  assert(type(x) == "CMEM")
  local y = ffi.cast("CMEM_REC_TYPE *", x)

  assert(type(qtype) == "string")
  if ( qtype == "uint8_t" ) then 
    ret_ptr = ffi.cast(qtype .. " *", y[0].data)
  else
    assert(qconsts.qtypes[qtype])
    local ctype = assert(qconsts.qtypes[qtype].ctype)
    ret_ptr = ffi.cast(ctype .. " *", y[0].data)
  end
  return ret_ptr
end
return get_ptr
